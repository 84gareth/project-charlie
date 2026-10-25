// The teleportation bug: "it can teleport anywhere to scare you, behind,
// above and in front of you!" (Charlie).
import { test, assert } from "../framework.js";
import { Baddie, TELEPORT, teleportSpot } from "../../js/baddies.js";
import * as Brain from "../../js/baddie_brain.js";

const AREA = { x: 80, y: 600, w: 4640, h: 270 };
const HERO = { x: 2000, y: 730, facing: 1 };

function tick(b, seconds, hero = HERO) {
  const events = [];
  for (let t = 0; t < seconds; t += 1 / 60) {
    const e = b.update(1 / 60, hero, AREA);
    if (e) events.push(e);
  }
  return events;
}

// A teleport bug standing beside the hero, about to teleport.
function ready() {
  const b = new Baddie("teleport_bug", HERO.x + Brain.STOP_X, HERO.y);
  b.teleportWait = 0;
  b.punchWait = 99;
  return b;
}

test("it vanishes when its teleport is ready and it's near you", () => {
  const b = ready();
  b.update(1 / 60, HERO, AREA);
  assert.eq(b.state, "vanish");
  assert.ok(b.teleporting());
});

test("it takes turns: behind you, above you, in front of you", () => {
  const b = ready();
  const seen = [];
  for (let i = 0; i < 3; i++) {
    b.teleportWait = 0;
    b.punchWait = 99;
    tick(b, 1 / 60);
    seen.push(b.goingTo.where);
    tick(b, TELEPORT.VANISH + TELEPORT.APPEAR + 0.05);
  }
  assert.eq(seen, ["behind", "above", "front"]);
});

test("behind means the side you're not facing; in front, the side you are", () => {
  assert.lt(teleportSpot("behind", HERO, 1, AREA).x, HERO.x, "facing right: behind is left");
  assert.gt(teleportSpot("front", HERO, 1, AREA).x, HERO.x, "facing right: in front is right");
  assert.gt(teleportSpot("behind", HERO, -1, AREA).x, HERO.x, "facing left: behind is right");
  const s = teleportSpot("behind", HERO, 1, AREA);
  assert.eq(Math.abs(s.x - HERO.x), Brain.STOP_X, "close enough to punch");
  assert.eq(s.y, HERO.y);
});

test("it really moves: after the puff it's behind you", () => {
  const b = ready();
  tick(b, TELEPORT.VANISH + 0.05);
  assert.eq(b.state, "appear");
  assert.lt(b.x, HERO.x, "now on your other side");
});

test("from above it drops down", () => {
  const b = ready();
  b.teleports = 1;   // next is "above"
  tick(b, TELEPORT.VANISH + 0.05);
  assert.gt(b.drop, TELEPORT.DROP * 0.7, "high up as it appears");
  tick(b, TELEPORT.APPEAR);
  assert.eq(b.drop, 0, "landed");
});

test("it can't be hit while it's vanished", () => {
  const b = ready();
  tick(b, 0.1);
  assert.eq(b.state, "vanish");
  assert.notOk(b.takeHit(1, 1, HERO.x, AREA));
  assert.eq(b.hp, Brain.HP);
});

test("the scare: straight after popping up it winds up a punch", () => {
  const b = ready();
  b.punchWait = 2;
  tick(b, TELEPORT.VANISH + TELEPORT.APPEAR + 0.05);
  assert.eq(b.state, "walk");
  assert.lt(b.punchWait, TELEPORT.SCARE + 0.01, "punch coming soon");
  const events = tick(b, TELEPORT.SCARE + Brain.WINDUP + 0.1);
  assert.ok(events.includes("punch"), "and it punches");
});

test("then it waits before teleporting again", () => {
  const b = ready();
  tick(b, TELEPORT.VANISH + TELEPORT.APPEAR + 0.05);
  assert.gt(b.teleportWait, TELEPORT.EVERY - 0.1);
});

test("only the teleportation bug teleports", () => {
  for (const kind of ["house_bug", "acorn"]) {
    const b = new Baddie(kind, HERO.x + Brain.STOP_X, HERO.y);
    b.teleportWait = 0;
    tick(b, 1);
    assert.notOk(b.goingTo, `${kind} stays put`);
  }
});

test("it doesn't teleport from far away", () => {
  const b = new Baddie("teleport_bug", HERO.x + TELEPORT.RANGE + 300, HERO.y);
  b.teleportWait = 0;
  tick(b, 0.2);
  assert.eq(b.state, "walk");
});

test("the popping size: shrinks away, then pops back", () => {
  const b = ready();
  tick(b, TELEPORT.VANISH * 0.5);
  assert.lt(b.popScale(), 0.7, "shrinking");
  tick(b, TELEPORT.VANISH * 0.5 + TELEPORT.APPEAR * 0.5);
  assert.gt(b.popScale(), 1, "a bit too big as it pops");
  tick(b, TELEPORT.APPEAR);
  assert.eq(b.popScale(), 1);
});
