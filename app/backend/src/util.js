import { ApiError } from './errors.js';

export const ah = (fn) => (req, res, next) => fn(req, res, next).catch(next);

export function id(value, name) {
  const n = Number(value);
  if (!Number.isInteger(n) || n <= 0) throw new ApiError(400, `${name} must be a positive whole number.`);
  return n;
}

export const opt = (value) => (value === undefined || value === '' ? null : String(value));

export const DT = `'YYYY-MM-DD"T"HH24:MI'`;

export const num = (value) => {
  const n = Number(value);
  return value === '' || value === undefined || value === null || !Number.isFinite(n) ? null : n;
};
