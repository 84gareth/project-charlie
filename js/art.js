// Drawing the street and the hero on a canvas, shape for shape the same as
// the Godot game's placeholder art (archive/godot/scripts/*_art.gd). World
// units throughout; js/main.js sets up the camera before calling these.
import { WORLD_WIDTH, WORLD_HEIGHT, PAVEMENT_TOP, ROAD_TOP } from "./layout.js";

// Godot colours were 0 to 1; these are the same colours.
const rgb = (r, g, b, a = 1) => `rgba(${Math.round(r * 255)}, ${Math.round(g * 255)}, ${Math.round(b * 255)}, ${a})`;
const dark = (c, amount) => c.map((v, i) => (i < 3 ? v * (1 - amount) : v));
const css = (c) => rgb(...c);

// ─── Little drawing helpers ────────────────────────────────────────────────

export function rect(ctx, x, y, w, h, colour) {
  ctx.fillStyle = colour;
  ctx.fillRect(x, y, w, h);
}

export function circle(ctx, x, y, r, colour) {
  ctx.fillStyle = colour;
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI * 2);
  ctx.fill();
}

export function line(ctx, a, b, colour, width) {
  ctx.strokeStyle = colour;
  ctx.lineWidth = width;
  ctx.lineCap = "butt";
  ctx.beginPath();
  ctx.moveTo(a.x, a.y);
  ctx.lineTo(b.x, b.y);
  ctx.stroke();
}

export function ellipse(ctx, x, y, rx, ry, colour) {
  ctx.fillStyle = colour;
  ctx.beginPath();
  ctx.ellipse(x, y, rx, ry, 0, 0, Math.PI * 2);
  ctx.fill();
}

export function polygon(ctx, points, colour) {
  ctx.fillStyle = colour;
  ctx.beginPath();
  ctx.moveTo(points[0][0], points[0][1]);
  for (const [x, y] of points.slice(1)) ctx.lineTo(x, y);
  ctx.closePath();
  ctx.fill();
}

// Godot's ease(x, c) for 0 < c < 1: fast at the start, slowing at the end.
export const easeOut = (x, c) => 1 - Math.pow(1 - x, 1 / c);

// ─── The street ────────────────────────────────────────────────────────────

const SKY = rgb(0.55, 0.8, 0.98);
const PAVEMENT = rgb(0.72, 0.72, 0.74);
const KERB = rgb(0.55, 0.55, 0.58);
const ROAD = rgb(0.3, 0.31, 0.34);
const ROAD_LINE = rgb(0.98, 0.85, 0.2);
const WINDOW = rgb(0.98, 0.95, 0.7);
const BUILDING_COLOURS = [
  [0.9, 0.45, 0.35, 1], [0.95, 0.75, 0.3, 1], [0.45, 0.7, 0.45, 1],
  [0.55, 0.5, 0.85, 1], [0.85, 0.55, 0.75, 1], [0.4, 0.65, 0.8, 1],
];

// A small seeded random number maker, so the street looks the same every
// time (mulberry32).
export function seeded(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// The row of buildings along the whole street: where each one is, how big,
// and its colour (never the same colour twice in a row).
export function buildings() {
  const rand = seeded(5);
  const between = (lo, hi) => lo + Math.floor(rand() * (hi - lo + 1));
  const out = [];
  let x = 0, last = -1;
  while (x < WORLD_WIDTH) {
    const w = between(220, 360), h = between(260, 460);
    const pick = (last + between(1, BUILDING_COLOURS.length - 1)) % BUILDING_COLOURS.length;
    last = pick;
    out.push({ x, w, h, colour: BUILDING_COLOURS[pick] });
    x += w;
  }
  return out;
}
const BUILDINGS = buildings();

// The part of the street from `left` to `left + width`.
export function drawStreet(ctx, left, width) {
  const right = left + width;
  rect(ctx, left, 0, width, PAVEMENT_TOP, SKY);
  for (const b of BUILDINGS) {
    if (b.x + b.w < left || b.x > right) continue;
    const top = PAVEMENT_TOP - b.h;
    rect(ctx, b.x, top, b.w - 8, b.h, css(b.colour));
    // Windows stop above the door.
    for (let wy = top + 30; wy < PAVEMENT_TOP - 150; wy += 80) {
      for (let wx = b.x + 28; wx < b.x + b.w - 60; wx += 70) rect(ctx, wx, wy, 36, 44, WINDOW);
    }
    rect(ctx, b.x + b.w / 2 - 30, PAVEMENT_TOP - 90, 60, 90, css(dark(b.colour, 0.45)));
  }
  rect(ctx, left, PAVEMENT_TOP, width, ROAD_TOP - PAVEMENT_TOP, PAVEMENT);
  rect(ctx, left, ROAD_TOP - 10, width, 10, KERB);
  rect(ctx, left, ROAD_TOP, width, WORLD_HEIGHT - ROAD_TOP, ROAD);
  const lineY = (ROAD_TOP + WORLD_HEIGHT) / 2;
  for (let x = Math.floor(left / 200) * 200; x < right; x += 200) rect(ctx, x + 40, lineY - 6, 110, 12, ROAD_LINE);
}

// ─── The hero ──────────────────────────────────────────────────────────────

const SKIN = rgb(0.96, 0.78, 0.62);
const SHIRT_C = [0.15, 0.55, 0.95, 1];
const SHIRT = css(SHIRT_C);
const SLEEVE = css(dark(SHIRT_C, 0.2));
const TROUSERS = rgb(0.2, 0.22, 0.35);
const SHOES = rgb(0.1, 0.1, 0.12);
const HAIR = rgb(0.4, 0.25, 0.12);
const BLADE = rgb(0.85, 0.9, 0.95);
const GRIP = rgb(0.45, 0.28, 0.12);
const GOLD = rgb(0.95, 0.75, 0.2);
const HAMMER_HEAD = rgb(0.45, 0.47, 0.52);
const SWOOSH = "rgba(255, 255, 255, 0.55)";
const BOBBLE = rgb(0.98, 0.35, 0.65);
const SHADOW = "rgba(0, 0, 0, 0.28)";

// Where the spinning hammer circles, around the hero's middle.
export const SPIN_CENTRE = { x: 0, y: -95 };
export const SPIN_RADIUS = { x: 150, y: 45 };
export const SPIN_TURNS = 2;

// The hero: feet at (h.x, h.y), facing h.facing (1 right, -1 left).
//   h.look "boy" or "girl", h.stepTime (walk swing), h.attack ("" or
//   "sword" or "hammer") with h.progress (0 to 1), h.down (lying down),
//   h.alpha (blinking), now (seconds, for the dizzy stars).
export function drawHero(ctx, h, now = 0) {
  ctx.save();
  ctx.translate(h.x, h.y);
  ctx.globalAlpha = h.alpha ?? 1;
  ellipse(ctx, 0, 0, h.down ? 110 : 44, (h.down ? 110 : 44) * 0.3, SHADOW);
  ctx.scale(h.facing, 1);
  if (h.down) {
    drawLyingDown(ctx, h, now);
    ctx.restore();
    return;
  }
  const spinning = h.attack === "hammer";
  const spinAngle = (h.progress || 0) * SPIN_TURNS * Math.PI * 2;
  if (spinning) {
    drawSpinRing(ctx);
    if (Math.sin(spinAngle) < 0) drawSpinningHammer(ctx, spinAngle);
  } else {
    drawHammerOnBack(ctx);
  }
  const swing = Math.sin(h.stepTime || 0) * 14;
  // Back leg, then front leg.
  rect(ctx, -20 - swing, -64, 16, 58, TROUSERS);
  rect(ctx, -24 - swing, -8, 24, 8, SHOES);
  rect(ctx, 4 + swing, -64, 16, 58, TROUSERS);
  rect(ctx, 4 + swing, -8, 24, 8, SHOES);
  // Body.
  rect(ctx, -28, -138, 56, 78, SHIRT);
  // Head, hair and eye.
  circle(ctx, 0, -168, 30, SKIN);
  drawHair(ctx, h.look);
  circle(ctx, 14, -172, 4.5, "#000");
  if (spinning) {
    if (Math.sin(spinAngle) >= 0) drawSpinningHammer(ctx, spinAngle);
  } else {
    drawSwordArm(ctx, h, swing);
  }
  ctx.restore();
}

// Short hair for the boy; for the girl, Charlie's two pigtails, one each
// side, with pink bobbles.
function drawHair(ctx, look) {
  rect(ctx, -32, -202, 58, 20, HAIR);
  if (look !== "girl") return;
  for (const side of [-1, 1]) {
    const bx = side * 33, by = -186;
    circle(ctx, bx + side * 16, by + 14, 15, HAIR);
    circle(ctx, bx + side * 20, by + 34, 11, HAIR);
    circle(ctx, bx, by, 7, BOBBLE);
  }
}

// The arm holding the sword. Idle, the sword points up and forward; a
// sword attack sweeps it from over the shoulder down to the front.
function drawSwordArm(ctx, h, walkSwing) {
  const shoulder = { x: 0, y: -126 };
  let hand, angle;
  if (h.attack === "sword") {
    const t = easeOut(h.progress || 0, 0.4);
    const from = (-120 * Math.PI) / 180, to = (25 * Math.PI) / 180;
    angle = from + (to - from) * t;
    hand = { x: shoulder.x + Math.cos(angle) * 46, y: shoulder.y + Math.sin(angle) * 46 };
    // The swoosh the blade leaves behind it.
    ctx.strokeStyle = SWOOSH;
    ctx.lineWidth = 18;
    ctx.beginPath();
    ctx.arc(shoulder.x, shoulder.y, 150, from, angle);
    ctx.stroke();
  } else {
    angle = (-60 * Math.PI) / 180;
    hand = { x: 10 - walkSwing * 0.6, y: -72 };
  }
  line(ctx, shoulder, hand, SLEEVE, 16);
  const d = { x: Math.cos(angle), y: Math.sin(angle) };
  const s = { x: -d.y, y: d.x };
  const at = (k, sk = 0) => ({ x: hand.x + d.x * k + s.x * sk, y: hand.y + d.y * k + s.y * sk });
  // Grip, gold guard, then the blade.
  line(ctx, at(-16), at(8), GRIP, 9);
  line(ctx, at(8, -16), at(8, 16), GOLD, 7);
  line(ctx, at(10), at(100), BLADE, 12);
  circle(ctx, hand.x, hand.y, 9, SKIN);
}

function drawHammerOnBack(ctx) {
  line(ctx, { x: -20, y: -70 }, { x: -44, y: -170 }, GRIP, 9);
  rect(ctx, -72, -196, 56, 34, HAMMER_HEAD);
}

// A faint ring on the street where the hammer is sweeping.
function drawSpinRing(ctx) {
  ctx.strokeStyle = SWOOSH;
  ctx.lineWidth = 14;
  ctx.beginPath();
  ctx.ellipse(SPIN_CENTRE.x, SPIN_CENTRE.y, SPIN_RADIUS.x, SPIN_RADIUS.y, 0, 0, Math.PI * 2);
  ctx.stroke();
}

function drawSpinningHammer(ctx, angle) {
  const head = {
    x: SPIN_CENTRE.x + Math.cos(angle) * SPIN_RADIUS.x,
    y: SPIN_CENTRE.y + Math.sin(angle) * SPIN_RADIUS.y,
  };
  line(ctx, SPIN_CENTRE, head, GRIP, 10);
  circle(ctx, SPIN_CENTRE.x, SPIN_CENTRE.y, 10, SKIN);
  rect(ctx, head.x - 34, head.y - 24, 68, 48, HAMMER_HEAD);
}

// Flat on the street, head to the back, with dizzy stars circling.
function drawLyingDown(ctx, h, now) {
  ctx.save();
  ctx.translate(100, -30);
  ctx.rotate(-Math.PI / 2);
  rect(ctx, -20, -64, 16, 58, TROUSERS);
  rect(ctx, 4, -64, 16, 58, TROUSERS);
  rect(ctx, -28, -138, 56, 78, SHIRT);
  circle(ctx, 0, -168, 30, SKIN);
  drawHair(ctx, h.look);
  ctx.restore();
  const t = now * 4;
  for (let i = 0; i < 3; i++) {
    const a = t + (i * Math.PI * 2) / 3;
    circle(ctx, -68 + Math.cos(a) * 40, -80 + Math.sin(a) * 12, 8, GOLD);
  }
}

// ─── Charlie's bugs (simple shapes from his drawings, until their real
//     pictures are made) ───────────────────────────────────────────────────

const BUG_INK = "#1c1a24";
const WHITE = "#ffffff";

// A baddie: b.x, b.y is its spot on the street; b.kind, b.facing,
// b.hurt (wobbling, drawn pale), b.sink (0 to 1, into the ground),
// b.hover (how high it floats).
export function drawBaddie(ctx, b, now = 0) {
  const sink = b.sink || 0;
  // Fliers drop to the street as they're beaten, then sink.
  const lift = (b.hover || 0) * (1 - Math.min(1, sink * 3)) + Math.sin(now * 5 + b.x * 0.01) * (b.hover ? 6 : 0);
  ctx.save();
  ctx.translate(b.x, b.y);
  const hole = sink > 0 ? `rgba(26, 20, 31, ${0.3 + sink * 0.6})` : "rgba(0, 0, 0, 0.25)";
  ellipse(ctx, 0, 0, 46 + sink * 10, (46 + sink * 10) * 0.3, hole);
  // Everything below the street line is hidden, so sinking looks right.
  ctx.beginPath();
  ctx.rect(-400, -600, 800, 600);
  ctx.clip();
  const wobble = b.hurt ? Math.sin(now * 60) * 6 : 0;
  ctx.translate(wobble, -lift + sink * 220);
  ctx.scale(b.facing || 1, 1);
  if (b.hurt) ctx.globalAlpha = 0.55;
  const pic = BUG_PICTURES[b.kind];
  if (pic && pic.complete && pic.naturalWidth > 0) {
    // Charlie's own drawing, just as he drew it, swaying a little.
    const h = BUG_HEIGHT[b.kind];
    const w = (h * pic.naturalWidth) / pic.naturalHeight;
    ctx.rotate(Math.sin(now * 3 + b.x * 0.02) * 0.05);
    ctx.drawImage(pic, -w / 2, -h, w, h);
  } else if (b.kind === "house_bug") drawHouseBug(ctx, now);
  else if (b.kind === "acorn") drawAcorn(ctx, now);
  else drawTeleportBug(ctx, now);
  ctx.restore();
}

// Charlie's drawings of his bugs, cut out of the paper by
// tools/image-fix/cutout.gd (Gareth, 2026-10-25: "put Charlie's drawings
// in as they are"). Until a picture has loaded, the simple shapes below
// stand in.
export const BUG_HEIGHT = { house_bug: 170, acorn: 160, teleport_bug: 210 };
const BUG_PICTURES = {};

export function loadBugPictures(version) {
  for (const kind of Object.keys(BUG_HEIGHT)) {
    const img = new Image();
    img.src = `assets/baddies/${kind}.png?v=${version}`;
    BUG_PICTURES[kind] = img;
  }
  return BUG_PICTURES;
}

// Black square body, two striped pale blue wings, five dangly tentacles.
function drawHouseBug(ctx, now) {
  const flap = Math.sin(now * 18) * 0.25;
  for (const side of [-1, 1]) {
    ctx.save();
    ctx.translate(side * 22, -95);
    ctx.rotate(side * (0.6 + flap));
    ellipse(ctx, 0, -42, 22, 46, "rgba(170, 205, 245, 0.9)");
    ctx.strokeStyle = BUG_INK;
    ctx.lineWidth = 5;
    ctx.beginPath();
    ctx.ellipse(0, -42, 22, 46, 0, 0, Math.PI * 2);
    ctx.stroke();
    for (const y of [-70, -52, -34, -16]) line(ctx, { x: -20, y }, { x: 20, y: y - 6 }, BUG_INK, 4);
    ctx.restore();
  }
  for (let i = 0; i < 5; i++) {
    const x = -24 + i * 12;
    const sway = Math.sin(now * 4 + i) * 8;
    ctx.strokeStyle = BUG_INK;
    ctx.lineWidth = 6;
    ctx.lineCap = "round";
    ctx.beginPath();
    ctx.moveTo(x, -78);
    ctx.quadraticCurveTo(x + sway, -40, x + sway * 1.5, -8);
    ctx.stroke();
  }
  rect(ctx, -30, -122, 60, 50, BUG_INK);
  circle(ctx, 8, -102, 6, WHITE);
  circle(ctx, 22, -102, 6, WHITE);
}

// A brown acorn with a dark cap, two rounded wings and five thin legs.
function drawAcorn(ctx, now) {
  const flap = Math.sin(now * 14) * 0.2;
  for (let i = 0; i < 5; i++) {
    const x = -16 + i * 8;
    line(ctx, { x, y: -40 }, { x: x + (i - 2) * 9, y: -2 }, BUG_INK, 5);
  }
  for (const side of [-1, 1]) {
    ctx.save();
    ctx.translate(side * 30, -110);
    ctx.rotate(side * (0.15 + flap));
    ellipse(ctx, side * 30, 0, 34, 18, "#8a4b38");
    ctx.strokeStyle = BUG_INK;
    ctx.lineWidth = 5;
    ctx.beginPath();
    ctx.ellipse(side * 30, 0, 34, 18, 0, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();
  }
  ctx.fillStyle = "#9a5440";
  ctx.strokeStyle = BUG_INK;
  ctx.lineWidth = 6;
  ctx.beginPath();
  ctx.moveTo(0, -38);
  ctx.bezierCurveTo(-46, -70, -44, -140, 0, -150);
  ctx.bezierCurveTo(44, -140, 46, -70, 0, -38);
  ctx.fill();
  ctx.stroke();
  rect(ctx, -26, -170, 52, 24, "#3a2a22");
  rect(ctx, -4, -182, 8, 14, "#3a2a22");
  circle(ctx, 4, -112, 5, BUG_INK);
  circle(ctx, 18, -112, 5, BUG_INK);
  line(ctx, { x: 2, y: -124 }, { x: 12, y: -120 }, BUG_INK, 4);
  line(ctx, { x: 22, y: -124 }, { x: 14, y: -120 }, BUG_INK, 4);
}

// A tall leaning purple body with a dark band at the top and two arms.
function drawTeleportBug(ctx, now) {
  const sway = Math.sin(now * 3) * 0.05;
  ctx.save();
  ctx.rotate(0.12 + sway);
  for (const side of [-1, 1]) {
    ctx.save();
    ctx.translate(side * 22, -130);
    ctx.rotate(side * 0.7);
    ellipse(ctx, side * 18, -14, 26, 16, "#5b2fc4");
    ctx.strokeStyle = BUG_INK;
    ctx.lineWidth = 5;
    ctx.beginPath();
    ctx.ellipse(side * 18, -14, 26, 16, 0, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();
  }
  ctx.fillStyle = "#5b2fc4";
  ctx.strokeStyle = BUG_INK;
  ctx.lineWidth = 6;
  ctx.beginPath();
  ctx.roundRect(-26, -200, 52, 196, 26);
  ctx.fill();
  ctx.stroke();
  rect(ctx, -23, -180, 46, 16, "#2a1660");
  circle(ctx, 4, -150, 5, WHITE);
  circle(ctx, 16, -150, 5, WHITE);
  ctx.restore();
}

// ─── Gems ──────────────────────────────────────────────────────────────────

const GEM_FACE = rgb(0.98, 0.35, 0.65);
const GEM_LIGHT = rgb(1, 0.7, 0.85);

// A shiny pink diamond with a sparkle at (x, y), `size` times normal.
export function drawGemShape(ctx, x, y, size = 1) {
  ctx.save();
  ctx.translate(x, y);
  ctx.scale(size, size);
  polygon(ctx, [[0, -26], [22, -6], [0, 26], [-22, -6]], GEM_FACE);
  polygon(ctx, [[0, -26], [22, -6], [0, -6], [-22, -6]], GEM_LIGHT);
  circle(ctx, -7, -14, 4, "rgba(255, 255, 255, 0.9)");
  ctx.restore();
}

// A gem lying on the street, bobbing gently over its shadow.
export function drawGem(ctx, g, now = 0) {
  ellipse(ctx, g.x, g.y, 22, 22 * 0.3, "rgba(0, 0, 0, 0.25)");
  drawGemShape(ctx, g.x, g.y - 30 - Math.sin(now * 5 + g.x) * 8);
}
