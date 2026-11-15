SET SERVEROUTPUT ON;

VARIABLE v_booking NUMBER;

SELECT get_seat_price(13, 101) AS regular_price,
       get_seat_price(13, 109) AS premium_price,
       seats_left(13)          AS seats_left,
       get_avg_rating(11)      AS rrr_avg_rating
FROM   dual;

BEGIN
  book_seats(p_user_id => 2, p_show_id => 13, p_seat_ids => '105,106,109',
             p_booking_id => :v_booking);
  make_payment(:v_booking, 'UPI');
END;
/

COMMIT;

SELECT booking_id, username, title, booking_status, seat_count, total_amount, payment_status
FROM   booking_summary
WHERE  booking_id = :v_booking;

SELECT seats_left(13) AS seats_left_after_booking FROM dual;

DECLARE
  v_id NUMBER;
BEGIN
  book_seats(1, 13, '107,105', v_id);
  DBMS_OUTPUT.PUT_LINE('Should not get here');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Booking failed: ' || SQLERRM);
END;
/

SELECT COUNT(*) AS aarav_bookings_show_13
FROM   booking
WHERE  user_id = 1 AND show_id = 13;

SELECT seat_label, seat_status
FROM   show_seat_status
WHERE  show_id = 13 AND seat_row = 'B' AND seat_number <= 4
ORDER  BY seat_number;

EXEC book_seats(1, 1, '101', :v_booking);

EXEC book_seats(1, 999, '101', :v_booking);

EXEC book_seats(1, 13, '', :v_booking);

EXEC book_seats(1, 13, '201', :v_booking);

EXEC book_seats(1, 13, '9999', :v_booking);

EXEC make_payment(9, 'UPI');

EXEC cancel_booking(1);

EXEC cancel_booking(12345);

EXEC book_seats(4, 13, '101,102', :v_booking);

SELECT seats_left(13) AS seats_left_uncommitted FROM dual;

EXEC make_payment(:v_booking, 'CASH');

SELECT booking_id, booking_status, seat_count, payment_status
FROM   booking_summary
WHERE  booking_id = :v_booking;

ROLLBACK;

SELECT seats_left(13) AS seats_left_after_rollback FROM dual;
SELECT COUNT(*) AS rows_for_rolled_back_booking FROM booking WHERE booking_id = :v_booking;

SELECT COUNT(*) AS rrr_on_divya_watchlist FROM watchlist WHERE user_id = 8 AND movie_id = 11;

EXEC save_review(8, 11, 4.5, 'Saw it in IMAX. Loud and glorious.');

SELECT COUNT(*) AS rrr_on_divya_watchlist FROM watchlist WHERE user_id = 8 AND movie_id = 11;

EXEC save_review(8, 11, 5, 'Rewatched. Even better.');

SELECT user_id, movie_id, rating, review_text FROM review WHERE user_id = 8 AND movie_id = 11;

SELECT get_avg_rating(11) AS rrr_avg_now FROM dual;

EXEC save_review(8, 4, 4.3);

ROLLBACK;

EXEC print_user_activity(2);

DECLARE
  v_id booking.booking_id%TYPE;
BEGIN
  SELECT MAX(booking_id) INTO v_id
  FROM   booking
  WHERE  user_id = 2 AND show_id = 13 AND status = 'CONFIRMED';

  cancel_booking(v_id);
END;
/

COMMIT;

SELECT booking_id, booking_status, seat_count, total_amount, amount_charged, payment_status
FROM   booking_summary
WHERE  username = 'priya_s' AND show_start > SYSDATE
ORDER  BY booking_id;

SELECT seats_left(13) AS seats_left_at_end FROM dual;
