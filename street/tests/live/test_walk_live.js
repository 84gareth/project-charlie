// The hero walks in the real page when a key is held or a thumb drags the
// on-screen joystick, never off the street, and the camera follows.
import { test, assert, openPage, until } from "../framework.js";
import { WALK_AREA } from "../../js/layout.js";
import { STICK_RADIUS } from "../../js/controls.js";

async function start(w = 1024, h = 768) {
  const page = await openPage("../index.html?manual=1", w, h);
  await until(() => page.game !== undefined, "page script ran", 15000);
  return page;
}

const key = (page, type, code) => page.dispatchEvent(new page.KeyboardEvent(type, { code, bubbles: true }));
const run = (page, seconds) => { for (let t = 0; t < seconds; t += 1 / 60) page.gameTick(1 / 60); };

function touch(page, type, id, x, y) {
  const c = page.document.getElementById("game");
  c.dispatchEvent(new page.PointerEvent(type, { pointerId: id, pointerType: "touch", clientX: x, clientY: y, bubbles: true }));
}

test("right arrow walks right and faces right", async () => {
  const page = await start();
  const x = page.game.hero.x;
  key(page, "keydown", "ArrowRight");
  run(page, 0.5);
  key(page, "keyup", "ArrowRight");
  assert.gt(page.game.hero.x, x + 150, "walked right");
  assert.eq(page.game.hero.facing, 1);
  const stopped = page.game.hero.x;
  run(page, 0.3);
  assert.eq(page.game.hero.x, stopped, "stops when the key comes up");
});

test("dragging the joystick left walks left and turns round", async () => {
  const page = await start();
  page.game.hero.x = 1500;
  touch(page, "pointerdown", 7, 200, 600);
  touch(page, "pointermove", 7, 200 - STICK_RADIUS, 600);
  run(page, 0.5);
  assert.lt(page.game.hero.x, 1500 - 150, "walked left");
  assert.eq(page.game.hero.facing, -1);
  touch(page, "pointerup", 7, 200 - STICK_RADIUS, 600);
  const x = page.game.hero.x;
  run(page, 0.3);
  assert.eq(page.game.hero.x, x, "lifting the thumb stops");
});

test("joystick up walks up the street", async () => {
  const page = await start();
  const y = page.game.hero.y;
  touch(page, "pointerdown", 3, 200, 600);
  touch(page, "pointermove", 3, 200, 600 - STICK_RADIUS);
  run(page, 0.3);
  touch(page, "pointerup", 3, 200, 600 - STICK_RADIUS);
  assert.lt(page.game.hero.y, y - 30, "walked up");
});

test("can't walk off the left end", async () => {
  const page = await start();
  page.game.hero.x = WALK_AREA.x + 5;
  key(page, "keydown", "ArrowLeft");
  run(page, 0.3);
  key(page, "keyup", "ArrowLeft");
  assert.eq(page.game.hero.x, WALK_AREA.x);
});

test("the camera follows along the street", async () => {
  const page = await start();
  const cam = page.game.camX;
  key(page, "keydown", "ArrowRight");
  run(page, 3);
  key(page, "keyup", "ArrowRight");
  assert.gt(page.game.camX, cam + 500, "camera moved with the hero");
});
