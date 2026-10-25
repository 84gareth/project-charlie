// What the player's fingers, keys and game controller mean, as pure rules.
// The page (js/input.js) collects the raw touches and presses; these
// functions turn them into a walking direction and attack buttons.

// ─── On-screen joystick (left half of the screen) ──────────────────────────
// It appears wherever the thumb lands, so a small hand can't miss it.
export const STICK_RADIUS = 70;      // screen px from the middle to the edge
export const STICK_DEADZONE = 0.2;   // a tiny wobble doesn't walk

// The walking direction for a thumb that went down at `origin` and is now
// at `point`: length 0 to 1, pointing where the thumb has moved.
export function stickVector(origin, point) {
  const dx = point.x - origin.x, dy = point.y - origin.y;
  const len = Math.hypot(dx, dy);
  if (len < STICK_DEADZONE * STICK_RADIUS) return { x: 0, y: 0 };
  const reach = Math.max(len, STICK_RADIUS);
  return { x: dx / reach, y: dy / reach };
}

// The thumb can start the joystick anywhere in the left part of the
// screen; the right part holds the attack buttons.
export const STICK_SIDE = 0.5;
export const onStickSide = (x, screenW) => x < screenW * STICK_SIDE;

// ─── On-screen attack buttons (bottom right) ───────────────────────────────
// Big round buttons: sword in the corner, hammer beside it.
export const BUTTON_RADIUS = 62;
export function buttons(screenW, screenH) {
  const margin = 28;
  const r = BUTTON_RADIUS;
  return [
    { action: "sword", x: screenW - margin - r, y: screenH - margin - r - 40, r },
    { action: "hammer", x: screenW - margin - r * 3 - 24, y: screenH - margin - r, r },
  ];
}

// Which button (if any) a touch at `p` lands on. A little generous, for
// small fingers.
export function buttonAt(list, p) {
  for (const b of list) if (Math.hypot(p.x - b.x, p.y - b.y) <= b.r * 1.15) return b.action;
  return null;
}

// ─── Keyboard (for trying it on the Mac) ───────────────────────────────────
export const KEYS = {
  left: ["ArrowLeft", "KeyA"], right: ["ArrowRight", "KeyD"],
  up: ["ArrowUp", "KeyW"], down: ["ArrowDown", "KeyS"],
  sword: ["KeyZ", "KeyJ", "Space"], hammer: ["KeyX", "KeyK"],
};

// The walking direction from the keys held down (a Set of key codes).
export function keyVector(held) {
  const on = (name) => KEYS[name].some((k) => held.has(k));
  return { x: (on("right") ? 1 : 0) - (on("left") ? 1 : 0), y: (on("down") ? 1 : 0) - (on("up") ? 1 : 0) };
}

// The attack a key starts, or null.
export function keyAction(code) {
  if (KEYS.sword.includes(code)) return "sword";
  if (KEYS.hammer.includes(code)) return "hammer";
  return null;
}

// ─── Game controller (Xbox or Switch, which iPads support) ─────────────────
// Browsers' "standard" layout: stick on axes 0 and 1, d-pad on buttons
// 12 to 15. Face buttons by place, so Xbox and Switch match: bottom and
// right swing the sword, left and top spin the hammer.
export const PAD_DEADZONE = 0.3;
export const PAD = { sword: [0, 1], hammer: [2, 3], up: 12, down: 13, left: 14, right: 15 };

export function padVector(axes, pressed) {
  let x = Math.abs(axes[0] || 0) >= PAD_DEADZONE ? axes[0] : 0;
  let y = Math.abs(axes[1] || 0) >= PAD_DEADZONE ? axes[1] : 0;
  if (pressed[PAD.left]) x = -1;
  if (pressed[PAD.right]) x = 1;
  if (pressed[PAD.up]) y = -1;
  if (pressed[PAD.down]) y = 1;
  return { x, y };
}

// Attacks started this frame: buttons down now that weren't last frame.
export function padActions(pressed, before) {
  const out = [];
  for (const action of ["sword", "hammer"]) {
    if (PAD[action].some((i) => pressed[i] && !before[i])) out.push(action);
  }
  return out;
}

// Everything added up, never longer than 1.
export function combine(...dirs) {
  let x = 0, y = 0;
  for (const d of dirs) { x += d.x; y += d.y; }
  const len = Math.hypot(x, y);
  return len > 1 ? { x: x / len, y: y / len } : { x, y };
}
