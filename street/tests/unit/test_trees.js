// Charlie's trees, and the Acorn bad guy who "drop[s] from trees and
// attack[s] you and can fly too".
import { test, assert } from "../framework.js";
import { TREES, nearestTree, WORLD_WIDTH, view } from "../../js/layout.js";
import { Baddie, TREE_DROP } from "../../js/baddies.js";

const AREA = { x: 80, y: 600, w: 4640, h: 270 };

function tick(b, seconds, hero) {
  for (let t = 0; t < seconds; t += 1 / 60) b.update(1 / 60, hero, AREA);
}

test("trees all along the street, one always in view", () => {
  assert.ok(TREES.every((x) => x > 0 && x < WORLD_WIDTH));
  const halfView = view(1024, 768).width / 2;
  for (let x = AREA.x; x <= AREA.x + AREA.w; x += 50) {
    assert.lt(Math.abs(nearestTree(x) - x), halfView, `a tree on screen when the hero is at ${x}`);
  }
});

test("the nearest tree is the nearest one", () => {
  assert.eq(nearestTree(420), 600);
  assert.eq(nearestTree(2000), 2400);
  assert.eq(nearestTree(4700), 4200);
});

test("hiding in a tree, it can't be hit, then it drops down", () => {
  const hero = { x: 900, y: 730 };
  const b = new Baddie("acorn", 600, 620);
  b.hideInTree();
  assert.ok(b.inTree());
  assert.eq(b.drop, TREE_DROP.HEIGHT, "up high");
  assert.notOk(b.takeHit(1, 1, hero.x, AREA), "safe in the tree");
  tick(b, TREE_DROP.WAIT + 0.05, hero);
  assert.eq(b.state, "fall");
  assert.notOk(b.takeHit(1, 2, hero.x, AREA), "and while falling");
  tick(b, TREE_DROP.FALL, hero);
  assert.eq(b.drop, 0, "landed");
  assert.eq(b.state, "walk", "and off it flies at you");
  assert.ok(b.takeHit(1, 3, hero.x, AREA), "now it can be hit");
});

test("it falls faster and faster, like a real acorn", () => {
  const b = new Baddie("acorn", 600, 620);
  b.hideInTree();
  tick(b, TREE_DROP.WAIT + 0.02, { x: 900, y: 730 });
  const heights = [];
  for (let i = 0; i < 4; i++) { tick(b, TREE_DROP.FALL / 5, { x: 900, y: 730 }); heights.push(b.drop); }
  const steps = heights.slice(1).map((h, i) => heights[i] - h);
  assert.ok(steps[2] > steps[0], `speeding up: ${steps}`);
});

test("it waits in the tree before dropping, so Charlie can spot it", () => {
  assert.gt(TREE_DROP.WAIT, 0.5);
});
