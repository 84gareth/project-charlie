// Where each wave of baddies comes from: just off-screen, from both sides
// when there's room, never off the ends of the street (carried over from
// the Godot game's waves.gd). A wave is one of each of Charlie's bugs.
import { clamp } from "./layout.js";
import { KINDS } from "./baddies.js";

export const SIZE = 3;
// Well past the edge of the widest view the iPad shows (about 1400 across
// held sideways), so they walk in from out of sight.
export const OFFSCREEN = 950;
// Playtest "fight" mode: the first wave starts this close, in view.
export const CLOSE = 450;
// Up-and-down offsets, so a wave spreads across the street.
export const LANES = [-35, 0, 35];
// Seconds between beating a wave and the next one arriving.
export const PAUSE = 1.5;

// `startDist` is how far from the hero the nearest one starts.
export function spawnPoints(heroX, area, count = SIZE, startDist = OFFSCREEN) {
  const out = [];
  const midY = area.y + area.h / 2;
  for (let i = 0; i < count; i++) {
    const side = i % 2 === 0 ? 1 : -1;
    const dist = startDist + i * 60;
    let x = heroX + side * dist;
    if (x < area.x || x > area.x + area.w) x = heroX - side * dist;
    out.push({ x: clamp(x, area.x, area.x + area.w), y: midY + lane(i) });
  }
  return out;
}

// The lane a baddie keeps while chasing.
export const lane = (i) => LANES[i % LANES.length];
// Which bug comes in place `i` of a wave.
export const kind = (i) => KINDS[i % KINDS.length];
