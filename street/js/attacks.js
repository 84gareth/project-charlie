// Sword and hammer, as pure data and maths (carried over unchanged from
// the Godot game's attacks.gd).
//   Sword: a quick swing in front of the hero.
//   Hammer: Charlie's "spin hammer attack", hitting all around.
// Positions are feet-on-the-street positions, like the hero's.

export const SWORD = "sword";
export const HAMMER = "hammer";

// How long each attack lasts, in seconds. The hero stands still meanwhile.
export const DURATION = { sword: 0.25, hammer: 0.7 };
// When during the attack it can hit something: [from, to] in seconds.
export const HIT_WINDOW = { sword: [0.05, 0.2], hammer: [0.1, 0.6] };

// The sword reaches this far in front, and this far up or down the street.
export const SWORD_REACH = 170;
export const SWORD_DEPTH = 50;
// The hammer spin reaches this far all around.
export const HAMMER_REACH = 190;
export const HAMMER_DEPTH = 70;

// Would this attack hit something standing at `target`?
export function hits(kind, hero, facing, target) {
  const dx = target.x - hero.x, dy = target.y - hero.y;
  if (kind === SWORD) {
    const ahead = dx * facing;
    return ahead >= -20 && ahead <= SWORD_REACH && Math.abs(dy) <= SWORD_DEPTH;
  }
  if (kind === HAMMER) return Math.abs(dx) <= HAMMER_REACH && Math.abs(dy) <= HAMMER_DEPTH;
  return false;
}

// One hero's attack in progress: which one, and how far through it is.
export class AttackState {
  constructor() {
    this.kind = "";
    this.time = 0;
  }

  busy() { return this.kind !== ""; }

  // Starts an attack unless one is already going. True if it started.
  start(kind) {
    if (this.busy() || !(kind in DURATION)) return false;
    this.kind = kind;
    this.time = 0;
    return true;
  }

  update(dt) {
    if (!this.busy()) return;
    this.time += dt;
    if (this.time >= DURATION[this.kind]) {
      this.kind = "";
      this.time = 0;
    }
  }

  canHit() {
    if (!this.busy()) return false;
    const [from, to] = HIT_WINDOW[this.kind];
    return this.time >= from && this.time <= to;
  }

  // 0 at the start of the attack, nearly 1 at the end; 0 when idle.
  progress() { return this.busy() ? this.time / DURATION[this.kind] : 0; }
}
