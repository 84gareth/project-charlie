// The game page: one city street and the hero walking along it, swinging
// the sword and spinning the hammer. Runs the loop, draws, and hands
// touches and keys to the rules.
//
// For tests: window.game is the game's state and window.gameTick(dt) steps
// it by hand; with ?manual=1 in the address the game doesn't run by itself.
import { GAME_NAME, VERSION } from "./version.js";
import { WALK_AREA, HERO_START, view, cameraX } from "./layout.js";
import * as Walk from "./walk.js";
import { AttackState } from "./attacks.js";
import { drawStreet, drawHero } from "./art.js";
import { drawControls } from "./hud.js";
import { createInput } from "./input.js";
import { options } from "./playtest.js";

const opts = options(location.search);
const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");
const input = createInput(canvas);

const game = {
  mode: opts.mode,
  time: 0,
  camX: 0,
  hero: {
    x: HERO_START.x, y: HERO_START.y, facing: 1, look: opts.hero || "boy",
    moving: false, stepTime: 0, attack: "", progress: 0,
  },
  attack: new AttackState(),
  // Counts up with every attack, so a baddie is hit once per swing or spin.
  attackId: 0,
};

export function tick(dt) {
  game.time += dt;
  input.poll();
  // A press while an attack is going is ignored (no queueing up).
  for (const kind of input.takePresses()) {
    if (game.attack.start(kind)) game.attackId += 1;
  }
  game.attack.update(dt);
  const h = game.hero;
  h.attack = game.attack.kind;
  h.progress = game.attack.progress();
  // Standing still while attacking.
  const dir = game.attack.busy() ? { x: 0, y: 0 } : input.direction();
  const next = Walk.step(h, dir, dt, WALK_AREA);
  h.x = next.x;
  h.y = next.y;
  h.facing = Walk.facing(h.facing, dir.x);
  h.moving = Math.hypot(dir.x, dir.y) > 0.1;
  h.stepTime = h.moving ? h.stepTime + dt * 12 : 0;
  // The camera glides after the hero.
  const v = view(canvas.clientWidth, canvas.clientHeight);
  const target = cameraX(h.x, v.width);
  game.camX += (target - game.camX) * Math.min(1, dt * 6);
}

function draw() {
  const dpr = window.devicePixelRatio || 1;
  const w = canvas.clientWidth, h = canvas.clientHeight;
  if (canvas.width !== Math.round(w * dpr) || canvas.height !== Math.round(h * dpr)) {
    canvas.width = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
  }
  const v = view(w, h);
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.fillStyle = "#8cccfa";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.setTransform(dpr * v.scale, 0, 0, dpr * v.scale, -game.camX * dpr * v.scale, v.top * dpr);
  drawStreet(ctx, game.camX, v.width);
  drawHero(ctx, game.hero, game.time);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  if (input.showTouch()) drawControls(ctx, w, h, input.stick, input.buttonsDown());
}

let last = performance.now();
function frame(now) {
  tick(Math.min(0.05, (now - last) / 1000));
  last = now;
  draw();
  requestAnimationFrame(frame);
}

document.title = GAME_NAME;
document.getElementById("version").textContent = "v" + VERSION;
game.camX = cameraX(game.hero.x, view(canvas.clientWidth, canvas.clientHeight).width);
window.game = game;
window.gameTick = (dt) => { tick(dt); draw(); };
if (opts.manual) draw();
else requestAnimationFrame(frame);
