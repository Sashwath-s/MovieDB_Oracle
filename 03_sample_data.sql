-- =====================================================================
-- STEP 6 : SAMPLE DATA
-- Run AFTER 02_create_tables.sql. Parents are inserted before children.
-- The data is designed so that every query in 04_queries.sql returns
-- something interesting (see "Built-in test cases" at the bottom).
-- =====================================================================

-- ---------------------------------------------------------------------
-- USERS (user 8 is new and has written no reviews)
-- ---------------------------------------------------------------------
INSERT INTO app_user VALUES (1, 'aarav_k',   'Aarav Kumar',  'aarav.k@example.com',   '9000000001', 'Hyderabad', DATE '2003-04-12', DATE '2025-01-10');
INSERT INTO app_user VALUES (2, 'priya_s',   'Priya Sharma', 'priya.s@example.com',   '9000000002', 'Hyderabad', DATE '2004-08-23', DATE '2025-02-14');
INSERT INTO app_user VALUES (3, 'rahul_v',   'Rahul Verma',  'rahul.v@example.com',   '9000000003', 'Bengaluru', DATE '2002-11-05', DATE '2025-03-01');
INSERT INTO app_user VALUES (4, 'sneha_r',   'Sneha Reddy',  'sneha.r@example.com',   '9000000004', 'Hyderabad', DATE '2003-01-30', DATE '2025-03-18');
INSERT INTO app_user VALUES (5, 'karthik_n', 'Karthik Nair', 'karthik.n@example.com', NULL,         'Chennai',   DATE '2001-06-17', DATE '2025-05-02');
INSERT INTO app_user VALUES (6, 'ananya_m',  'Ananya Menon', 'ananya.m@example.com',  '9000000006', 'Hyderabad', DATE '2004-02-09', DATE '2025-06-21');
INSERT INTO app_user VALUES (7, 'vikram_j',  'Vikram Joshi', 'vikram.j@example.com',  '9000000007', 'Mumbai',    DATE '2000-09-14', DATE '2025-07-07');
INSERT INTO app_user VALUES (8, 'divya_p',   'Divya Patel',  'divya.p@example.com',   NULL,         'Hyderabad', NULL,              DATE '2026-09-20');

-- ---------------------------------------------------------------------
-- MOVIES
-- ---------------------------------------------------------------------
INSERT INTO movie VALUES (1,  'Inception',                   DATE '2010-07-16', 148, 'English',  'UA', 'A thief enters dreams to plant an idea.');
INSERT INTO movie VALUES (2,  'Interstellar',                DATE '2014-11-07', 169, 'English',  'UA', 'Astronauts travel through a wormhole to save humanity.');
INSERT INTO movie VALUES (3,  'The Dark Knight',             DATE '2008-07-18', 152, 'English',  'UA', 'Batman faces the Joker in Gotham City.');
INSERT INTO movie VALUES (4,  'Oppenheimer',                 DATE '2023-07-21', 180, 'English',  'UA', 'The story of the father of the atomic bomb.');
INSERT INTO movie VALUES (5,  'Parasite',                    DATE '2019-05-30', 132, 'Korean',   'A',  'A poor family infiltrates a wealthy household.');
INSERT INTO movie VALUES (6,  'Spirited Away',               DATE '2001-07-20', 125, 'Japanese', 'U',  'A girl is trapped in a world of spirits.');
INSERT INTO movie VALUES (7,  '3 Idiots',                    DATE '2009-12-25', 170, 'Hindi',    'U',  'Three engineering students question the education system.');
INSERT INTO movie VALUES (8,  'Dangal',                      DATE '2016-12-23', 161, 'Hindi',    'U',  'A former wrestler trains his daughters.');
INSERT INTO movie VALUES (9,  'Andhadhun',                   DATE '2018-10-05', 139, 'Hindi',    'UA', 'A pianist pretending to be blind witnesses a murder.');
INSERT INTO movie VALUES (10, 'Baahubali 2: The Conclusion', DATE '2017-04-28', 167, 'Telugu',   'UA', 'The answer to why Kattappa killed Baahubali.');
INSERT INTO movie VALUES (11, 'RRR',                         DATE '2022-03-25', 187, 'Telugu',   'UA', 'Two revolutionaries form an unlikely friendship.');
INSERT INTO movie VALUES (12, 'Eega',                        DATE '2012-07-06', 134, 'Telugu',   'U',  'A murdered man is reborn as a housefly seeking revenge.');

-- ---------------------------------------------------------------------
-- GENRES (Romance has no movies -> useful for LEFT JOIN demo)
-- ---------------------------------------------------------------------
INSERT INTO genre VALUES (1, 'Action');
INSERT INTO genre VALUES (2, 'Drama');
INSERT INTO genre VALUES (3, 'Sci-Fi');
INSERT INTO genre VALUES (4, 'Thriller');
INSERT INTO genre VALUES (5, 'Comedy');
INSERT INTO genre VALUES (6, 'Animation');
INSERT INTO genre VALUES (7, 'Fantasy');
INSERT INTO genre VALUES (8, 'Biography');
INSERT INTO genre VALUES (9, 'Romance');

-- ---------------------------------------------------------------------
-- MOVIE_GENRE (every movie has 2-3 genres)
-- ---------------------------------------------------------------------
INSERT INTO movie_genre VALUES (1, 3);
INSERT INTO movie_genre VALUES (1, 1);
INSERT INTO movie_genre VALUES (1, 4);
INSERT INTO movie_genre VALUES (2, 3);
INSERT INTO movie_genre VALUES (2, 2);
INSERT INTO movie_genre VALUES (3, 1);
INSERT INTO movie_genre VALUES (3, 4);
INSERT INTO movie_genre VALUES (3, 2);
INSERT INTO movie_genre VALUES (4, 2);
INSERT INTO movie_genre VALUES (4, 8);
INSERT INTO movie_genre VALUES (5, 4);
INSERT INTO movie_genre VALUES (5, 2);
INSERT INTO movie_genre VALUES (5, 5);
INSERT INTO movie_genre VALUES (6, 6);
INSERT INTO movie_genre VALUES (6, 7);
INSERT INTO movie_genre VALUES (7, 5);
INSERT INTO movie_genre VALUES (7, 2);
INSERT INTO movie_genre VALUES (8, 2);
INSERT INTO movie_genre VALUES (8, 8);
INSERT INTO movie_genre VALUES (9, 4);
INSERT INTO movie_genre VALUES (9, 5);
INSERT INTO movie_genre VALUES (10, 1);
INSERT INTO movie_genre VALUES (10, 7);
INSERT INTO movie_genre VALUES (10, 2);
INSERT INTO movie_genre VALUES (11, 1);
INSERT INTO movie_genre VALUES (11, 2);
INSERT INTO movie_genre VALUES (12, 7);
INSERT INTO movie_genre VALUES (12, 1);

-- ---------------------------------------------------------------------
-- ACTORS
-- ---------------------------------------------------------------------
INSERT INTO actor VALUES (1,  'Leonardo DiCaprio',   'American');
INSERT INTO actor VALUES (2,  'Matthew McConaughey', 'American');
INSERT INTO actor VALUES (3,  'Christian Bale',      'British');
INSERT INTO actor VALUES (4,  'Cillian Murphy',      'Irish');
INSERT INTO actor VALUES (5,  'Song Kang-ho',        'South Korean');
INSERT INTO actor VALUES (6,  'Aamir Khan',          'Indian');
INSERT INTO actor VALUES (7,  'Ayushmann Khurrana',  'Indian');
INSERT INTO actor VALUES (8,  'Prabhas',             'Indian');
INSERT INTO actor VALUES (9,  'N. T. Rama Rao Jr.',  'Indian');
INSERT INTO actor VALUES (10, 'Ram Charan',          'Indian');
INSERT INTO actor VALUES (11, 'Anne Hathaway',       'American');
INSERT INTO actor VALUES (12, 'Michael Caine',       'British');
INSERT INTO actor VALUES (13, 'Nani',                'Indian');
INSERT INTO actor VALUES (14, 'Sudeep',              'Indian');

-- ---------------------------------------------------------------------
-- MOVIE_ACTOR (Spirited Away deliberately has no cast rows)
-- ---------------------------------------------------------------------
INSERT INTO movie_actor VALUES (1, 1,  'Cobb');
INSERT INTO movie_actor VALUES (1, 4,  'Robert Fischer');
INSERT INTO movie_actor VALUES (1, 12, 'Miles');
INSERT INTO movie_actor VALUES (2, 2,  'Cooper');
INSERT INTO movie_actor VALUES (2, 11, 'Brand');
INSERT INTO movie_actor VALUES (2, 12, 'Professor Brand');
INSERT INTO movie_actor VALUES (3, 3,  'Bruce Wayne');
INSERT INTO movie_actor VALUES (3, 4,  'Scarecrow');
INSERT INTO movie_actor VALUES (3, 12, 'Alfred');
INSERT INTO movie_actor VALUES (4, 4,  'J. Robert Oppenheimer');
INSERT INTO movie_actor VALUES (5, 5,  'Kim Ki-taek');
INSERT INTO movie_actor VALUES (7, 6,  'Rancho');
INSERT INTO movie_actor VALUES (8, 6,  'Mahavir Singh Phogat');
INSERT INTO movie_actor VALUES (9, 7,  'Akash');
INSERT INTO movie_actor VALUES (10, 8, 'Baahubali');
INSERT INTO movie_actor VALUES (11, 9, 'Komaram Bheem');
INSERT INTO movie_actor VALUES (11, 10,'Alluri Sitarama Raju');
INSERT INTO movie_actor VALUES (12, 13,'Nani');
INSERT INTO movie_actor VALUES (12, 14,'Sudeep');

-- ---------------------------------------------------------------------
-- REVIEWS (26 rows). Movie 12 (Eega) is never reviewed.
-- Some rows have NULL review_text = rating-only log.
-- ---------------------------------------------------------------------
INSERT INTO review VALUES (1, 1,  5.0, 'Mind-bending from start to finish.',        DATE '2025-02-01');
INSERT INTO review VALUES (1, 2,  4.5, 'The docking scene is unforgettable.',       DATE '2025-02-10');
INSERT INTO review VALUES (1, 3,  5.0, 'Best superhero film ever made.',            DATE '2025-03-05');
INSERT INTO review VALUES (1, 4,  4.0, NULL,                                        DATE '2025-04-12');
INSERT INTO review VALUES (1, 11, 4.5, 'Naatu Naatu alone is worth the ticket.',    DATE '2025-05-20');

INSERT INTO review VALUES (2, 1,  4.0, 'Great concept, a little confusing.',        DATE '2025-03-01');
INSERT INTO review VALUES (2, 2,  5.0, 'Made me cry in a cinema hall.',             DATE '2025-03-15');
INSERT INTO review VALUES (2, 7,  4.5, 'Funny and meaningful.',                     DATE '2025-04-02');
INSERT INTO review VALUES (2, 8,  4.0, NULL,                                        DATE '2025-04-20');
INSERT INTO review VALUES (2, 9,  4.5, 'The twists keep coming.',                   DATE '2025-06-11');

INSERT INTO review VALUES (3, 3,  4.5, 'Heath Ledger is incredible.',               DATE '2025-03-10');
INSERT INTO review VALUES (3, 4,  3.5, 'Brilliant but too long.',                   DATE '2025-05-01');
INSERT INTO review VALUES (3, 8,  4.5, 'Inspiring sports drama.',                   DATE '2025-05-18');
INSERT INTO review VALUES (3, 10, 3.0, NULL,                                        DATE '2025-07-22');

INSERT INTO review VALUES (4, 5,  5.0, 'A masterpiece about class.',                DATE '2025-04-01');
INSERT INTO review VALUES (4, 6,  5.0, 'Beautiful animation.',                      DATE '2025-04-15');
INSERT INTO review VALUES (4, 9,  4.0, NULL,                                        DATE '2025-06-30');

INSERT INTO review VALUES (5, 10, 4.0, 'Grand visuals.',                            DATE '2025-06-01');
INSERT INTO review VALUES (5, 11, 5.0, 'Pure cinema.',                              DATE '2025-06-05');
INSERT INTO review VALUES (5, 1,  3.5, NULL,                                        DATE '2025-06-20');
INSERT INTO review VALUES (5, 2,  4.0, 'Good science, slow middle.',                DATE '2025-07-02');

INSERT INTO review VALUES (6, 6,  4.5, 'Still magical on a rewatch.',               DATE '2025-07-10');
INSERT INTO review VALUES (6, 7,  5.0, 'All izz well!',                             DATE '2025-07-25');

INSERT INTO review VALUES (7, 3,  4.0, NULL,                                        DATE '2025-08-01');
INSERT INTO review VALUES (7, 5,  4.5, 'Genre-bending and sharp.',                  DATE '2025-08-14');
INSERT INTO review VALUES (7, 11, 2.5, 'Too over the top for me.',                  DATE '2025-09-03');

-- ---------------------------------------------------------------------
-- WATCHLIST (user 3 has movie 8 in watchlist AND has reviewed it)
-- ---------------------------------------------------------------------
INSERT INTO watchlist VALUES (1, 5,  DATE '2025-08-01');
INSERT INTO watchlist VALUES (1, 6,  DATE '2025-08-02');
INSERT INTO watchlist VALUES (1, 12, DATE '2025-08-05');
INSERT INTO watchlist VALUES (2, 3,  DATE '2025-08-10');
INSERT INTO watchlist VALUES (2, 11, DATE '2025-08-11');
INSERT INTO watchlist VALUES (3, 1,  DATE '2025-08-12');
INSERT INTO watchlist VALUES (3, 12, DATE '2025-08-15');
INSERT INTO watchlist VALUES (3, 8,  DATE '2025-04-01');
INSERT INTO watchlist VALUES (4, 11, DATE '2025-09-01');
INSERT INTO watchlist VALUES (4, 2,  DATE '2025-09-02');
INSERT INTO watchlist VALUES (6, 1,  DATE '2025-09-05');
INSERT INTO watchlist VALUES (6, 10, DATE '2025-09-06');
INSERT INTO watchlist VALUES (7, 12, DATE '2025-09-10');
INSERT INTO watchlist VALUES (8, 11, DATE '2026-09-21');
INSERT INTO watchlist VALUES (8, 4,  DATE '2026-09-22');

-- ---------------------------------------------------------------------
-- THEATRES (fictional names)
-- ---------------------------------------------------------------------
INSERT INTO theatre VALUES (1, 'Cineplex Central',   'Hyderabad', 'Ameerpet Main Road');
INSERT INTO theatre VALUES (2, 'Starlight Multiplex', 'Hyderabad', 'Gachibowli, Financial District');
INSERT INTO theatre VALUES (3, 'Royal Talkies',      'Hyderabad', 'Kukatpally Housing Board');
INSERT INTO theatre VALUES (4, 'Orion Screens',      'Bengaluru', 'Koramangala 5th Block');

-- ---------------------------------------------------------------------
-- SCREENS (theatre 1 has 3 screens, theatre 2 has 2, others have 1)
-- ---------------------------------------------------------------------
INSERT INTO screen VALUES (1, 1, 1, 'IMAX');
INSERT INTO screen VALUES (2, 1, 2, '2D');
INSERT INTO screen VALUES (3, 1, 3, '3D');
INSERT INTO screen VALUES (4, 2, 1, '2D');
INSERT INTO screen VALUES (5, 2, 2, '2D');
INSERT INTO screen VALUES (6, 3, 1, '2D');
INSERT INTO screen VALUES (7, 4, 1, '2D');

-- ---------------------------------------------------------------------
-- SEATS: every screen gets rows A, B, C with seats 1-4 (12 seats/screen,
-- 84 seats total). Row C is PREMIUM.
-- seat_id = screen_id*100 + position, e.g. screen 1: A1=101 ... C4=112
--   Row A -> x01..x04, Row B -> x05..x08, Row C -> x09..x12
-- A small anonymous PL/SQL block avoids writing 84 INSERT statements.
-- ---------------------------------------------------------------------
BEGIN
  FOR s IN 1 .. 7 LOOP
    FOR r IN 1 .. 3 LOOP
      FOR n IN 1 .. 4 LOOP
        INSERT INTO seat (seat_id, screen_id, seat_row, seat_number, seat_type)
        VALUES (s * 100 + (r - 1) * 4 + n,
                s,
                CHR(64 + r),                          -- 65 = 'A'
                n,
                CASE WHEN r = 3 THEN 'PREMIUM' ELSE 'REGULAR' END);
      END LOOP;
    END LOOP;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- SHOWS (Premium seat price = base_price + 100)
-- ---------------------------------------------------------------------
INSERT INTO movie_show VALUES (1,  11, 1, TO_DATE('2026-10-02 18:30','YYYY-MM-DD HH24:MI'), 250);
INSERT INTO movie_show VALUES (2,  11, 4, TO_DATE('2026-10-02 21:00','YYYY-MM-DD HH24:MI'), 200);
INSERT INTO movie_show VALUES (3,  1,  1, TO_DATE('2026-10-03 14:00','YYYY-MM-DD HH24:MI'), 300);
INSERT INTO movie_show VALUES (4,  2,  1, TO_DATE('2026-10-03 18:00','YYYY-MM-DD HH24:MI'), 300);
INSERT INTO movie_show VALUES (5,  2,  2, TO_DATE('2026-10-03 18:00','YYYY-MM-DD HH24:MI'), 200);
INSERT INTO movie_show VALUES (6,  10, 3, TO_DATE('2026-10-04 11:00','YYYY-MM-DD HH24:MI'), 180);
INSERT INTO movie_show VALUES (7,  4,  5, TO_DATE('2026-10-04 15:00','YYYY-MM-DD HH24:MI'), 220);
INSERT INTO movie_show VALUES (8,  7,  6, TO_DATE('2026-10-04 19:00','YYYY-MM-DD HH24:MI'), 150);
INSERT INTO movie_show VALUES (9,  11, 7, TO_DATE('2026-10-05 20:00','YYYY-MM-DD HH24:MI'), 220);
INSERT INTO movie_show VALUES (10, 9,  2, TO_DATE('2026-10-05 13:00','YYYY-MM-DD HH24:MI'), 180);
INSERT INTO movie_show VALUES (11, 6,  6, TO_DATE('2026-10-05 10:00','YYYY-MM-DD HH24:MI'), 150);
INSERT INTO movie_show VALUES (12, 12, 4, TO_DATE('2026-10-06 12:00','YYYY-MM-DD HH24:MI'), 160);

-- ---------------------------------------------------------------------
-- BOOKINGS
-- ---------------------------------------------------------------------
INSERT INTO booking VALUES (1,  1, 1,  TO_DATE('2026-09-25 10:15','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (2,  2, 1,  TO_DATE('2026-09-25 11:40','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (3,  3, 4,  TO_DATE('2026-09-26 09:05','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (4,  5, 9,  TO_DATE('2026-09-26 13:30','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (5,  4, 2,  TO_DATE('2026-09-26 18:45','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (6,  8, 8,  TO_DATE('2026-09-27 08:20','YYYY-MM-DD HH24:MI'), 'PENDING');
INSERT INTO booking VALUES (7,  7, 3,  TO_DATE('2026-09-27 12:00','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (8,  1, 6,  TO_DATE('2026-09-27 16:10','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (9,  2, 7,  TO_DATE('2026-09-27 19:30','YYYY-MM-DD HH24:MI'), 'CANCELLED');
INSERT INTO booking VALUES (10, 8, 5,  TO_DATE('2026-09-28 10:00','YYYY-MM-DD HH24:MI'), 'CANCELLED');
INSERT INTO booking VALUES (11, 3, 10, TO_DATE('2026-09-28 14:25','YYYY-MM-DD HH24:MI'), 'CONFIRMED');
INSERT INTO booking VALUES (12, 4, 1,  TO_DATE('2026-09-28 20:50','YYYY-MM-DD HH24:MI'), 'CONFIRMED');

-- ---------------------------------------------------------------------
-- BOOKING_SEAT (booking_id, show_id, seat_id, price_paid)
-- Cancelled bookings 9 and 10 have no seats (seats were released).
-- ---------------------------------------------------------------------
INSERT INTO booking_seat VALUES (1,  1,  105, 250)   /* B1 */;
INSERT INTO booking_seat VALUES (1,  1,  106, 250)   /* B2 */;
INSERT INTO booking_seat VALUES (2,  1,  109, 350)   /* C1 premium */;
INSERT INTO booking_seat VALUES (2,  1,  110, 350)   /* C2 premium */;
INSERT INTO booking_seat VALUES (3,  4,  101, 300);
INSERT INTO booking_seat VALUES (3,  4,  102, 300);
INSERT INTO booking_seat VALUES (3,  4,  103, 300);
INSERT INTO booking_seat VALUES (4,  9,  701, 220);
INSERT INTO booking_seat VALUES (4,  9,  702, 220);
INSERT INTO booking_seat VALUES (5,  2,  409, 300)   /* premium */;
INSERT INTO booking_seat VALUES (6,  8,  605, 150);
INSERT INTO booking_seat VALUES (6,  8,  606, 150);
INSERT INTO booking_seat VALUES (7,  3,  111, 400)   /* premium */;
INSERT INTO booking_seat VALUES (7,  3,  112, 400)   /* premium */;
INSERT INTO booking_seat VALUES (8,  6,  305, 180);
INSERT INTO booking_seat VALUES (8,  6,  306, 180);
INSERT INTO booking_seat VALUES (8,  6,  307, 180);
INSERT INTO booking_seat VALUES (8,  6,  308, 180);
INSERT INTO booking_seat VALUES (11, 10, 209, 280)   /* premium */;
INSERT INTO booking_seat VALUES (12, 1,  107, 250);
INSERT INTO booking_seat VALUES (12, 1,  108, 250);

-- ---------------------------------------------------------------------
-- PAYMENTS (one per booking)
-- ---------------------------------------------------------------------
INSERT INTO payment VALUES (1,  1,  500, 'UPI',        'SUCCESS',  TO_DATE('2026-09-25 10:16','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (2,  2,  700, 'CARD',       'SUCCESS',  TO_DATE('2026-09-25 11:42','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (3,  3,  900, 'UPI',        'SUCCESS',  TO_DATE('2026-09-26 09:06','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (4,  4,  440, 'UPI',        'SUCCESS',  TO_DATE('2026-09-26 13:31','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (5,  5,  300, 'WALLET',     'SUCCESS',  TO_DATE('2026-09-26 18:46','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (6,  6,  300, 'UPI',        'PENDING',  NULL);
INSERT INTO payment VALUES (7,  7,  800, 'CARD',       'SUCCESS',  TO_DATE('2026-09-27 12:02','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (8,  8,  720, 'NETBANKING', 'SUCCESS',  TO_DATE('2026-09-27 16:12','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (9,  9,  220, 'CARD',       'REFUNDED', TO_DATE('2026-09-27 19:31','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (10, 10, 400, 'CARD',       'FAILED',   NULL);
INSERT INTO payment VALUES (11, 11, 280, 'UPI',        'SUCCESS',  TO_DATE('2026-09-28 14:26','YYYY-MM-DD HH24:MI'));
INSERT INTO payment VALUES (12, 12, 500, 'WALLET',     'SUCCESS',  TO_DATE('2026-09-28 20:51','YYYY-MM-DD HH24:MI'));

COMMIT;

-- ---------------------------------------------------------------------
-- Row counts (expected in brackets)
-- ---------------------------------------------------------------------
SELECT 'APP_USER' tbl, COUNT(*) cnt FROM app_user        -- 8
UNION ALL SELECT 'MOVIE',        COUNT(*) FROM movie        -- 12
UNION ALL SELECT 'GENRE',        COUNT(*) FROM genre        -- 9
UNION ALL SELECT 'MOVIE_GENRE',  COUNT(*) FROM movie_genre  -- 28
UNION ALL SELECT 'ACTOR',        COUNT(*) FROM actor        -- 14
UNION ALL SELECT 'MOVIE_ACTOR',  COUNT(*) FROM movie_actor  -- 19
UNION ALL SELECT 'REVIEW',       COUNT(*) FROM review       -- 26
UNION ALL SELECT 'WATCHLIST',    COUNT(*) FROM watchlist    -- 15
UNION ALL SELECT 'THEATRE',      COUNT(*) FROM theatre      -- 4
UNION ALL SELECT 'SCREEN',       COUNT(*) FROM screen       -- 7
UNION ALL SELECT 'SEAT',         COUNT(*) FROM seat         -- 84
UNION ALL SELECT 'MOVIE_SHOW',   COUNT(*) FROM movie_show   -- 12
UNION ALL SELECT 'BOOKING',      COUNT(*) FROM booking      -- 12
UNION ALL SELECT 'BOOKING_SEAT', COUNT(*) FROM booking_seat -- 21
UNION ALL SELECT 'PAYMENT',      COUNT(*) FROM payment     /* 12 */;

-- ---------------------------------------------------------------------
-- Built-in test cases (so you know what the queries should show)
--  * Eega (12): never reviewed, never booked
--  * Spirited Away (6): has a show but no bookings, and no cast rows
--  * Romance genre: no movies
--  * divya_p (8): booked but never reviewed
--  * ananya_m (6): reviewed but never booked
--  * aarav_k, priya_s, karthik_n: reviewed every Sci-Fi movie
--  * RRR average rating is exactly 4.0 (boundary case for "> 4")
--  * Cineplex Central: the only theatre with more than 2 screens
--  * Show 1 (RRR, IMAX): 6 of 12 seats booked
-- ---------------------------------------------------------------------
