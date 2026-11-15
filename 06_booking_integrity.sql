CREATE OR REPLACE TRIGGER trg_booking_seat_screen
BEFORE INSERT OR UPDATE OF seat_id, show_id ON booking_seat
FOR EACH ROW
DECLARE
  v_show_screen  movie_show.screen_id%TYPE;
  v_seat_screen  seat.screen_id%TYPE;
BEGIN
  SELECT screen_id INTO v_show_screen FROM movie_show WHERE show_id = :NEW.show_id;
  SELECT screen_id INTO v_seat_screen FROM seat       WHERE seat_id = :NEW.seat_id;

  IF v_show_screen <> v_seat_screen THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Seat ' || :NEW.seat_id || ' is not in screen ' || v_show_screen ||
      ' where show ' || :NEW.show_id || ' is running.');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END;
/

INSERT INTO booking (booking_id, user_id, show_id, status)
VALUES (900, 8, 1, 'PENDING');

INSERT INTO booking_seat (booking_id, show_id, seat_id, price_paid)
VALUES (900, 1, 101, 250);

SAVEPOINT after_valid_seat;

INSERT INTO booking (booking_id, user_id, show_id, status)
VALUES (901, 8, 999, 'PENDING');

INSERT INTO booking_seat (booking_id, show_id, seat_id, price_paid)
VALUES (900, 1, 9999, 250);

INSERT INTO booking_seat (booking_id, show_id, seat_id, price_paid)
VALUES (900, 1, 105, 250);

INSERT INTO booking_seat (booking_id, show_id, seat_id, price_paid)
VALUES (900, 1, 201, 250);

INSERT INTO booking_seat (booking_id, show_id, seat_id, price_paid)
VALUES (900, 2, 401, 200);

INSERT INTO booking (booking_id, user_id, show_id, status)
VALUES (902, 8, 1, 'DONE');

UPDATE booking SET status = 'BOOKED' WHERE booking_id = 900;

INSERT INTO payment (payment_id, booking_id, amount, payment_method, payment_status, paid_at)
VALUES (900, 900, 250, 'UPI', 'PAID', SYSDATE);

INSERT INTO payment (payment_id, booking_id, amount, payment_method, payment_status, paid_at)
VALUES (900, 900, 250, 'CASH', 'SUCCESS', SYSDATE);

INSERT INTO payment (payment_id, booking_id, amount, payment_method, payment_status)
VALUES (900, 900, 250, 'UPI', 'SUCCESS');

INSERT INTO payment (payment_id, booking_id, amount, payment_method, payment_status, paid_at)
VALUES (900, 900, 250, 'UPI', 'SUCCESS', SYSDATE);

UPDATE booking SET status = 'CONFIRMED' WHERE booking_id = 900;

INSERT INTO payment (payment_id, booking_id, amount, payment_method, payment_status, paid_at)
VALUES (901, 900, 250, 'CARD', 'SUCCESS', SYSDATE);

SELECT seat_label, seat_status FROM show_seat_status WHERE show_id = 1 AND seat_row = 'A';

ROLLBACK TO SAVEPOINT after_valid_seat;

SELECT booking_id, status FROM booking WHERE booking_id = 900;
SELECT COUNT(*) AS payments_for_900 FROM payment WHERE booking_id = 900;

ROLLBACK;

SELECT COUNT(*) AS booking_900_rows FROM booking WHERE booking_id = 900;
