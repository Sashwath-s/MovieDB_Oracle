SELECT title, movie_language, duration_min
FROM   movie;

SELECT title, duration_min
FROM   movie
WHERE  movie_language = 'Telugu'
AND    duration_min > 150;

SELECT title, TO_CHAR(release_date, 'DD-Mon-YYYY') AS released
FROM   movie
ORDER  BY release_date DESC;

SELECT user_id, movie_id, rating
FROM   review
WHERE  review_text IS NULL
AND    rating >= 4;

SELECT u.username, m.title, r.rating, r.review_text
FROM   review r
JOIN   app_user u ON u.user_id  = r.user_id
JOIN   movie    m ON m.movie_id = r.movie_id
ORDER  BY m.title, r.rating DESC;

SELECT m.title, COUNT(r.user_id) AS review_count
FROM   movie m
LEFT   JOIN review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
ORDER  BY review_count DESC, m.title;

SELECT g.genre_name, COUNT(mg.movie_id) AS movie_count
FROM   genre g
LEFT   JOIN movie_genre mg ON mg.genre_id = g.genre_id
GROUP  BY g.genre_name
ORDER  BY movie_count DESC;

SELECT m.title
FROM   movie m
LEFT   JOIN movie_actor ma ON ma.movie_id = m.movie_id
WHERE  ma.movie_id IS NULL;

SELECT t.theatre_name, t.city, sc.screen_no, sc.screen_type, m.title,
       TO_CHAR(sh.show_start, 'DD-Mon HH24:MI') AS show_time, sh.base_price
FROM   movie_show sh
JOIN   movie   m  ON m.movie_id    = sh.movie_id
JOIN   screen  sc ON sc.screen_id  = sh.screen_id
JOIN   theatre t  ON t.theatre_id  = sc.theatre_id
ORDER  BY sh.show_start;

SELECT DISTINCT t.theatre_name, t.city
FROM   theatre t
JOIN   screen     sc ON sc.theatre_id = t.theatre_id
JOIN   movie_show sh ON sh.screen_id  = sc.screen_id
JOIN   movie      m  ON m.movie_id    = sh.movie_id
WHERE  m.title = 'RRR';

SELECT b.booking_id, m.title, t.theatre_name,
       TO_CHAR(sh.show_start, 'DD-Mon HH24:MI') AS show_time,
       st.seat_row || st.seat_number AS seat, bs.price_paid
FROM   app_user u
JOIN   booking      b  ON b.user_id     = u.user_id
JOIN   booking_seat bs ON bs.booking_id = b.booking_id
JOIN   seat         st ON st.seat_id    = bs.seat_id
JOIN   movie_show   sh ON sh.show_id    = b.show_id
JOIN   movie        m  ON m.movie_id    = sh.movie_id
JOIN   screen       sc ON sc.screen_id  = sh.screen_id
JOIN   theatre      t  ON t.theatre_id  = sc.theatre_id
WHERE  u.username = 'aarav_k'
ORDER  BY b.booking_id, seat;

SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating, COUNT(*) AS reviews
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING AVG(r.rating) > 4
ORDER  BY avg_rating DESC;

SELECT m.title, COUNT(*) AS genre_count
FROM   movie m
JOIN   movie_genre mg ON mg.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING COUNT(*) > 2;

SELECT u.username, COUNT(*) AS reviews_written
FROM   app_user u
JOIN   review r ON r.user_id = u.user_id
GROUP  BY u.user_id, u.username
HAVING COUNT(*) > 3
ORDER  BY reviews_written DESC;

SELECT t.theatre_name, COUNT(*) AS screens
FROM   theatre t
JOIN   screen sc ON sc.theatre_id = t.theatre_id
GROUP  BY t.theatre_id, t.theatre_name
HAVING COUNT(*) > 2;

SELECT m.title, MAX(r.rating) AS highest, MIN(r.rating) AS lowest,
       MAX(r.rating) - MIN(r.rating) AS spread
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
ORDER  BY spread DESC;

SELECT u.username, SUM(bs.price_paid) AS total_spent
FROM   app_user u
JOIN   booking      b  ON b.user_id     = u.user_id
JOIN   booking_seat bs ON bs.booking_id = b.booking_id
WHERE  b.status = 'CONFIRMED'
GROUP  BY u.user_id, u.username
HAVING SUM(bs.price_paid) > 800
ORDER  BY total_spent DESC;

SELECT a.actor_name, COUNT(*) AS movies
FROM   actor a
JOIN   movie_actor ma ON ma.actor_id = a.actor_id
GROUP  BY a.actor_id, a.actor_name
HAVING COUNT(*) > 2;

SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING AVG(r.rating) > (SELECT AVG(rating) FROM review);

SELECT m.title, COUNT(*) AS review_count
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM review GROUP BY movie_id);

SELECT username
FROM   app_user
WHERE  user_id IN (SELECT b.user_id
                   FROM   booking b
                   WHERE  b.status = 'CONFIRMED'
                   AND    b.show_id IN (SELECT sh.show_id
                                        FROM   movie_show sh
                                        JOIN   screen  sc ON sc.screen_id = sh.screen_id
                                        JOIN   theatre t  ON t.theatre_id = sc.theatre_id
                                        WHERE  t.theatre_name = 'Cineplex Central'));

SELECT m.title, m.movie_language, m.duration_min
FROM   movie m
WHERE  m.duration_min > (SELECT AVG(m2.duration_min)
                         FROM   movie m2
                         WHERE  m2.movie_language = m.movie_language);

SELECT u.username, m.title, r.rating
FROM   review r
JOIN   app_user u ON u.user_id  = r.user_id
JOIN   movie    m ON m.movie_id = r.movie_id
WHERE  r.rating = (SELECT MAX(r2.rating)
                   FROM   review r2
                   WHERE  r2.user_id = r.user_id)
ORDER  BY u.username;

SELECT sh.show_id, t.theatre_name,
       TO_CHAR(sh.show_start, 'DD-Mon HH24:MI') AS show_time,
       (SELECT COUNT(*) FROM seat st WHERE st.screen_id = sh.screen_id)
     - (SELECT COUNT(*) FROM booking_seat bs WHERE bs.show_id = sh.show_id) AS seats_left
FROM   movie_show sh
JOIN   movie   m  ON m.movie_id   = sh.movie_id
JOIN   screen  sc ON sc.screen_id = sh.screen_id
JOIN   theatre t  ON t.theatre_id = sc.theatre_id
WHERE  m.title = 'RRR'
ORDER  BY sh.show_start;

SELECT u.username
FROM   app_user u
WHERE  EXISTS (SELECT 1 FROM review r WHERE r.user_id = u.user_id);

SELECT m.title
FROM   movie m
WHERE  NOT EXISTS (SELECT 1 FROM review r WHERE r.movie_id = m.movie_id);

SELECT m.title
FROM   movie m
WHERE  NOT EXISTS (SELECT 1
                   FROM   movie_show sh
                   JOIN   booking b ON b.show_id = sh.show_id
                   WHERE  sh.movie_id = m.movie_id);

SELECT st.seat_row || st.seat_number AS seat, st.seat_type
FROM   movie_show sh
JOIN   seat st ON st.screen_id = sh.screen_id
WHERE  sh.show_id = 1
AND    NOT EXISTS (SELECT 1
                   FROM   booking_seat bs
                   WHERE  bs.show_id = sh.show_id
                   AND    bs.seat_id = st.seat_id)
ORDER  BY st.seat_row, st.seat_number;

SELECT u.username
FROM   app_user u
WHERE  NOT EXISTS (
         SELECT 1
         FROM   movie_genre mg
         JOIN   genre g ON g.genre_id = mg.genre_id
         WHERE  g.genre_name = 'Sci-Fi'
         AND    NOT EXISTS (SELECT 1
                            FROM   review r
                            WHERE  r.user_id  = u.user_id
                            AND    r.movie_id = mg.movie_id));

SELECT t.theatre_name
FROM   theatre t
WHERE  NOT EXISTS (
         SELECT 1
         FROM   movie_genre mg
         JOIN   genre g ON g.genre_id = mg.genre_id
         WHERE  g.genre_name = 'Sci-Fi'
         AND    NOT EXISTS (SELECT 1
                            FROM   movie_show sh
                            JOIN   screen sc ON sc.screen_id = sh.screen_id
                            WHERE  sc.theatre_id = t.theatre_id
                            AND    sh.movie_id   = mg.movie_id));

SELECT m.title,
       ROUND(AVG(r.rating), 2) AS avg_rating,
       CASE
         WHEN AVG(r.rating) IS NULL THEN 'Not rated yet'
         WHEN AVG(r.rating) >= 4.5  THEN 'Must watch'
         WHEN AVG(r.rating) >= 3.5  THEN 'Good'
         ELSE                            'Mixed reviews'
       END AS verdict
FROM   movie m
LEFT   JOIN review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
ORDER  BY avg_rating DESC NULLS LAST;

SELECT sh.show_id, m.title,
       COUNT(bs.seat_id) AS booked,
       (SELECT COUNT(*) FROM seat st WHERE st.screen_id = sh.screen_id) AS capacity,
       SUM(CASE WHEN st2.seat_type = 'PREMIUM' THEN 1 ELSE 0 END) AS premium_booked,
       CASE
         WHEN COUNT(bs.seat_id) = 0 THEN 'No bookings'
         WHEN COUNT(bs.seat_id) >= 6 THEN 'Filling fast'
         ELSE 'Available'
       END AS status_label
FROM   movie_show sh
JOIN   movie m ON m.movie_id = sh.movie_id
LEFT   JOIN booking_seat bs ON bs.show_id = sh.show_id
LEFT   JOIN seat st2        ON st2.seat_id = bs.seat_id
GROUP  BY sh.show_id, sh.screen_id, m.title
ORDER  BY sh.show_id;

SELECT city FROM app_user WHERE city IS NOT NULL
UNION
SELECT city FROM theatre
ORDER  BY 1;

SELECT u.username FROM app_user u JOIN review  r ON r.user_id = u.user_id
INTERSECT
SELECT u.username FROM app_user u JOIN booking b ON b.user_id = u.user_id;

SELECT user_id FROM review
MINUS
SELECT user_id FROM booking;

SELECT user_id FROM booking
MINUS
SELECT user_id FROM review;

SELECT movie_id FROM watchlist
INTERSECT
SELECT movie_id FROM movie_show
ORDER  BY 1;
