// In the real page: the sword and hammer buttons (and keys) start attacks,
// the hero stands still while attacking and walks again afterwards, and
// mashing doesn't restart an attack.
import { test, assert, openPage, until } from "../framework.js";
import { buttons } from "../../js/controls.js";
import { DURATION } from "../../js/attacks.js";

async function start() {
  const page = await openPage("../index.html?manual=1", 1024, 768);
  await until(() => page.game !== undefined, "page script ran", 15000);
  return page;
}

const key = (page, type, code) => page.dispatchEvent(new page.KeyboardEvent(type, { code, bubbles: true }));
const run = (page, seconds) => { for (let t = 0; t < seconds; t += 1 / 60) page.gameTick(1 / 60); };

function tap(page, action, id = 5) {
  const b = buttons(1024, 768).find((x) => x.action === action);
  const c = page.document.getElementById("game");
  for (const type of ["pointerdown", "pointerup"]) {
    c.dispatchEvent(new page.PointerEvent(type, { pointerId: id, pointerType: "touch", clientX: b.x, clientY: b.y, bubbles: true }));
  }
}

test("tapping the sword button swings the sword", async () => {
  const page = await start();
  tap(page, "sword");
  page.gameTick(1 / 60);
  assert.eq(page.game.attack.kind, "sword");
  assert.eq(page.game.hero.attack, "sword", "the hero is drawn swinging");
  run(page, DURATION.sword + 0.05);
  assert.notOk(page.game.attack.busy(), "swing ends");
});

test("tapping the hammer button spins the hammer", async () => {
  const page = await start();
  tap(page, "hammer");
  page.gameTick(1 / 60);
  assert.eq(page.game.attack.kind, "hammer");
});

test("the keys work too: Z for the sword, X for the hammer", async () => {
  const page = await start();
  key(page, "keydown", "KeyZ");
  key(page, "keyup", "KeyZ");
  page.gameTick(1 / 60);
  assert.eq(page.game.attack.kind, "sword");
  run(page, 0.5);
  key(page, "keydown", "KeyX");
  key(page, "keyup", "KeyX");
  page.gameTick(1 / 60);
  assert.eq(page.game.attack.kind, "hammer");
});

test("standing still while spinning, then walking again", async () => {
  const page = await start();
  key(page, "keydown", "ArrowRight");
  tap(page, "hammer");
  page.gameTick(1 / 60);
  const x = page.game.hero.x;
  run(page, 0.3);
  assert.eq(page.game.hero.x, x, "no walking mid-spin");
  run(page, DURATION.hammer);
  assert.gt(page.game.hero.x, x + 20, "walks again after");
  key(page, "keyup", "ArrowRight");
});

test("mashing during a spin doesn't restart it", async () => {
  const page = await start();
  tap(page, "hammer");
  page.gameTick(1 / 60);
  const id = page.game.attackId;
  run(page, 0.2);
  tap(page, "sword", 6);
  tap(page, "hammer", 7);
  page.gameTick(1 / 60);
  assert.eq(page.game.attackId, id, "only the first press counts");
  assert.eq(page.game.attack.kind, "hammer");
  assert.gt(page.game.attack.time, 0.2, "the spin carried on");
});

test("a tap on a button doesn't also start the joystick", async () => {
  const page = await start();
  tap(page, "sword");
  page.gameTick(1 / 60);
  assert.eq(page.game.hero.facing, 1);
  assert.notOk(page.game.hero.moving);
});
