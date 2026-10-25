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

// ─── The teleportation bug's teleport ──────────────────────────────────────
// Charlie: "it can teleport anywhere to scare you, behind, above and in
// front of you!" Every few seconds, when it's near you, it vanishes in a
// puff of sparkles and pops up next to you, taking turns: behind you,
// above you (then dropping down in front), in front of you. Straight after
// popping up it gets ready to punch: that's the scare.
export const TELEPORT = {
  FIRST: 2.0,      // seconds before its first teleport
  EVERY: 4.0,      // seconds between teleports
  RANGE: 700,      // only when this close to the hero (about on screen)
  VANISH: 0.35,    // seconds to vanish (can't be hit meanwhile)
  APPEAR: 0.4,     // seconds to pop up (and drop, from above)
  DROP: 260,       // how high above you it appears before dropping
  SCARE: 0.4,      // seconds after popping up before it winds up a punch
  ORDER: ["behind", "above", "front"],
};

// ─── The Acorn bad guy's drop from a tree ─────────────────────────────────
// Charlie: "They drop from trees and attack you and can fly too." It
// starts hidden up in one of Charlie's trees, waits a moment, then drops
// to the street (it can't be hit until it's down) and flies at you.
export const TREE_DROP = {
  WAIT: 0.8,      // seconds hiding in the tree
  FALL: 0.5,      // seconds to drop down
  HEIGHT: 190,    // how far above its flying height it hides
};

// Where the teleportation bug pops up: beside the hero, behind or in
// front of where they're facing (from above, it drops in front), kept on
// the street.
export function teleportSpot(where, hero, facing, area) {
  const side = where === "behind" ? -facing : facing;
  return {
    x: clamp(hero.x + side * Brain.STOP_X, area.x, area.x + area.w),
    y: clamp(hero.y, area.y, area.y + area.h),
  };
}

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
    // The teleportation bug: seconds to its next teleport, which way it
    // goes next, where it's going, and how high it still is when dropping.
    this.teleportWait = TELEPORT.FIRST;
    this.teleports = 0;
    this.goingTo = null;
    this.drop = 0;
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
  // Up in a tree (hidden), then dropping from it.
  hideInTree() {
    this.drop = TREE_DROP.HEIGHT;
    this.enter("tree");
  }

  inTree() { return this.state === "tree"; }

  takeHit(damage, attackId, fromX, area) {
    if (!this.alive() || this.hitBy.has(attackId)) return false;
    if (["vanish", "tree", "fall"].includes(this.state)) return false;
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
        if (this.kind === "teleport_bug") this.teleportWait -= dt;
        if (hero) {
          const p = Brain.step(this, Brain.chaseTarget(hero, this, this.lane, area), dt);
          this.x = p.x;
          this.y = p.y;
          if (this.kind === "teleport_bug" && this.teleportWait <= 0
              && Math.abs(hero.x - this.x) <= TELEPORT.RANGE) {
            const where = TELEPORT.ORDER[this.teleports % TELEPORT.ORDER.length];
            this.teleports += 1;
            this.goingTo = { where, ...teleportSpot(where, hero, hero.facing || 1, area) };
            this.enter("vanish");
          } else if (this.punchWait <= 0 && Brain.inReach(this, hero)) {
            this.enter("windup");
          }
        }
        break;
      case "tree":
        if (this.timer >= TREE_DROP.WAIT) this.enter("fall");
        break;
      case "fall": {
        // Speeding up as it falls.
        const k = Math.min(1, this.timer / TREE_DROP.FALL);
        this.drop = TREE_DROP.HEIGHT * (1 - k * k);
        if (k >= 1) {
          this.drop = 0;
          this.enter("walk");
        }
        break;
      }
      case "vanish":
        if (this.timer >= TELEPORT.VANISH) {
          this.x = this.goingTo.x;
          this.y = this.goingTo.y;
          this.drop = this.goingTo.where === "above" ? TELEPORT.DROP : 0;
          this.enter("appear");
        }
        break;
      case "appear":
        this.drop = this.goingTo.where === "above"
          ? TELEPORT.DROP * Math.max(0, 1 - this.timer / TELEPORT.APPEAR) : 0;
        if (this.timer >= TELEPORT.APPEAR) {
          this.drop = 0;
          this.teleportWait = TELEPORT.EVERY;
          this.punchWait = Math.min(this.punchWait, TELEPORT.SCARE);
          this.enter("walk");
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

  // How big it's drawn while teleporting: shrinking away to nothing, then
  // popping back up (a little too big for a moment). 1 the rest of the time.
  popScale() {
    if (this.state === "vanish") return Math.max(0, 1 - this.timer / TELEPORT.VANISH);
    if (this.state === "appear") {
      const k = Math.min(1, this.timer / (TELEPORT.APPEAR * 0.5));
      return k < 1 ? k * 1.15 : 1 + 0.15 * Math.max(0, 1 - (this.timer - TELEPORT.APPEAR * 0.5) / (TELEPORT.APPEAR * 0.5));
    }
    return 1;
  }

  teleporting() { return this.state === "vanish" || this.state === "appear"; }
}
