// The street fits the iPad: whole street top to bottom, a slice of it
// across, and the camera keeps the hero in the middle without going past
// either end.
import { test, assert } from "../framework.js";
import { view, cameraX, keepIn, WORLD_WIDTH, WORLD_HEIGHT, WALK_AREA, VIEW_MIN_WIDTH } from "../../js/layout.js";

test("an iPad held sideways sees the whole street top to bottom", () => {
  const v = view(1024, 768);
  assert.near(v.scale * WORLD_HEIGHT, 768, 1e-6, "fills the height");
  assert.near(v.top, 0, 1e-6, "no gap above");
  assert.gt(v.width, VIEW_MIN_WIDTH - 1e-6, "at least the minimum width across");
});

test("an iPad held upright still sees enough street across", () => {
  const v = view(768, 1024);
  assert.near(v.width, VIEW_MIN_WIDTH, 1e-6, "the minimum width");
  assert.gt(v.top, 0, "sky above and below to fill the tall screen");
});

test("the camera follows the hero and stops at the ends", () => {
  assert.eq(cameraX(2400, 1200), 1800, "hero in the middle");
  assert.eq(cameraX(100, 1200), 0, "not past the start");
  assert.eq(cameraX(4790, 1200), WORLD_WIDTH - 1200, "not past the end");
});

test("keepIn holds a point inside an area", () => {
  assert.eq(keepIn({ x: 0, y: 2000 }, WALK_AREA), { x: WALK_AREA.x, y: WALK_AREA.y + WALK_AREA.h });
  assert.eq(keepIn({ x: 500, y: 700 }, WALK_AREA), { x: 500, y: 700 });
});
