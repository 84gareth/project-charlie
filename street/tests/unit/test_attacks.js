// Sword swings in front; the hammer spins all around; one attack at a
// time. The same checks as the Godot game's test_attacks.gd.
import { test, assert } from "../framework.js";
import * as A from "../../js/attacks.js";

const HERO = { x: 1000, y: 700 };
const at = (dx, dy) => ({ x: HERO.x + dx, y: HERO.y + dy });

test("sword hits in front", () => {
  assert.ok(A.hits(A.SWORD, HERO, 1, at(100, 0)), "right in front");
  assert.ok(A.hits(A.SWORD, HERO, 1, at(100, 40)), "a bit down the street");
});

test("sword misses behind, far, and off to the side", () => {
  assert.notOk(A.hits(A.SWORD, HERO, 1, at(-100, 0)), "behind");
  assert.notOk(A.hits(A.SWORD, HERO, 1, at(A.SWORD_REACH + 10, 0)), "too far");
  assert.notOk(A.hits(A.SWORD, HERO, 1, at(100, A.SWORD_DEPTH + 10)), "too far down the street");
});

test("sword faces the way the hero faces", () => {
  assert.ok(A.hits(A.SWORD, HERO, -1, at(-100, 0)), "facing left hits left");
  assert.notOk(A.hits(A.SWORD, HERO, -1, at(100, 0)), "facing left misses right");
});

test("hammer spin hits all around", () => {
  for (const [dx, dy] of [[150, 0], [-150, 0], [0, 60], [0, -60]]) {
    assert.ok(A.hits(A.HAMMER, HERO, 1, at(dx, dy)), `hits at ${dx},${dy}`);
  }
  assert.notOk(A.hits(A.HAMMER, HERO, 1, at(A.HAMMER_REACH + 10, 0)), "too far");
});

test("one attack at a time", () => {
  const s = new A.AttackState();
  assert.notOk(s.busy());
  assert.ok(s.start(A.SWORD), "sword starts");
  assert.notOk(s.start(A.HAMMER), "no hammer mid-swing");
  assert.eq(s.kind, A.SWORD);
});

test("an attack finishes after its time", () => {
  const s = new A.AttackState();
  s.start(A.HAMMER);
  s.update(A.DURATION.hammer - 0.05);
  assert.ok(s.busy(), "still spinning");
  s.update(0.1);
  assert.notOk(s.busy(), "spin over");
  assert.ok(s.start(A.SWORD), "free to attack again");
});

test("hammer spin lasts longer than a sword swing", () => {
  assert.gt(A.DURATION.hammer, A.DURATION.sword);
});

test("can only hit in the middle of an attack", () => {
  const s = new A.AttackState();
  assert.notOk(s.canHit(), "idle");
  s.start(A.SWORD);
  assert.notOk(s.canHit(), "wind-up");
  s.update(0.1);
  assert.ok(s.canHit(), "mid-swing");
  s.update(0.12);
  assert.notOk(s.canHit(), "follow-through");
});

test("an unknown attack does not start", () => {
  const s = new A.AttackState();
  assert.notOk(s.start("banana"));
  assert.notOk(s.busy());
});
