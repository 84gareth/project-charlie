// One of Charlie's bugs: walks up, gets knocked back, two hits sinks it,
// one swing counts once, and it says "sunk" once it's all the way down.
import { test, assert } from "../framework.js";
import { Baddie, KINDS, HOVER } from "../../js/baddies.js";
import * as Brain from "../../js/baddie_brain.js";

const AREA = { x: 80, y: 600, w: 4640, h: 270 };
const HERO = { x: 1000, y: 730 };

test("Charlie's three bugs; the house bug and the Acorn fly", () => {
  assert.eq(KINDS, ["house_bug", "acorn", "teleport_bug"]);
  assert.gt(HOVER.house_bug, 0, "the house bug flies");
  assert.gt(HOVER.acorn, 0, "the Acorn bad guy flies too");
});

test("walks up to the hero and faces them", () => {
  const b = new Baddie("acorn", 1500, 730);
  for (let i = 0; i < 300; i++) b.update(1 / 60, HERO, AREA);
  assert.near(b.x, HERO.x + Brain.STOP_X, 1e-6, "stands beside the hero");
  assert.eq(b.facing, -1, "faces left, toward the hero");
});

test("a hit knocks it back and makes it wobble, then it carries on", () => {
  const b = new Baddie("house_bug", 1110, 730);
  assert.ok(b.takeHit(1, 1, HERO.x, AREA));
  assert.eq(b.x, 1110 + Brain.KNOCKBACK, "pushed away");
  assert.eq(b.state, "hurt");
  b.update(Brain.HURT_TIME + 0.01, HERO, AREA);
  assert.eq(b.state, "walk");
});

test("one swing hits once, even if another lands in between", () => {
  const b = new Baddie("acorn", 1110, 730);
  b.hp = 5;
  assert.ok(b.takeHit(1, 7, HERO.x, AREA), "swing 7");
  assert.ok(b.takeHit(1, 8, HERO.x, AREA), "swing 8");
  assert.notOk(b.takeHit(1, 7, HERO.x, AREA), "swing 7 again doesn't count");
  assert.eq(b.hp, 3);
});

test("two hits and it sinks, then it's gone with a 'sunk'", () => {
  const b = new Baddie("teleport_bug", 1110, 730);
  b.takeHit(1, 1, HERO.x, AREA);
  b.takeHit(1, 2, HERO.x, AREA);
  assert.eq(b.state, "sink");
  assert.notOk(b.alive());
  assert.notOk(b.takeHit(1, 3, HERO.x, AREA), "can't be hit while sinking");
  assert.eq(b.update(Brain.SINK_TIME / 2, HERO, AREA), null, "still sinking");
  assert.near(b.sinkAmount(), 0.5, 1e-9);
  assert.eq(b.update(Brain.SINK_TIME, HERO, AREA), "sunk");
  assert.eq(b.state, "gone");
});

test("knockback never pushes it off the street", () => {
  const b = new Baddie("acorn", AREA.x + AREA.w - 10, 730);
  b.takeHit(1, 1, AREA.x + AREA.w - 100, AREA);
  assert.eq(b.x, AREA.x + AREA.w);
});
