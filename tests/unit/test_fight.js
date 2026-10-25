// Twelve hearts; a short safe time after each hit; running out restarts
// the fight with full hearts and every gem kept. Godot's
// test_fight_state.gd, plus the bump.
import { test, assert } from "../framework.js";
import { FightState, MAX_HEARTS, SAFE_TIME, BUMP, bumpedX } from "../../js/fight.js";
import { GEM_VALUE } from "../../js/gems.js";

const AREA = { x: 80, y: 600, w: 4640, h: 270 };

test("starts with twelve hearts and no gems", () => {
  const f = new FightState();
  assert.eq(MAX_HEARTS, 12, "Charlie's number");
  assert.eq([f.hearts, f.gems], [12, 0]);
});

test("a punch costs one heart", () => {
  const f = new FightState();
  assert.ok(f.takeHit());
  assert.eq(f.hearts, 11);
});

test("safe for a moment after a hit", () => {
  const f = new FightState();
  f.takeHit();
  assert.ok(f.isSafe());
  assert.notOk(f.takeHit(), "a second punch straight after doesn't count");
  assert.eq(f.hearts, 11);
  f.update(SAFE_TIME + 0.01);
  assert.notOk(f.isSafe());
  assert.ok(f.takeHit(), "counts again once safe time is over");
  assert.eq(f.hearts, 10);
});

test("twelve punches run out", () => {
  const f = new FightState();
  for (let i = 0; i < 12; i++) {
    assert.notOk(f.outOfHearts(), `still going after ${i}`);
    f.takeHit();
    f.update(SAFE_TIME + 0.01);
  }
  assert.ok(f.outOfHearts());
  assert.notOk(f.takeHit(), "can't go below zero");
  assert.eq(f.hearts, 0);
});

test("restarting fills the hearts and keeps the gems", () => {
  const f = new FightState();
  for (let i = 0; i < 5; i++) f.addGem();
  for (let i = 0; i < 12; i++) { f.takeHit(); f.update(SAFE_TIME + 0.01); }
  f.restartFight();
  assert.eq(f.hearts, MAX_HEARTS, "full hearts");
  assert.eq(f.gems, 5 * GEM_VALUE, "gems kept");
  assert.ok(f.isSafe(), "a moment to get ready");
});

test("a heart from a helper, only when one is missing", () => {
  const f = new FightState();
  assert.notOk(f.heal(), "already full");
  f.takeHit();
  assert.ok(f.heal());
  assert.eq(f.hearts, MAX_HEARTS);
});

test("a punch bumps the hero away, never off the street", () => {
  assert.eq(bumpedX(1000, 1, 1110, AREA), 1000 - BUMP, "punched from the right: pushed left");
  assert.eq(bumpedX(1000, 1, 890, AREA), 1000 + BUMP, "from the left: pushed right");
  assert.eq(bumpedX(1000, 1, 1000, AREA), 1000 - BUMP, "right on top: pushed backwards");
  assert.eq(bumpedX(AREA.x + 10, 1, AREA.x + 100, AREA), AREA.x, "not off the end");
});
