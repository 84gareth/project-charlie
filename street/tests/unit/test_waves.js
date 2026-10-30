// Waves come from just out of view, spread out, one of each of Charlie's
// bugs, never off the street. Godot's test_waves.gd plus the bugs.
import { test, assert } from "../framework.js";
import * as Waves from "../../js/waves.js";
import { view } from "../../js/layout.js";

const AREA = { x: 80, y: 600, w: 4640, h: 270 };
// Half the widest view: a laptop's wide screen shows the most street.
const HALF_VIEW = view(1920, 1080).width / 2;

test("a wave is one of each of Charlie's bugs", () => {
  assert.eq(Waves.SIZE, 3);
  assert.eq([0, 1, 2].map(Waves.kind), ["house_bug", "acorn", "teleport_bug"]);
});

test("mid-street they come from both sides, out of view on a laptop or iPad", () => {
  const pts = Waves.spawnPoints(2400, AREA);
  for (const p of pts) assert.gt(Math.abs(p.x - 2400), HALF_VIEW, `out of view: ${p.x}`);
  assert.ok(pts.some((p) => p.x < 2400) && pts.some((p) => p.x > 2400), "both sides");
});

test("at the start of the street they all come from the right", () => {
  for (const p of Waves.spawnPoints(420, AREA)) assert.gt(p.x, 420 + HALF_VIEW);
});

test("at the end of the street they all come from the left", () => {
  for (const p of Waves.spawnPoints(4600, AREA)) assert.lt(p.x, 4600 - HALF_VIEW);
});

test("always on the street, each on its own lane", () => {
  const ys = new Set();
  for (const p of Waves.spawnPoints(2400, AREA)) {
    assert.ok(p.x >= AREA.x && p.x <= AREA.x + AREA.w && p.y >= AREA.y && p.y <= AREA.y + AREA.h);
    ys.add(p.y);
  }
  assert.eq(ys.size, 3);
});

test("fight mode's close wave starts in view", () => {
  for (const p of Waves.spawnPoints(420, AREA, 3, Waves.CLOSE)) {
    assert.lt(p.x - 420, view(1024, 768).width, `in view on an iPad: ${p.x}`);
  }
});
