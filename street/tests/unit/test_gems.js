// Walk onto a gem to pick it up; each is worth 10.
import { test, assert } from "../framework.js";
import { touching, GEM_VALUE } from "../../js/gems.js";

test("each gem is worth 10 (Gareth's number)", () => {
  assert.eq(GEM_VALUE, 10);
});

test("standing on a gem picks it up", () => {
  assert.ok(touching({ x: 500, y: 700 }, { x: 500, y: 700 }));
  assert.ok(touching({ x: 500, y: 700 }, { x: 560, y: 730 }), "close enough");
});

test("walking past nearby does not", () => {
  assert.notOk(touching({ x: 500, y: 700 }, { x: 600, y: 700 }), "too far along");
  assert.notOk(touching({ x: 500, y: 700 }, { x: 500, y: 760 }), "too far across");
});
