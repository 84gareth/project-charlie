// tools/playtest.sh passes ?mode=...&hero=...; anything odd means the
// normal game.
import { test, assert } from "../framework.js";
import { options } from "../../js/playtest.js";

test("no options is the normal game", () => {
  assert.eq(options(""), { mode: "street", hero: "", manual: false });
});

test("each mode and hero is read", () => {
  for (const m of ["street", "practice", "fight", "helpers"]) assert.eq(options("?mode=" + m).mode, m);
  assert.eq(options("?mode=fight&hero=girl").hero, "girl");
  assert.ok(options("?manual=1").manual);
});

test("odd ones fall back", () => {
  assert.eq(options("?mode=banana&hero=dragon"), { mode: "street", hero: "", manual: false });
});
