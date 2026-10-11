-- =====================================================================
-- STEP 7 : SQL QUERY SET
-- Each query: the question, the concept it demonstrates, and the
-- expected result on the sample data (so you can verify it quickly).
-- =====================================================================


-- =====================================================================
-- A. BASIC SELECT, WHERE, ORDER BY
-- =====================================================================

-- Q1. [Basic SELECT] List every movie with its language and running time.
SELECT title, movie_language, duration_min
FROM   movie;

-- Q2. [WHERE] Telugu movies longer than 2.5 hours.
-- Expected: Baahubali 2, RRR
SELECT title, duration_min
FROM   movie
WHERE  movie_language = 'Telugu'
AND    duration_min > 150;

-- Q3. [ORDER BY, date formatting] Movies from newest to oldest.
SELECT title, TO_CHAR(release_date, 'DD-Mon-YYYY') AS released
FROM   movie
ORDER  BY release_date DESC;

-- Q4. [WHERE with IS NULL and AND] Rating-only logs (no review text)
--     with ratings of 4 or more.
SELECT user_id, movie_id, rating
FROM   review
WHERE  review_text IS NULL
AND    rating >= 4;


-- =====================================================================
-- B. JOINS
-- =====================================================================

-- Q5. [INNER JOIN] Show every review with the reviewer's username and
--     the movie title.
SELECT u.username, m.title, r.rating, r.review_text
FROM   review r
JOIN   app_user u ON u.user_id  = r.user_id
JOIN   movie    m ON m.movie_id = r.movie_id
ORDER  BY m.title, r.rating DESC;

-- Q6. [LEFT JOIN + COUNT] Number of reviews for every movie, including
--     movies with zero reviews.
-- Expected: Eega shows 0. Note COUNT(r.user_id), not COUNT(*): COUNT(*)
-- would count the NULL-padded row and wrongly give Eega 1.
SELECT m.title, COUNT(r.user_id) AS review_count
FROM   movie m
LEFT   JOIN review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
ORDER  BY review_count DESC, m.title;

-- Q7. [LEFT JOIN] Number of movies in each genre, including empty genres.
-- Expected: Drama 8, Action 5, Thriller 4, ... Romance 0
SELECT g.genre_name, COUNT(mg.movie_id) AS movie_count
FROM   genre g
LEFT   JOIN movie_genre mg ON mg.genre_id = g.genre_id
GROUP  BY g.genre_name
ORDER  BY movie_count DESC;

-- Q8. [LEFT JOIN, finding "missing" rows] Movies with no cast recorded.
-- Expected: Spirited Away
SELECT m.title
FROM   movie m
LEFT   JOIN movie_actor ma ON ma.movie_id = m.movie_id
WHERE  ma.movie_id IS NULL;

-- Q9. [Multi-table join: 4 tables] Full show schedule.
SELECT t.theatre_name, t.city, sc.screen_no, sc.screen_type, m.title,
       TO_CHAR(sh.show_start, 'DD-Mon HH24:MI') AS show_time, sh.base_price
FROM   movie_show sh
JOIN   movie   m  ON m.movie_id    = sh.movie_id
JOIN   screen  sc ON sc.screen_id  = sh.screen_id
JOIN   theatre t  ON t.theatre_id  = sc.theatre_id
ORDER  BY sh.show_start;

-- Q10. [Multi-table join + DISTINCT] Theatres showing RRR.
-- Expected: Cineplex Central, Starlight Multiplex, Orion Screens
SELECT DISTINCT t.theatre_name, t.city
FROM   theatre t
JOIN   screen     sc ON sc.theatre_id = t.theatre_id
JOIN   movie_show sh ON sh.screen_id  = sc.screen_id
JOIN   movie      m  ON m.movie_id    = sh.movie_id
WHERE  m.title = 'RRR';

-- Q11. [Multi-table join: 6 tables] Ticket details of one user (aarav_k):
--      movie, theatre, time and seat labels.
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


-- =====================================================================
-- C. AGGREGATES, GROUP BY, HAVING
-- =====================================================================

-- Q12. [GROUP BY + AVG + HAVING] Movies with average rating above 4.
-- Expected: 8 movies. RRR (exactly 4.0) is NOT included.
SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating, COUNT(*) AS reviews
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING AVG(r.rating) > 4
ORDER  BY avg_rating DESC;

-- Q13. [GROUP BY + HAVING] Movies belonging to more than two genres.
-- (Every movie in our data has at least two genres, so "> 1" returns all
--  12 rows; "> 2" is more interesting.)
-- Expected: Inception, The Dark Knight, Parasite, Baahubali 2
SELECT m.title, COUNT(*) AS genre_count
FROM   movie m
JOIN   movie_genre mg ON mg.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING COUNT(*) > 2;

-- Q14. [HAVING] Users who have reviewed more than 3 movies.
-- Expected: aarav_k 5, priya_s 5, rahul_v 4, karthik_n 4
SELECT u.username, COUNT(*) AS reviews_written
FROM   app_user u
JOIN   review r ON r.user_id = u.user_id
GROUP  BY u.user_id, u.username
HAVING COUNT(*) > 3
ORDER  BY reviews_written DESC;

-- Q15. [HAVING] Theatres having more than 2 screens.
-- Expected: Cineplex Central (3)
SELECT t.theatre_name, COUNT(*) AS screens
FROM   theatre t
JOIN   screen sc ON sc.theatre_id = t.theatre_id
GROUP  BY t.theatre_id, t.theatre_name
HAVING COUNT(*) > 2;

-- Q16. [MAX / MIN] Highest and lowest rating each movie received.
SELECT m.title, MAX(r.rating) AS highest, MIN(r.rating) AS lowest,
       MAX(r.rating) - MIN(r.rating) AS spread
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
ORDER  BY spread DESC;

-- Q17. [GROUP BY + SUM + HAVING] Users whose confirmed bookings total
--      more than Rs 800.
-- Expected: aarav_k 1220, rahul_v 1180
SELECT u.username, SUM(bs.price_paid) AS total_spent
FROM   app_user u
JOIN   booking      b  ON b.user_id     = u.user_id
JOIN   booking_seat bs ON bs.booking_id = b.booking_id
WHERE  b.status = 'CONFIRMED'
GROUP  BY u.user_id, u.username
HAVING SUM(bs.price_paid) > 800
ORDER  BY total_spent DESC;

-- Q18. [GROUP BY on two columns] Actors who appear in more than 2 movies.
-- Expected: Cillian Murphy 3, Michael Caine 3
SELECT a.actor_name, COUNT(*) AS movies
FROM   actor a
JOIN   movie_actor ma ON ma.actor_id = a.actor_id
GROUP  BY a.actor_id, a.actor_name
HAVING COUNT(*) > 2;


-- =====================================================================
-- D. SUBQUERIES
-- =====================================================================

-- Q19. [Subquery in HAVING] Movies rated above the overall average
--      rating of all reviews (overall average is about 4.29).
-- Expected: Interstellar, The Dark Knight, Parasite, Spirited Away, 3 Idiots
SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING AVG(r.rating) > (SELECT AVG(rating) FROM review);

-- Q20. [Nested aggregate in subquery] The most reviewed movie(s).
-- Expected: Inception, Interstellar, The Dark Knight, RRR (3 reviews each)
SELECT m.title, COUNT(*) AS review_count
FROM   movie m
JOIN   review r ON r.movie_id = m.movie_id
GROUP  BY m.movie_id, m.title
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM review GROUP BY movie_id);

-- Q21. [Nested IN subqueries] Users who have booked at Cineplex Central
--      (confirmed bookings only).
-- Expected: aarav_k, priya_s, rahul_v, sneha_r, vikram_j
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

-- Q22. [Correlated subquery] Movies longer than the average length of
--      movies in the SAME language.
-- Expected: Interstellar, Oppenheimer, 3 Idiots, Dangal, Baahubali 2, RRR
SELECT m.title, m.movie_language, m.duration_min
FROM   movie m
WHERE  m.duration_min > (SELECT AVG(m2.duration_min)
                         FROM   movie m2
                         WHERE  m2.movie_language = m.movie_language);

-- Q23. [Correlated subquery] Each user's highest-rated movie(s).
SELECT u.username, m.title, r.rating
FROM   review r
JOIN   app_user u ON u.user_id  = r.user_id
JOIN   movie    m ON m.movie_id = r.movie_id
WHERE  r.rating = (SELECT MAX(r2.rating)
                   FROM   review r2
                   WHERE  r2.user_id = r.user_id)
ORDER  BY u.username;

-- Q24. [Correlated scalar subqueries in SELECT] Upcoming RRR shows with
--      the number of seats still available.
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


-- =====================================================================
-- E. EXISTS, NOT EXISTS, DOUBLE NOT EXISTS
-- =====================================================================

-- Q25. [EXISTS] Users who have reviewed at least one movie.
-- Expected: users 1-7 (not divya_p)
SELECT u.username
FROM   app_user u
WHERE  EXISTS (SELECT 1 FROM review r WHERE r.user_id = u.user_id);

-- Q26. [NOT EXISTS] Movies that have never been reviewed.
-- Expected: Eega
SELECT m.title
FROM   movie m
WHERE  NOT EXISTS (SELECT 1 FROM review r WHERE r.movie_id = m.movie_id);

-- Q27. [NOT EXISTS] Movies with no bookings at all (any status).
-- Expected: The Dark Knight, Parasite, Spirited Away, Dangal, Eega
SELECT m.title
FROM   movie m
WHERE  NOT EXISTS (SELECT 1
                   FROM   movie_show sh
                   JOIN   booking b ON b.show_id = sh.show_id
                   WHERE  sh.movie_id = m.movie_id);

-- Q28. [NOT EXISTS] Available seats for show 1 (RRR, IMAX, 02-Oct 18:30).
-- Expected: A1, A2, A3, A4, C3, C4
SELECT st.seat_row || st.seat_number AS seat, st.seat_type
FROM   movie_show sh
JOIN   seat st ON st.screen_id = sh.screen_id
WHERE  sh.show_id = 1
AND    NOT EXISTS (SELECT 1
                   FROM   booking_seat bs
                   WHERE  bs.show_id = sh.show_id
                   AND    bs.seat_id = st.seat_id)
ORDER  BY st.seat_row, st.seat_number;

-- Q29. [DOUBLE NOT EXISTS = relational division]
--      Users who have reviewed EVERY Sci-Fi movie.
-- Read it as: "there is no Sci-Fi movie that this user has not reviewed."
-- Expected: aarav_k, priya_s, karthik_n
-- Caution: for a genre with no movies (Romance) the outer NOT EXISTS is
-- vacuously true and EVERY user is returned. Worth mentioning in the viva.
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

-- Q30. [DOUBLE NOT EXISTS, second example] Theatres that are showing
--      EVERY Sci-Fi movie.
-- Read it as: "there is no Sci-Fi movie that this theatre does not show."
-- Expected: Cineplex Central (shows both Inception and Interstellar)
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


-- =====================================================================
-- F. CASE
-- =====================================================================

-- Q31. [CASE with LEFT JOIN] Label each movie by its average rating.
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

-- Q32. [CASE inside an aggregate] Occupancy of every show, with a label.
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


-- =====================================================================
-- G. SET OPERATORS: UNION, INTERSECT, MINUS
-- (Both sides must have the same number of columns with compatible types.)
-- =====================================================================

-- Q33. [UNION] Every city the platform is active in (users or theatres).
-- UNION removes duplicates; UNION ALL would keep them.
-- Expected: Bengaluru, Chennai, Hyderabad, Mumbai
SELECT city FROM app_user WHERE city IS NOT NULL
UNION
SELECT city FROM theatre
ORDER  BY 1;

-- Q34. [INTERSECT] Users who have both reviewed and booked.
-- Expected: aarav_k, priya_s, rahul_v, sneha_r, karthik_n, vikram_j
SELECT u.username FROM app_user u JOIN review  r ON r.user_id = u.user_id
INTERSECT
SELECT u.username FROM app_user u JOIN booking b ON b.user_id = u.user_id;

-- Q35. [MINUS] Users who review movies but have never booked a ticket.
-- Expected: ananya_m
SELECT user_id FROM review
MINUS
SELECT user_id FROM booking;

-- Q36. [MINUS] Users who book tickets but have never written a review.
-- Expected: 8 (divya_p)
SELECT user_id FROM booking
MINUS
SELECT user_id FROM review;

-- Q37. [INTERSECT] Watchlisted movies that are currently scheduled
--      (useful for "a movie on your watchlist is in theatres!").
-- Expected: movie_ids 1, 2, 4, 6, 10, 11, 12
SELECT movie_id FROM watchlist
INTERSECT
SELECT movie_id FROM movie_show
ORDER  BY 1;
