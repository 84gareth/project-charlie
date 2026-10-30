// Belt-scroller walking: speeds, diagonals, staying on the street, facing.
// The same checks as the Godot game's test_walk.gd.
import { test, assert } from "../framework.js";
import { SPEED, step, facing } from "../../js/walk.js";

const AREA = { x: 100, y: 600, w: 1000, h: 200 };

test("walks right at full speed", () => {
  const p = step({ x: 500, y: 700 }, { x: 1, y: 0 }, 0.5, AREA);
  assert.near(p.x, 500 + SPEED.x * 0.5);
  assert.near(p.y, 700);
});

test("walks across the street slower than along it", () => {
  const along = step({ x: 500, y: 700 }, { x: 1, y: 0 }, 0.1, AREA);
  const across = step({ x: 500, y: 700 }, { x: 0, y: 1 }, 0.1, AREA);
  assert.gt(along.x - 500, across.y - 700, "along beats across");
  assert.gt(across.y, 700, "down means further down the screen");
});

test("diagonal is not faster than straight", () => {
  const straight = step({ x: 500, y: 700 }, { x: 3, y: 0 }, 0.1, AREA);
  assert.near(straight.x - 500, SPEED.x * 0.1, 0.001, "oversized input is capped");
  const diag = step({ x: 500, y: 700 }, { x: 1, y: 1 }, 0.1, AREA);
  assert.lt(diag.x - 500, SPEED.x * 0.1, "diagonal x is less than a straight walk");
});

test("stays on the street on every side", () => {
  assert.eq(step({ x: 110, y: 700 }, { x: -1, y: 0 }, 1, AREA).x, AREA.x, "left edge");
  assert.eq(step({ x: 1090, y: 700 }, { x: 1, y: 0 }, 1, AREA).x, AREA.x + AREA.w, "right edge");
  assert.eq(step({ x: 500, y: 610 }, { x: 0, y: -1 }, 1, AREA).y, AREA.y, "back of the pavement");
  assert.eq(step({ x: 500, y: 790 }, { x: 0, y: 1 }, 1, AREA).y, AREA.y + AREA.h, "front of the road");
});

test("standing still stays put", () => {
  assert.eq(step({ x: 500, y: 700 }, { x: 0, y: 0 }, 1, AREA), { x: 500, y: 700 });
});

test("facing follows left and right only", () => {
  assert.eq(facing(1, -1), -1, "walk left, face left");
  assert.eq(facing(-1, 1), 1, "walk right, face right");
  assert.eq(facing(-1, 0), -1, "straight up or down keeps facing");
  assert.eq(facing(1, 0.05), 1, "a tiny wobble keeps facing");
});
