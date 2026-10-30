// The hero's side of the fight, as pure logic: hearts and gems (carried
// over unchanged from the Godot game's fight_state.gd). Charlie chose 12
// hearts. Running out restarts the fight, and you keep your gems (Gareth).
import { GEM_VALUE } from "./gems.js";

export const MAX_HEARTS = 12;
// Seconds after a hit when nothing can hurt you again, so a crowd can't
// take several hearts at once.
export const SAFE_TIME = 1.0;
// Seconds the hero lies down after running out of hearts.
export const DOWN_TIME = 1.5;
// How far a punch pushes the hero.
export const BUMP = 50;

export class FightState {
  constructor() {
    this.hearts = MAX_HEARTS;
    this.gems = 0;
    this.safe = 0;
  }

  // A baddie's punch landed. True if it cost a heart.
  takeHit() {
    if (this.safe > 0 || this.hearts <= 0) return false;
    this.hearts -= 1;
    this.safe = SAFE_TIME;
    return true;
  }

  update(dt) { this.safe = Math.max(0, this.safe - dt); }
  isSafe() { return this.safe > 0; }
  outOfHearts() { return this.hearts <= 0; }

  // A helper gives a heart. True if it helped (false when full or out).
  heal() {
    if (this.hearts <= 0 || this.hearts >= MAX_HEARTS) return false;
    this.hearts += 1;
    return true;
  }

  addGem() { this.gems += GEM_VALUE; }

  // Hearts back to full; gems kept.
  restartFight() {
    this.hearts = MAX_HEARTS;
    this.safe = SAFE_TIME;
  }
}

// Where a punch from someone at `fromX` pushes the hero: away from them
// (backwards if they're right on top), kept on the street.
export function bumpedX(heroX, facing, fromX, area) {
  const away = Math.sign(heroX - fromX) || -facing;
  return Math.min(area.x + area.w, Math.max(area.x, heroX + away * BUMP));
}
