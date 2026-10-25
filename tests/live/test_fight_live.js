// The real fight: Charlie's bugs arrive, walk up, take two hits, sink into
// the ground, leave a gem; walking onto it adds 10; the next wave comes.
// The same checks as the Godot game's test_fight_live.gd.
import { test, assert, openPage, until } from "../framework.js";
import { HP, SINK_TIME } from "../../js/baddie_brain.js";
import * as Waves from "../../js/waves.js";
import { DURATION } from "../../js/attacks.js";

async function start(query = "") {
  const page = await openPage("../index.html?manual=1" + query, 1024, 768);
  await until(() => page.game !== undefined, "page script ran", 15000);
  return page;
}

const run = (page, seconds) => { for (let t = 0; t < seconds; t += 1 / 60) page.gameTick(1 / 60); };
function swing(page, code) {
  page.dispatchEvent(new page.KeyboardEvent("keydown", { code, bubbles: true }));
  page.dispatchEvent(new page.KeyboardEvent("keyup", { code, bubbles: true }));
  run(page, DURATION[code === "KeyZ" ? "sword" : "hammer"] + 0.05);
}

test("the first wave arrives after a pause, one of each bug, and walks closer", async () => {
  const page = await start();
  run(page, Waves.PAUSE - 0.2);
  assert.eq(page.game.baddies.length, 0, "not yet");
  run(page, 0.3);
  assert.eq(page.game.baddies.map((b) => b.kind), ["house_bug", "acorn", "teleport_bug"]);
  const b = page.game.baddies[0];
  const gap = Math.abs(b.x - page.game.hero.x);
  run(page, 1);
  assert.lt(Math.abs(b.x - page.game.hero.x), gap - 100, "walked closer");
});

test("one sword swing hits once", async () => {
  const page = await start("&mode=practice");
  const h = page.game.hero;
  const b = page.game.spawnBaddie("acorn", h.x + 100, h.y);
  swing(page, "KeyZ");
  assert.eq(b.hp, HP - 1);
});

test("the sword misses a bug behind", async () => {
  const page = await start("&mode=practice");
  const h = page.game.hero;
  const b = page.game.spawnBaddie("acorn", h.x - 100, h.y);
  b.update = () => null;   // stand still
  swing(page, "KeyZ");
  assert.eq(b.hp, HP);
});

test("the hammer spin hits both sides", async () => {
  const page = await start("&mode=practice");
  const h = page.game.hero;
  const front = page.game.spawnBaddie("house_bug", h.x + 120, h.y);
  const back = page.game.spawnBaddie("teleport_bug", h.x - 120, h.y);
  swing(page, "KeyX");
  assert.eq([front.hp, back.hp], [HP - 1, HP - 1]);
});

test("two hits sink it and leave a gem worth 10", async () => {
  const page = await start("&mode=practice");
  const h = page.game.hero;
  page.game.spawnBaddie("teleport_bug", h.x + 100, h.y);
  swing(page, "KeyZ");
  swing(page, "KeyZ");
  run(page, SINK_TIME + 0.1);
  assert.eq(page.game.baddies.length, 0, "gone");
  assert.eq(page.game.looseGems.length, 1, "a gem pops out");
  assert.eq(page.game.gems, 0, "not picked up yet");
  h.x = page.game.looseGems[0].x;
  h.y = page.game.looseGems[0].y;
  run(page, 0.05);
  assert.eq(page.game.gems, 10);
  assert.eq(page.game.looseGems.length, 0, "gone from the street");
});

test("beating a wave brings the next", async () => {
  const page = await start();
  run(page, Waves.PAUSE + 0.1);
  const first = [...page.game.baddies];
  first.forEach((b, i) => b.takeHit(HP, 900 + i, b.x, { x: 0, y: 0, w: 99999, h: 99999 }));
  run(page, SINK_TIME + Waves.PAUSE + 0.2);
  assert.eq(page.game.baddies.length, 3, "a new wave");
  assert.notOk(first.includes(page.game.baddies[0]), "new bugs");
  assert.eq(page.game.looseGems.length, 3, "the first wave left three gems");
});

test("fight mode brings a wave straight away; practice never does", async () => {
  const fight = await start("&mode=fight");
  assert.eq(fight.game.baddies.length, 3);
  const practice = await start("&mode=practice");
  run(practice, Waves.PAUSE + 1);
  assert.eq(practice.game.baddies.length, 0);
});

test("the gem counter is drawn in the corner", async () => {
  const page = await start();
  page.game.gems = 120;
  page.gameTick(0);
  const c = page.document.getElementById("game");
  const dpr = page.devicePixelRatio || 1;
  const [r, g, b] = c.getContext("2d").getImageData(52 * dpr, 60 * dpr, 1, 1).data;
  assert.ok(r > 200 && g < 150 && b > 120, `a pink gem: ${r},${g},${b}`);
});

test("the bugs are Charlie's own drawings, and all three load", async () => {
  const page = await start();
  const pics = page.bugPictures;
  assert.eq(Object.keys(pics).sort(), ["acorn", "house_bug", "teleport_bug"]);
  for (const [kind, img] of Object.entries(pics)) {
    await until(() => img.complete, `${kind} finished loading`);
    assert.gt(img.naturalWidth, 100, `${kind} is a real picture`);
    assert.ok(img.src.includes(`assets/baddies/${kind}.png`), kind);
  }
});

test("in the page, the teleportation bug pops up behind the hero", async () => {
  const page = await start("&mode=practice");
  const h = page.game.hero;
  const b = page.game.spawnBaddie("teleport_bug", h.x + 300, h.y);
  b.teleportWait = 0.5;
  b.punchWait = 99;
  run(page, 0.6);
  assert.eq(b.state, "vanish", "puff");
  run(page, 0.5);
  assert.lt(b.x, h.x, "now behind the hero (who faces right)");
});
