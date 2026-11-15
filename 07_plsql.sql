SET SERVEROUTPUT ON;

BEGIN
  FOR i IN (SELECT index_name FROM user_indexes
            WHERE  index_name IN ('IDX_BOOKING_USER','IDX_BOOKING_SHOW','IDX_SHOW_MOVIE',
                                  'IDX_REVIEW_MOVIE','IDX_WATCHLIST_MOVIE','IDX_MOVIE_GENRE_GENRE')) LOOP
    EXECUTE IMMEDIATE 'DROP INDEX ' || i.index_name;
  END LOOP;
END;
/

CREATE INDEX idx_booking_user      ON booking (user_id);
CREATE INDEX idx_booking_show      ON booking (show_id);
CREATE INDEX idx_show_movie        ON movie_show (movie_id);
CREATE INDEX idx_review_movie      ON review (movie_id);
CREATE INDEX idx_watchlist_movie   ON watchlist (movie_id);
CREATE INDEX idx_movie_genre_genre ON movie_genre (genre_id);

SELECT table_name, index_name, uniqueness
FROM   user_indexes
ORDER  BY table_name, index_name;

CREATE OR REPLACE FUNCTION get_seat_price (
  p_show_id IN movie_show.show_id%TYPE,
  p_seat_id IN seat.seat_id%TYPE
) RETURN NUMBER
IS
  v_base_price  movie_show.base_price%TYPE;
  v_seat_type   seat.seat_type%TYPE;
BEGIN
  SELECT base_price INTO v_base_price FROM movie_show WHERE show_id = p_show_id;
  SELECT seat_type  INTO v_seat_type  FROM seat       WHERE seat_id = p_seat_id;

  IF v_seat_type = 'PREMIUM' THEN
    RETURN v_base_price + 100;
  ELSE
    RETURN v_base_price;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20010,
      'Show ' || p_show_id || ' or seat ' || p_seat_id || ' does not exist.');
END get_seat_price;
/

CREATE OR REPLACE FUNCTION get_avg_rating (
  p_movie_id IN movie.movie_id%TYPE
) RETURN NUMBER
IS
  v_avg NUMBER;
BEGIN
  SELECT ROUND(AVG(rating), 2) INTO v_avg
  FROM   review
  WHERE  movie_id = p_movie_id;

  RETURN v_avg;
END get_avg_rating;
/

CREATE OR REPLACE FUNCTION seats_left (
  p_show_id IN movie_show.show_id%TYPE
) RETURN NUMBER
IS
  v_capacity NUMBER;
  v_booked   NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_capacity
  FROM   seat st
  JOIN   movie_show sh ON sh.screen_id = st.screen_id
  WHERE  sh.show_id = p_show_id;

  IF v_capacity = 0 THEN
    RETURN NULL;
  END IF;

  SELECT COUNT(*) INTO v_booked FROM booking_seat WHERE show_id = p_show_id;

  RETURN v_capacity - v_booked;
END seats_left;
/

SELECT m.title, get_avg_rating(m.movie_id) AS avg_rating
FROM   movie m
ORDER  BY avg_rating DESC NULLS LAST;

SELECT sh.show_id, m.title, seats_left(sh.show_id) AS seats_left,
       get_seat_price(sh.show_id, 101) AS price_a1_if_screen1
FROM   movie_show sh
JOIN   movie m ON m.movie_id = sh.movie_id
WHERE  sh.screen_id = 1;

CREATE OR REPLACE PROCEDURE book_seats (
  p_user_id    IN  app_user.user_id%TYPE,
  p_show_id    IN  movie_show.show_id%TYPE,
  p_seat_ids   IN  VARCHAR2,
  p_booking_id OUT booking.booking_id%TYPE
)
IS
  v_show_start  movie_show.show_start%TYPE;
  v_seat_count  NUMBER;
  v_seat_id     seat.seat_id%TYPE;
BEGIN
  SAVEPOINT start_booking;
  p_booking_id := NULL;

  BEGIN
    SELECT show_start INTO v_show_start FROM movie_show WHERE show_id = p_show_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20020, 'Show ' || p_show_id || ' does not exist.');
  END;

  IF v_show_start <= SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20021, 'This show has already started.');
  END IF;

  v_seat_count := NVL(REGEXP_COUNT(p_seat_ids, '[^,]+'), 0);
  IF v_seat_count = 0 OR v_seat_count > 10 THEN
    RAISE_APPLICATION_ERROR(-20022, 'Select between 1 and 10 seats.');
  END IF;

  INSERT INTO booking (booking_id, user_id, show_id, booking_time, status)
  VALUES (booking_seq.NEXTVAL, p_user_id, p_show_id, SYSDATE, 'PENDING')
  RETURNING booking_id INTO p_booking_id;

  FOR i IN 1 .. v_seat_count LOOP
    v_seat_id := TO_NUMBER(TRIM(REGEXP_SUBSTR(p_seat_ids, '[^,]+', 1, i)));

    INSERT INTO booking_seat (booking_id, show_id, seat_id, price_paid)
    VALUES (p_booking_id, p_show_id, v_seat_id, get_seat_price(p_show_id, v_seat_id));
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' created with ' ||
                       v_seat_count || ' seat(s). Status: PENDING.');
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK TO start_booking;
    p_booking_id := NULL;
    RAISE_APPLICATION_ERROR(-20024, 'One or more of these seats is already booked for this show.');
  WHEN OTHERS THEN
    ROLLBACK TO start_booking;
    p_booking_id := NULL;
    RAISE;
END book_seats;
/

CREATE OR REPLACE PROCEDURE make_payment (
  p_booking_id IN booking.booking_id%TYPE,
  p_method     IN payment.payment_method%TYPE
)
IS
  v_status  booking.status%TYPE;
  v_amount  payment.amount%TYPE;
BEGIN
  SAVEPOINT start_payment;

  BEGIN
    SELECT status INTO v_status
    FROM   booking
    WHERE  booking_id = p_booking_id
    FOR UPDATE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20030, 'Booking ' || p_booking_id || ' does not exist.');
  END;

  IF v_status <> 'PENDING' THEN
    RAISE_APPLICATION_ERROR(-20031, 'Booking ' || p_booking_id || ' is ' || v_status ||
                                    ', not awaiting payment.');
  END IF;

  SELECT SUM(price_paid) INTO v_amount FROM booking_seat WHERE booking_id = p_booking_id;

  MERGE INTO payment p
  USING (SELECT p_booking_id AS booking_id FROM dual) src
  ON (p.booking_id = src.booking_id)
  WHEN MATCHED THEN
    UPDATE SET p.amount         = v_amount,
               p.payment_method = p_method,
               p.payment_status = 'SUCCESS',
               p.paid_at        = SYSDATE
  WHEN NOT MATCHED THEN
    INSERT (payment_id, booking_id, amount, payment_method, payment_status, paid_at)
    VALUES (payment_seq.NEXTVAL, p_booking_id, v_amount, p_method, 'SUCCESS', SYSDATE);

  UPDATE booking SET status = 'CONFIRMED' WHERE booking_id = p_booking_id;

  DBMS_OUTPUT.PUT_LINE('Payment of Rs ' || v_amount || ' by ' || p_method ||
                       ' received. Booking ' || p_booking_id || ' is CONFIRMED.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_payment;
    RAISE;
END make_payment;
/

CREATE OR REPLACE PROCEDURE cancel_booking (
  p_booking_id IN booking.booking_id%TYPE
)
IS
  v_status      booking.status%TYPE;
  v_show_start  movie_show.show_start%TYPE;
  v_seats_freed NUMBER;
BEGIN
  SAVEPOINT start_cancel;

  BEGIN
    SELECT b.status, sh.show_start
    INTO   v_status, v_show_start
    FROM   booking b
    JOIN   movie_show sh ON sh.show_id = b.show_id
    WHERE  b.booking_id = p_booking_id
    FOR UPDATE OF b.status;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20040, 'Booking ' || p_booking_id || ' does not exist.');
  END;

  IF v_status = 'CANCELLED' THEN
    RAISE_APPLICATION_ERROR(-20041, 'Booking ' || p_booking_id || ' is already cancelled.');
  END IF;

  IF v_show_start <= SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20042, 'The show has already started; it cannot be cancelled.');
  END IF;

  DELETE FROM booking_seat WHERE booking_id = p_booking_id;
  v_seats_freed := SQL%ROWCOUNT;

  UPDATE booking SET status = 'CANCELLED' WHERE booking_id = p_booking_id;

  UPDATE payment SET payment_status = 'REFUNDED'
  WHERE  booking_id = p_booking_id AND payment_status = 'SUCCESS';

  IF SQL%ROWCOUNT = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' cancelled, ' || v_seats_freed ||
                         ' seat(s) freed, payment refunded.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' cancelled, ' || v_seats_freed ||
                         ' seat(s) freed (nothing was paid).');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_cancel;
    RAISE;
END cancel_booking;
/

CREATE OR REPLACE PROCEDURE save_review (
  p_user_id  IN review.user_id%TYPE,
  p_movie_id IN review.movie_id%TYPE,
  p_rating   IN review.rating%TYPE,
  p_text     IN review.review_text%TYPE DEFAULT NULL
)
IS
BEGIN
  MERGE INTO review r
  USING (SELECT p_user_id AS user_id, p_movie_id AS movie_id FROM dual) src
  ON (r.user_id = src.user_id AND r.movie_id = src.movie_id)
  WHEN MATCHED THEN
    UPDATE SET r.rating      = p_rating,
               r.review_text = p_text,
               r.review_date = SYSDATE
  WHEN NOT MATCHED THEN
    INSERT (user_id, movie_id, rating, review_text, review_date)
    VALUES (p_user_id, p_movie_id, p_rating, p_text, SYSDATE);
END save_review;
/

CREATE OR REPLACE PROCEDURE print_user_activity (
  p_user_id IN app_user.user_id%TYPE
)
IS
  v_user  app_user%ROWTYPE;

  CURSOR c_reviews IS
    SELECT m.title, r.rating
    FROM   review r
    JOIN   movie m ON m.movie_id = r.movie_id
    WHERE  r.user_id = p_user_id
    ORDER  BY r.rating DESC, m.title;

  v_review  c_reviews%ROWTYPE;
  v_total   NUMBER := 0;
BEGIN
  SELECT * INTO v_user FROM app_user WHERE user_id = p_user_id;

  DBMS_OUTPUT.PUT_LINE('Activity of ' || v_user.full_name || ' (@' || v_user.username || ')');
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------');

  DBMS_OUTPUT.PUT_LINE('Reviews:');
  OPEN c_reviews;
  LOOP
    FETCH c_reviews INTO v_review;
    EXIT WHEN c_reviews%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  ' || RPAD(v_review.title, 30) || TO_CHAR(v_review.rating, '0.0'));
  END LOOP;
  IF c_reviews%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('  (no reviews yet)');
  END IF;
  CLOSE c_reviews;

  DBMS_OUTPUT.PUT_LINE('Bookings:');
  FOR rec IN (SELECT bk.booking_id, m.title, bk.status,
                     NVL((SELECT SUM(bs.price_paid) FROM booking_seat bs
                          WHERE bs.booking_id = bk.booking_id), 0) AS amount
              FROM   booking bk
              JOIN   movie_show sh ON sh.show_id = bk.show_id
              JOIN   movie m       ON m.movie_id = sh.movie_id
              WHERE  bk.user_id = p_user_id
              ORDER  BY bk.booking_id) LOOP
    DBMS_OUTPUT.PUT_LINE('  #' || RPAD(rec.booking_id, 5) || RPAD(rec.title, 28) ||
                         RPAD(rec.status, 11) || 'Rs ' || rec.amount);
    IF rec.status = 'CONFIRMED' THEN
      v_total := v_total + rec.amount;
    END IF;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Total spent on confirmed bookings: Rs ' || v_total);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No user with id ' || p_user_id);
END print_user_activity;
/

CREATE OR REPLACE TRIGGER trg_review_clears_watchlist
AFTER INSERT ON review
FOR EACH ROW
BEGIN
  DELETE FROM watchlist
  WHERE  user_id  = :NEW.user_id
  AND    movie_id = :NEW.movie_id;
END;
/

SELECT object_type, object_name, status
FROM   user_objects
WHERE  object_type IN ('FUNCTION','PROCEDURE','TRIGGER','VIEW','SEQUENCE')
ORDER  BY object_type, object_name;

SELECT name, type, line, text FROM user_errors ORDER BY name, sequence;
