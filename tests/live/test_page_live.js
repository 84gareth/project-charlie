// The real page loads in an iPad-sized frame: the street, the hero at the
// start spot, the version, and nothing to scroll.
import { test, assert, openPage, until } from "../framework.js";
import { VERSION, GAME_NAME } from "../../js/version.js";
import { HERO_START } from "../../js/layout.js";

const ready = (page) => until(() => page.game !== undefined, "page script ran", 15000);

test("page shows the version and the hero at the start", async () => {
  const page = await openPage("../index.html?manual=1");
  await ready(page);
  assert.eq(page.document.getElementById("version").textContent, "v" + VERSION);
  assert.eq(page.document.title, GAME_NAME);
  assert.eq({ x: page.game.hero.x, y: page.game.hero.y }, HERO_START);
});

test("the game fills an iPad screen, held either way, without scrolling", async () => {
  for (const [w, h] of [[1024, 768], [768, 1024]]) {
    const page = await openPage("../index.html?manual=1", w, h);
    await ready(page);
    const doc = page.document;
    const c = doc.getElementById("game");
    assert.eq([c.clientWidth, c.clientHeight], [w, h], "canvas fills it");
    assert.ok(doc.documentElement.scrollHeight <= h && doc.documentElement.scrollWidth <= w, "nothing to scroll");
  }
});

test("the page loads its code with the version stamped on", async () => {
  const page = await openPage("../index.html?manual=1");
  await ready(page);
  const loaded = page.performance.getEntriesByType("resource").map((e) => e.name).filter((n) => n.includes("/js/"));
  assert.gt(loaded.length, 5, "it loaded its modules");
  for (const n of loaded) assert.ok(n.includes(`?v=${VERSION}`), `stamped: ${n}`);
});

test("the street is drawn (the canvas isn't blank)", async () => {
  const page = await openPage("../index.html?manual=1");
  await ready(page);
  page.gameTick(0);
  const c = page.document.getElementById("game");
  const px = (x, y) => [...c.getContext("2d").getImageData(x, y, 1, 1).data];
  const dpr = page.devicePixelRatio || 1;
  // The road near the bottom is dark grey; the sky at the top is light blue.
  const road = px(10 * dpr, 740 * dpr);
  const sky = px(10 * dpr, 10 * dpr);
  assert.lt(road[0], 120, `road is dark: ${road}`);
  assert.gt(sky[2], 200, `sky is blue: ${sky}`);
});

test("a Home Screen icon for the iPad: Charlie's blue helper", async () => {
  const page = await openPage("../index.html?manual=1");
  await ready(page);
  const link = page.document.querySelector('link[rel="apple-touch-icon"]');
  assert.ok(link, "the icon is linked");
  const img = new Image();
  img.src = link.href;
  await img.decode();
  assert.eq([img.naturalWidth, img.naturalHeight], [180, 180]);
});
