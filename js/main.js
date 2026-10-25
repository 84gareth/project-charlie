// The game page: one city street, the hero swinging the sword and
// spinning the hammer, and waves of Charlie's three bugs that punch back
// and sink into the ground leaving a gem each. Beat a wave and another
// comes. Out of hearts: the hero falls down, the fight starts again with
// full hearts, and the gems are kept. Runs the loop, draws, and hands
// touches and keys to the rules.
//
// For tests: window.game is the game's state and window.gameTick(dt) steps
// it by hand; with ?manual=1 in the address the game doesn't run by itself.
import { GAME_NAME, VERSION } from "./version.js";
import { WALK_AREA, HERO_START, view, cameraX } from "./layout.js";
import * as Walk from "./walk.js";
import { AttackState, hits } from "./attacks.js";
import { DAMAGE, FIRST_PUNCH, STAGGER } from "./baddie_brain.js";
import { Baddie, HOVER } from "./baddies.js";
import * as Waves from "./waves.js";
import { touching } from "./gems.js";
import { FightState, MAX_HEARTS, DOWN_TIME, bumpedX } from "./fight.js";
import { drawStreet, drawHero, drawBaddie, drawGem, loadBugPictures } from "./art.js";
import { drawControls, drawGemCounter, drawHearts } from "./hud.js";
import { createInput } from "./input.js";
import { options } from "./playtest.js";

const opts = options(location.search);
const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");
const input = createInput(canvas);
const bugPictures = loadBugPictures(VERSION);

const game = {
  mode: opts.mode,
  time: 0,
  camX: 0,
  hero: {
    x: HERO_START.x, y: HERO_START.y, facing: 1, look: opts.hero || "boy",
    moving: false, stepTime: 0, attack: "", progress: 0, down: false, alpha: 1,
  },
  attack: new AttackState(),
  // Counts up with every attack, so a baddie is hit once per swing or spin.
  attackId: 0,
  // Hearts and gems.
  fight: new FightState(),
  get gems() { return game.fight.gems; },
  set gems(v) { game.fight.gems = v; },
  // Seconds left lying down after running out of hearts.
  downLeft: 0,
  // Bugs on the street (including ones sinking), and gems lying there.
  baddies: [],
  looseGems: [],
  // Tests turn this off to place bugs themselves; practice mode too.
  wavesOn: opts.mode !== "practice",
  waveWait: 0,
  // For tests and playtesting: put a bug on the street.
  spawnBaddie(kind, x, y, lane = 0) {
    const b = new Baddie(kind, x, y, lane);
    game.baddies.push(b);
    return b;
  },
  startWave(startDist = Waves.OFFSCREEN) {
    game.waveWait = 0;
    Waves.spawnPoints(game.hero.x, WALK_AREA, Waves.SIZE, startDist).forEach((p, i) => {
      const b = game.spawnBaddie(Waves.kind(i), p.x, p.y, Waves.lane(i));
      b.punchWait = FIRST_PUNCH + i * STAGGER;
    });
  },
};

export function tick(dt) {
  game.time += dt;
  input.poll();
  const h = game.hero;
  game.fight.update(dt);
  // Blinking for a moment after a punch.
  h.alpha = game.fight.isSafe() && !h.down && Math.floor(game.time * 10) % 2 === 0 ? 0.35 : 1;
  if (h.down) {
    input.takePresses();   // no attacking while lying down
    game.downLeft -= dt;
    if (game.downLeft <= 0) {
      h.down = false;
      game.fight.restartFight();
    }
    followWithCamera(dt);
    return;
  }

  // A press while an attack is going is ignored (no queueing up).
  for (const kind of input.takePresses()) {
    if (game.attack.start(kind)) game.attackId += 1;
  }
  game.attack.update(dt);
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

  hitBaddies();
  for (const b of game.baddies) {
    const event = b.update(dt, h, WALK_AREA);
    if (event === "sunk") game.looseGems.push({ x: b.x, y: b.y });
    if (event === "punch") punched(b);
    if (h.down) break;
  }
  game.baddies = game.baddies.filter((b) => b.state !== "gone");
  pickUpGems();
  if (game.wavesOn && game.baddies.length === 0 && !h.down) {
    game.waveWait += dt;
    if (game.waveWait >= Waves.PAUSE) game.startWave();
  }
  followWithCamera(dt);
}

// The camera glides after the hero.
function followWithCamera(dt) {
  const v = view(canvas.clientWidth, canvas.clientHeight);
  const target = cameraX(game.hero.x, v.width);
  game.camX += (target - game.camX) * Math.min(1, dt * 6);
}

function hitBaddies() {
  if (!game.attack.canHit()) return;
  const kind = game.attack.kind;
  for (const b of game.baddies) {
    if (b.alive() && hits(kind, game.hero, game.hero.facing, b)) {
      b.takeHit(DAMAGE[kind], game.attackId, game.hero.x, WALK_AREA);
    }
  }
}

// A bug's punch landed: a heart goes and the hero is bumped back.
function punched(b) {
  const h = game.hero;
  if (h.down || !game.fight.takeHit()) return;
  h.x = bumpedX(h.x, h.facing, b.x, WALK_AREA);
  if (game.fight.outOfHearts()) fallDown();
}

// Out of hearts: the hero lies down and this fight's bugs go away. Then
// up again with full hearts, every gem kept, and the fight starts over.
function fallDown() {
  const h = game.hero;
  h.down = true;
  h.attack = "";
  game.attack = new AttackState();
  game.downLeft = DOWN_TIME;
  game.baddies = [];
  game.waveWait = 0;
}

function pickUpGems() {
  const before = game.looseGems.length;
  game.looseGems = game.looseGems.filter((g) => !touching(game.hero, g));
  for (let i = game.looseGems.length; i < before; i++) game.fight.addGem();
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
  // Back of the street first, so nearer things stand in front.
  const things = [
    ...game.looseGems.map((g) => ({ y: g.y, draw: () => drawGem(ctx, g, game.time) })),
    ...game.baddies.map((b) => ({ y: b.y, draw: () => drawBaddie(ctx, {
      x: b.x, y: b.y, kind: b.kind, facing: b.facing, hurt: b.state === "hurt",
      pose: b.state === "windup" || b.state === "punch" ? b.state : "",
      sink: b.sinkAmount(), hover: HOVER[b.kind],
      pop: b.popScale(), drop: b.drop, sparkle: b.teleporting(),
    }, game.time) })),
    { y: game.hero.y, draw: () => drawHero(ctx, game.hero, game.time) },
  ].sort((a, b) => a.y - b.y);
  for (const t of things) t.draw();
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  drawGemCounter(ctx, game.gems);
  drawHearts(ctx, game.fight.hearts, MAX_HEARTS);
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
if (opts.mode === "fight") game.startWave(Waves.CLOSE);
window.game = game;
window.bugPictures = bugPictures;
window.gameTick = (dt) => { tick(dt); draw(); };
if (opts.manual) draw();
else requestAnimationFrame(frame);
