import { Router } from 'express';
import { query } from '../db.js';
import { ApiError } from '../errors.js';
import { ah, id, opt, DT } from '../util.js';

const router = Router();

router.get('/', ah(async (req, res) => {
  const movieId = req.query.movieId ? id(req.query.movieId, 'movieId') : null;
  res.json(await query(
    `SELECT show_id, theatre_name, city, screen_no, screen_type,
            movie_id, title, movie_language, certificate,
            TO_CHAR(show_start, ${DT}) AS show_start, base_price,
            seats_left(show_id) AS seats_left
     FROM   theatre_show_schedule
     WHERE  show_start > SYSDATE
     AND    (:city IS NULL OR city = :city)
     AND    (:showDate IS NULL OR TRUNC(show_start) = TO_DATE(:showDate, 'YYYY-MM-DD'))
     AND    (:movieId IS NULL OR movie_id = :movieId)
     ORDER  BY show_start, theatre_name`,
    { city: opt(req.query.city), showDate: opt(req.query.date), movieId }));
}));

router.get('/:id', ah(async (req, res) => {
  const showId = id(req.params.id, 'show id');
  const [show] = await query(
    `SELECT show_id, theatre_name, city, screen_no, screen_type, movie_id, title,
            movie_language, certificate, TO_CHAR(show_start, ${DT}) AS show_start, base_price,
            CASE WHEN show_start > SYSDATE THEN 0 ELSE 1 END AS started
     FROM   theatre_show_schedule
     WHERE  show_id = :showId`, { showId });
  if (!show) throw new ApiError(404, 'Show not found.');

  const seats = await query(
    `SELECT seat_id, seat_row, seat_number, seat_label, seat_type, seat_price, seat_status
     FROM   show_seat_status
     WHERE  show_id = :showId
     ORDER  BY seat_row, seat_number`, { showId });

  res.json({ ...show, seats });
}));

export default router;
