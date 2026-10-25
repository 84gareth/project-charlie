// Gems: every baddie leaves one (Charlie), each worth 10 (Gareth), and you
// walk onto one to pick it up (carried over from the Godot game).

// Each gem picked up adds this much to the counter.
export const GEM_VALUE = 10;

// How close the hero's feet must be, along and across the street.
export const PICKUP = { x: 70, y: 45 };

export const touching = (hero, gem) =>
  Math.abs(gem.x - hero.x) <= PICKUP.x && Math.abs(gem.y - hero.y) <= PICKUP.y;
