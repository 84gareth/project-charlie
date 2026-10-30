// Belt-scroller walking, as pure maths: left and right along the street,
// up and down across it (slower, like Rita's Rewind), never leaving the
// walkable part of the street.
import { keepIn } from "./layout.js";

// World units per second. Across the street is slower than along it.
export const SPEED = { x: 420, y: 260 };

// A direction no longer than 1 (a stick pushed into a corner, or two
// keys at once, doesn't go faster).
export function limit(dir) {
  const len = Math.hypot(dir.x, dir.y);
  return len > 1 ? { x: dir.x / len, y: dir.y / len } : { x: dir.x, y: dir.y };
}

// Where the hero's feet end up after walking `dir` for `dt` seconds.
export function step(pos, dir, dt, area) {
  const d = limit(dir);
  return keepIn({ x: pos.x + d.x * SPEED.x * dt, y: pos.y + d.y * SPEED.y * dt }, area);
}

// Which way the hero faces: 1 is right, -1 is left. Walking straight up or
// down keeps the old facing.
export function facing(current, dirX) {
  if (dirX > 0.1) return 1;
  if (dirX < -0.1) return -1;
  return current;
}
