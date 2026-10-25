// Baddies walk up beside the hero, slower than the hero, and take two
// hits. The same checks as the Godot game's test_baddie_brain.gd.
import { test, assert } from "../framework.js";
import * as Brain from "../../js/baddie_brain.js";
import { SPEED as HERO_SPEED } from "../../js/walk.js";
import { hits } from "../../js/attacks.js";

const AREA = { x: 80, y: 600, w: 4640, h: 270 };
const HERO = { x: 1000, y: 730 };

test("stops beside the hero on its own side", () => {
  assert.eq(Brain.chaseTarget(HERO, { x: 1500, y: 700 }, 0, AREA), { x: HERO.x + Brain.STOP_X, y: HERO.y }, "right side");
  assert.eq(Brain.chaseTarget(HERO, { x: 400, y: 700 }, 0, AREA), { x: HERO.x - Brain.STOP_X, y: HERO.y }, "left side");
});

test("its lane spreads a crowd up and down", () => {
  assert.eq(Brain.chaseTarget(HERO, { x: 1500, y: 700 }, 35, AREA).y, HERO.y + 35);
});

test("the stopping spot stays on the street", () => {
  const t = Brain.chaseTarget({ x: 4700, y: 865 }, { x: 4710, y: 700 }, 35, AREA);
  assert.ok(t.x <= AREA.x + AREA.w && t.y <= AREA.y + AREA.h);
});

test("it stands where the sword and hammer reach", () => {
  for (const lane of [-35, 0, 35]) {
    const spot = Brain.chaseTarget(HERO, { x: 1500, y: 700 }, lane, AREA);
    assert.ok(hits("sword", HERO, 1, spot), `sword reaches lane ${lane}`);
    assert.ok(hits("hammer", HERO, 1, spot), `hammer reaches lane ${lane}`);
  }
});

test("walks toward its spot without overshooting", () => {
  assert.eq(Brain.step({ x: 1000, y: 700 }, { x: 1010, y: 700 }, 1), { x: 1010, y: 700 }, "stops on the spot");
  assert.near(Brain.step({ x: 1000, y: 700 }, { x: 2000, y: 700 }, 0.1).x, 1000 + Brain.SPEED.x * 0.1, 1e-9, "at its speed");
});

test("slower than the hero", () => {
  assert.lt(Brain.SPEED.x, HERO_SPEED.x, "along the street");
  assert.lt(Brain.SPEED.y, HERO_SPEED.y, "across the street");
});

test("two hits from either weapon", () => {
  for (const kind of ["sword", "hammer"]) {
    assert.gt(Brain.HP, Brain.DAMAGE[kind], `${kind}: one hit isn't enough`);
    assert.ok(Brain.DAMAGE[kind] * 2 >= Brain.HP, `${kind}: two hits are`);
  }
});
