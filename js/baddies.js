// One baddie, as a pure state machine (no drawing, no page): Charlie's
// house bug, Acorn bad guy and teleportation bug. Its x, y is where it
// touches the street (flying ones float above that spot, with a shadow).
// Walks up beside the hero; when hit it wobbles, gets pushed back; out of
// HP it sinks into the ground and then is gone, leaving a gem.
import * as Brain from "./baddie_brain.js";
import { clamp } from "./layout.js";

// Charlie's three bugs, in the order a wave brings them.
export const KINDS = ["house_bug", "acorn", "teleport_bug"];
// How high each one floats above its spot on the street. The house bug
// and the Acorn bad guy fly (Charlie); the teleportation bug stands.
export const HOVER = { house_bug: 110, acorn: 55, teleport_bug: 0 };

export class Baddie {
  constructor(kind, x, y, lane = 0) {
    this.kind = kind;
    this.x = x;
    this.y = y;
    this.lane = lane;
    this.hp = Brain.HP;
    this.state = "walk";   // walk, hurt, sink, gone
    this.timer = 0;
    this.facing = -1;
    // Every attack that has hit it: one swing or spin hits once.
    this.hitBy = new Set();
  }

  alive() { return this.state === "walk" || this.state === "hurt"; }

  // Hit by attack number `attackId` from someone standing at `fromX`.
  // True if it counted.
  takeHit(damage, attackId, fromX, area) {
    if (!this.alive() || this.hitBy.has(attackId)) return false;
    this.hitBy.add(attackId);
    this.hp -= damage;
    this.x = clamp(this.x + Math.sign(this.x - fromX) * Brain.KNOCKBACK, area.x, area.x + area.w);
    this.state = this.hp <= 0 ? "sink" : "hurt";
    this.timer = 0;
    return true;
  }

  // One frame. Returns "sunk" on the frame it finishes sinking (that's
  // when its gem pops out), otherwise null.
  update(dt, hero, area) {
    this.timer += dt;
    if (this.state === "walk" && hero) {
      const target = Brain.chaseTarget(hero, this, this.lane, area);
      const p = Brain.step(this, target, dt);
      this.x = p.x;
      this.y = p.y;
    } else if (this.state === "hurt" && this.timer >= Brain.HURT_TIME) {
      this.state = "walk";
      this.timer = 0;
    } else if (this.state === "sink" && this.timer >= Brain.SINK_TIME) {
      this.state = "gone";
      return "sunk";
    }
    if (hero && this.alive()) this.facing = hero.x >= this.x ? 1 : -1;
    return null;
  }

  // 0 standing, 1 all the way into the ground.
  sinkAmount() { return this.state === "sink" ? Math.min(1, this.timer / Brain.SINK_TIME) : 0; }
}
