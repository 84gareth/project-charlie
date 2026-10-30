// Collects fingers, keys and the game controller from the page. The rules
// for what they mean live in js/controls.js; this file only listens.
import * as C from "./controls.js";

export function createInput(canvas, win = window) {
  const held = new Set();     // key codes held down
  const presses = [];         // attacks started since the last takePresses()
  let stick = null;           // { id, origin, point } while a thumb is down
  const buttonFingers = new Map();  // pointerId -> "sword" or "hammer"
  let padBefore = [];
  let padDir = { x: 0, y: 0 };
  let touchSeen = (win.navigator.maxTouchPoints || 0) > 0;

  const size = () => ({ w: canvas.clientWidth, h: canvas.clientHeight });
  const where = (e) => {
    const box = canvas.getBoundingClientRect();
    return { x: e.clientX - box.left, y: e.clientY - box.top };
  };

  win.addEventListener("keydown", (e) => {
    const action = C.keyAction(e.code);
    const walkKey = ["left", "right", "up", "down"].some((k) => C.KEYS[k].includes(e.code));
    if (action || walkKey) e.preventDefault();
    if (e.repeat) return;
    held.add(e.code);
    if (action) presses.push(action);
  });
  win.addEventListener("keyup", (e) => held.delete(e.code));
  win.addEventListener("blur", () => held.clear());

  canvas.addEventListener("pointerdown", (e) => {
    if (e.pointerType === "touch") touchSeen = true;
    const p = where(e);
    const { w, h } = size();
    const action = C.buttonAt(C.buttons(w, h), p);
    if (action) {
      presses.push(action);
      buttonFingers.set(e.pointerId, action);
    } else if (C.onStickSide(p.x, w) && !stick) {
      stick = { id: e.pointerId, origin: p, point: p };
    }
    try { canvas.setPointerCapture(e.pointerId); } catch { /* fine without */ }
    e.preventDefault();
  });
  canvas.addEventListener("pointermove", (e) => {
    if (stick && stick.id === e.pointerId) stick.point = where(e);
  });
  const lift = (e) => {
    if (stick && stick.id === e.pointerId) stick = null;
    buttonFingers.delete(e.pointerId);
  };
  canvas.addEventListener("pointerup", lift);
  canvas.addEventListener("pointercancel", lift);

  // Read the game controller; call once per frame.
  function poll() {
    const pads = win.navigator.getGamepads ? win.navigator.getGamepads() : [];
    const pad = [...pads].find((p) => p && p.connected);
    if (!pad) { padDir = { x: 0, y: 0 }; padBefore = []; return; }
    const pressed = pad.buttons.map((b) => b.pressed);
    padDir = C.padVector(pad.axes, pressed);
    presses.push(...C.padActions(pressed, padBefore));
    padBefore = pressed;
  }

  return {
    poll,
    // Where the player wants to walk: length 0 to 1.
    direction() {
      const thumb = stick ? C.stickVector(stick.origin, stick.point) : { x: 0, y: 0 };
      return C.combine(C.keyVector(held), thumb, padDir);
    },
    // Attacks started since last asked, oldest first.
    takePresses() { return presses.splice(0); },
    // For drawing the on-screen controls.
    get stick() { return stick; },
    buttonsDown() { return new Set(buttonFingers.values()); },
    showTouch() { return touchSeen; },
  };
}
