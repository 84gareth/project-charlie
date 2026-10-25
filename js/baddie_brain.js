// How a baddie moves, as pure numbers and maths (carried over unchanged
// from the Godot game's baddie_brain.gd): walk (or fly) up beside the
// hero and wait there; two hits and it sinks into the ground.
// Punching back comes with the hearts (Phase 4, step 4).
import { clamp } from "./layout.js";

// World units per second; slower than the hero so Charlie can get away.
export const SPEED = { x: 150, y: 110 };
// How far in front of the hero a baddie stops: inside sword reach.
export const STOP_X = 110;
export const HP = 2;
export const DAMAGE = { sword: 1, hammer: 1 };
// Seconds of wobble after being hit.
export const HURT_TIME = 0.25;
// Seconds to sink into the ground.
export const SINK_TIME = 0.8;
// How far a hit pushes a baddie away.
export const KNOCKBACK = 40;

// Where a baddie wants to stand: beside the hero on the side it's already
// on, shifted by its `lane` so a crowd doesn't stack in one spot.
export function chaseTarget(hero, me, lane, area) {
  const side = me.x >= hero.x ? 1 : -1;
  return {
    x: clamp(hero.x + side * STOP_X, area.x, area.x + area.w),
    y: clamp(hero.y + lane, area.y, area.y + area.h),
  };
}

const toward = (from, to, most) => (Math.abs(to - from) <= most ? to : from + Math.sign(to - from) * most);

// One frame of walking toward `target`, never overshooting it.
export function step(me, target, dt) {
  return { x: toward(me.x, target.x, SPEED.x * dt), y: toward(me.y, target.y, SPEED.y * dt) };
}
