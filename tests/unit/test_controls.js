// What thumbs, keys and the controller mean: the on-screen joystick, the
// sword and hammer buttons, the keyboard, and Xbox or Switch pads.
import { test, assert } from "../framework.js";
import * as C from "../../js/controls.js";

const O = { x: 200, y: 600 };

test("joystick: push right to walk right, up to walk up", () => {
  assert.eq(C.stickVector(O, { x: O.x + C.STICK_RADIUS, y: O.y }), { x: 1, y: 0 });
  assert.eq(C.stickVector(O, { x: O.x, y: O.y - C.STICK_RADIUS }), { x: 0, y: -1 });
});

test("joystick: a tiny wobble doesn't walk", () => {
  assert.eq(C.stickVector(O, { x: O.x + 5, y: O.y + 3 }), { x: 0, y: 0 });
});

test("joystick: pushing past the edge is still full speed, no faster", () => {
  const v = C.stickVector(O, { x: O.x + C.STICK_RADIUS * 3, y: O.y });
  assert.near(v.x, 1);
  const half = C.stickVector(O, { x: O.x + C.STICK_RADIUS / 2, y: O.y });
  assert.near(half.x, 0.5, 1e-9, "half way is half speed");
});

test("joystick on the left, buttons on the right", () => {
  assert.ok(C.onStickSide(100, 1024));
  assert.notOk(C.onStickSide(900, 1024));
  for (const b of C.buttons(1024, 768)) assert.notOk(C.onStickSide(b.x - b.r, 1024), `${b.action} is clear of the stick side`);
});

test("buttons are big, on screen, and don't overlap", () => {
  const [sword, hammer] = C.buttons(1024, 768);
  assert.eq([sword.action, hammer.action], ["sword", "hammer"]);
  for (const b of [sword, hammer]) {
    assert.ok(b.r * 2 >= 60, "at least 60 px across");
    assert.ok(b.x + b.r <= 1024 && b.y + b.r <= 768 && b.x - b.r >= 0 && b.y - b.r >= 0, `${b.action} on screen`);
  }
  assert.gt(Math.hypot(sword.x - hammer.x, sword.y - hammer.y), sword.r + hammer.r, "apart");
});

test("tapping a button finds it; tapping between finds nothing", () => {
  const list = C.buttons(1024, 768);
  for (const b of list) assert.eq(C.buttonAt(list, { x: b.x, y: b.y }), b.action);
  assert.eq(C.buttonAt(list, { x: 500, y: 100 }), null);
});

test("keys walk and attack", () => {
  assert.eq(C.keyVector(new Set(["ArrowRight"])), { x: 1, y: 0 });
  assert.eq(C.keyVector(new Set(["KeyA", "KeyW"])), { x: -1, y: -1 });
  assert.eq(C.keyVector(new Set()), { x: 0, y: 0 });
  assert.eq(C.keyAction("KeyZ"), "sword");
  assert.eq(C.keyAction("Space"), "sword");
  assert.eq(C.keyAction("KeyX"), "hammer");
  assert.eq(C.keyAction("KeyQ"), null);
});

test("controller: stick and d-pad walk; small wobbles don't", () => {
  assert.eq(C.padVector([1, 0], []), { x: 1, y: 0 });
  assert.eq(C.padVector([0.1, -0.1], []), { x: 0, y: 0 }, "deadzone");
  const dpadUp = []; dpadUp[C.PAD.up] = true;
  assert.eq(C.padVector([0, 0], dpadUp), { x: 0, y: -1 });
});

test("controller: bottom and right swing the sword, left and top spin the hammer, once per press", () => {
  const press = (i) => { const p = []; p[i] = true; return p; };
  assert.eq(C.padActions(press(0), []), ["sword"]);
  assert.eq(C.padActions(press(1), []), ["sword"]);
  assert.eq(C.padActions(press(2), []), ["hammer"]);
  assert.eq(C.padActions(press(3), []), ["hammer"]);
  assert.eq(C.padActions(press(0), press(0)), [], "holding doesn't repeat");
});

test("everything together is never faster than full speed", () => {
  const v = C.combine({ x: 1, y: 0 }, { x: 1, y: 0 }, { x: 0, y: 1 });
  assert.near(Math.hypot(v.x, v.y), 1);
});
