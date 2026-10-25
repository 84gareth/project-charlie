// One baddie, as a pure state machine (no drawing, no page): Charlie's
// house bug, Acorn bad guy and teleportation bug. Its x, y is where it
// touches the street (flying ones float above that spot, with a shadow).
// Walks up beside the hero and now and then winds up a punch, which lands
// only if the hero is still in reach. When hit it wobbles, gets pushed
// back and loses its wind-up; out of HP it sinks into the ground and then
// is gone, leaving a gem.
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
    // walk, windup, punch, hurt, sink, gone
    this.state = "walk";
    this.timer = 0;
    this.facing = -1;
    // Seconds until it may start its next punch.
    this.punchWait = Brain.FIRST_PUNCH;
    // Every attack that has hit it: one swing or spin hits once.
    this.hitBy = new Set();
  }

  alive() { return this.state !== "sink" && this.state !== "gone"; }

  enter(state) {
    this.state = state;
    this.timer = 0;
  }

  // Hit by attack number `attackId` from someone standing at `fromX`.
  // True if it counted. A hit stops a wind-up.
  takeHit(damage, attackId, fromX, area) {
    if (!this.alive() || this.hitBy.has(attackId)) return false;
    this.hitBy.add(attackId);
    this.hp -= damage;
    this.x = clamp(this.x + Math.sign(this.x - fromX) * Brain.KNOCKBACK, area.x, area.x + area.w);
    this.enter(this.hp <= 0 ? "sink" : "hurt");
    return true;
  }

  // One frame. Returns "punch" on the frame a punch lands on the hero,
  // "sunk" on the frame it finishes sinking (when its gem pops out),
  // otherwise null.
  update(dt, hero, area) {
    this.timer += dt;
    let event = null;
    switch (this.state) {
      case "walk":
        this.punchWait -= dt;
        if (hero) {
          const p = Brain.step(this, Brain.chaseTarget(hero, this, this.lane, area), dt);
          this.x = p.x;
          this.y = p.y;
          if (this.punchWait <= 0 && Brain.inReach(this, hero)) this.enter("windup");
        }
        break;
      case "windup":
        if (this.timer >= Brain.WINDUP) {
          if (hero && Brain.inReach(this, hero)) event = "punch";
          this.punchWait = Brain.COOLDOWN;
          this.enter("punch");
        }
        break;
      case "punch":
        if (this.timer >= Brain.PUNCH_SHOW) this.enter("walk");
        break;
      case "hurt":
        if (this.timer >= Brain.HURT_TIME) {
          this.punchWait = Math.max(this.punchWait, Brain.FIRST_PUNCH);
          this.enter("walk");
        }
        break;
      case "sink":
        if (this.timer >= Brain.SINK_TIME) {
          this.enter("gone");
          return "sunk";
        }
        break;
    }
    if (hero && this.alive()) this.facing = hero.x >= this.x ? 1 : -1;
    return event;
  }

  // 0 standing, 1 all the way into the ground.
  sinkAmount() { return this.state === "sink" ? Math.min(1, this.timer / Brain.SINK_TIME) : 0; }
}
