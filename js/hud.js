// Things drawn on top of the street in screen pixels, not world units: the
// on-screen joystick and the sword and hammer buttons.
import { STICK_RADIUS, buttons } from "./controls.js";
import { circle, line, rect } from "./art.js";

const RING = "rgba(255, 255, 255, 0.35)";
const KNOB = "rgba(255, 255, 255, 0.7)";
const BUTTON = "rgba(30, 32, 48, 0.55)";
const BUTTON_DOWN = "rgba(242, 193, 78, 0.85)";
const EDGE = "rgba(255, 255, 255, 0.8)";

// `stick` is { origin, point } while a thumb is down, or null; then a faint
// joystick shows where to put a thumb.
export function drawControls(ctx, w, h, stick, down) {
  const home = { x: 130, y: h - 130 };
  const origin = stick ? stick.origin : home;
  ctx.globalAlpha = stick ? 1 : 0.5;
  ctx.lineWidth = 6;
  ctx.strokeStyle = RING;
  ctx.beginPath();
  ctx.arc(origin.x, origin.y, STICK_RADIUS, 0, Math.PI * 2);
  ctx.stroke();
  let knob = origin;
  if (stick) {
    const dx = stick.point.x - origin.x, dy = stick.point.y - origin.y;
    const len = Math.hypot(dx, dy), k = len > STICK_RADIUS ? STICK_RADIUS / len : 1;
    knob = { x: origin.x + dx * k, y: origin.y + dy * k };
  }
  circle(ctx, knob.x, knob.y, 34, KNOB);
  ctx.globalAlpha = 1;

  for (const b of buttons(w, h)) {
    circle(ctx, b.x, b.y, b.r, down.has(b.action) ? BUTTON_DOWN : BUTTON);
    ctx.lineWidth = 5;
    ctx.strokeStyle = EDGE;
    ctx.beginPath();
    ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
    ctx.stroke();
    if (b.action === "sword") drawSwordIcon(ctx, b.x, b.y);
    else drawHammerIcon(ctx, b.x, b.y);
  }
}

// Pictures, not words, on the buttons.
function drawSwordIcon(ctx, x, y) {
  line(ctx, { x: x - 26, y: y + 26 }, { x: x + 24, y: y - 24 }, "#d9e6f2", 12);
  line(ctx, { x: x - 22, y: y + 6 }, { x: x - 6, y: y + 22 }, "#f2bf33", 8);
  line(ctx, { x: x - 30, y: y + 30 }, { x: x - 20, y: y + 20 }, "#73471f", 9);
}

function drawHammerIcon(ctx, x, y) {
  line(ctx, { x: x - 22, y: y + 28 }, { x: x + 8, y: y - 8 }, "#73471f", 9);
  ctx.save();
  ctx.translate(x + 10, y - 12);
  ctx.rotate(Math.PI / 4);
  rect(ctx, -26, -15, 52, 30, "#737885");
  ctx.restore();
}
