// Bugs punch back in the real page: a punch costs a heart and the hero
// blinks; stepping away or hitting first stops it; out of hearts the hero
// falls down, the fight restarts with full hearts and the gems are kept.
// The same checks as the Godot game's test_hearts_live.gd.
import { test, assert, openPage, until } from "../framework.js";
import * as Brain from "../../js/baddie_brain.js";
import { MAX_HEARTS, DOWN_TIME } from "../../js/fight.js";
import * as Waves from "../../js/waves.js";

async function start() {
  const page = await openPage("../index.html?manual=1&mode=practice", 1024, 768);
  await until(() => page.game !== undefined, "page script ran", 15000);
  return page;
}

const run = (page, seconds) => { for (let t = 0; t < seconds; t += 1 / 60) page.gameTick(1 / 60); };
const runUntil = (page, done, most = 5) => { for (let t = 0; t < most && !done(); t += 1 / 60) page.gameTick(1 / 60); };

function puncher(page) {
  const h = page.game.hero;
  const b = page.game.spawnBaddie("acorn", h.x + Brain.STOP_X, h.y);
  b.punchWait = 0;
  return b;
}

test("a punch costs a heart, and the hero blinks", async () => {
  const page = await start();
  puncher(page);
  runUntil(page, () => page.game.fight.hearts < MAX_HEARTS);
  assert.eq(page.game.fight.hearts, MAX_HEARTS - 1);
  page.gameTick(0.05);
  page.gameTick(0.05);
  assert.ok([page.game.hero.alpha].concat((() => { page.gameTick(0.1); return [page.game.hero.alpha]; })()).includes(0.35), "blinking");
});

test("stepping away dodges the punch", async () => {
  const page = await start();
  const b = puncher(page);
  runUntil(page, () => b.state === "windup");
  page.game.hero.x -= 300;
  b.lane = 999;   // can't follow into reach in time
  run(page, Brain.WINDUP + 0.1);
  assert.eq(page.game.fight.hearts, MAX_HEARTS, "missed");
});

test("hitting it first stops the punch", async () => {
  const page = await start();
  const b = puncher(page);
  runUntil(page, () => b.state === "windup");
  page.dispatchEvent(new page.KeyboardEvent("keydown", { code: "KeyZ", bubbles: true }));
  page.dispatchEvent(new page.KeyboardEvent("keyup", { code: "KeyZ", bubbles: true }));
  run(page, Brain.WINDUP + 0.1);
  assert.eq(page.game.fight.hearts, MAX_HEARTS, "punch stopped");
  assert.eq(b.hp, Brain.HP - 1, "and it got hit");
});

test("out of hearts: fall down, then the fight restarts with gems kept", async () => {
  const page = await start();
  page.game.gems = 70;
  page.game.fight.hearts = 1;
  page.game.wavesOn = true;
  puncher(page);
  runUntil(page, () => page.game.hero.down);
  assert.ok(page.game.hero.down, "lying down");
  assert.eq(page.game.baddies.length, 0, "this fight's bugs go away");
  run(page, DOWN_TIME + 0.05);
  assert.notOk(page.game.hero.down, "back up");
  assert.eq(page.game.fight.hearts, MAX_HEARTS, "full hearts");
  assert.eq(page.game.gems, 70, "gems kept");
  run(page, Waves.PAUSE + 0.1);
  assert.eq(page.game.baddies.length, 3, "the fight starts again");
});

test("no walking or attacking while lying down", async () => {
  const page = await start();
  page.game.fight.hearts = 1;
  puncher(page);
  runUntil(page, () => page.game.hero.down);
  const x = page.game.hero.x;
  page.dispatchEvent(new page.KeyboardEvent("keydown", { code: "ArrowRight", bubbles: true }));
  page.dispatchEvent(new page.KeyboardEvent("keydown", { code: "KeyZ", bubbles: true }));
  run(page, 0.3);
  page.dispatchEvent(new page.KeyboardEvent("keyup", { code: "ArrowRight", bubbles: true }));
  assert.eq(page.game.hero.x, x, "didn't walk");
  assert.notOk(page.game.attack.busy(), "didn't swing");
});

test("the hearts are drawn under the gem counter", async () => {
  const page = await start();
  page.game.fight.hearts = 3;
  page.gameTick(0);
  const c = page.document.getElementById("game");
  const dpr = page.devicePixelRatio || 1;
  const px = (x, y) => [...c.getContext("2d").getImageData(x * dpr, y * dpr, 1, 1).data];
  const full = px(46, 132), lost = px(46 + 5 * 46, 132);
  assert.ok(full[0] > 200 && full[1] < 100, `first heart red: ${full}`);
  assert.ok(lost[0] > 190 && lost[1] > 190, `sixth heart grey: ${lost}`);
});
