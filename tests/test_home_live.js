// Charlie's home page: two big picture buttons, one per game, that fit an
// iPad either way up; and a house in each game to come back.
import { test, assert, openPage, until } from "./framework.js";

test("two big picture buttons: the street game and Charlie's Traitors", async () => {
  const page = await openPage("../index.html", 1024, 768);
  const games = [...page.document.querySelectorAll("a.game")];
  assert.eq(games.map((a) => a.getAttribute("href")), ["street/", "traitors/"]);
  for (const a of games) {
    const r = a.getBoundingClientRect();
    assert.gt(r.width, 300, `${a.id} is big`);
    assert.gt(r.height, 300, `${a.id} is big`);
  }
});

test("fits an iPad held either way, with nothing to scroll", async () => {
  for (const [w, h] of [[1024, 768], [768, 1024]]) {
    const page = await openPage("../index.html", w, h);
    const doc = page.document;
    assert.ok(doc.documentElement.scrollHeight <= h && doc.documentElement.scrollWidth <= w, `no scrolling at ${w}x${h}`);
    const [a, b] = [...doc.querySelectorAll("a.game")].map((x) => x.getBoundingClientRect());
    for (const r of [a, b]) assert.ok(r.left >= 0 && r.top >= 0 && r.right <= w && r.bottom <= h, `on screen at ${w}x${h}`);
    if (w > h) assert.lt(a.right, b.left, "side by side when held sideways");
    else assert.lt(a.bottom, b.top, "one above the other when held upright");
  }
});

test("a Home Screen icon: Charlie's blue helper", async () => {
  const page = await openPage("../index.html");
  const link = page.document.querySelector('link[rel="apple-touch-icon"]');
  const img = new Image();
  img.src = link.href;
  await img.decode();
  assert.eq([img.naturalWidth, img.naturalHeight], [180, 180]);
});

test("each game has a house button back to this page", async () => {
  const home = new URL("../", location.href).href;
  const street = await openPage("../street/index.html?manual=1", 1024, 768);
  await until(() => street.game !== undefined, "street game started", 15000);
  assert.eq(street.document.getElementById("home").href, home, "street game");
  const traitors = await openPage("../traitors/index.html", 1024, 768);
  await until(() => traitors.document.getElementById("version").textContent !== "v0.0.0", "traitors started", 15000);
  const house = traitors.document.getElementById("home");
  assert.eq(house.href, home, "Charlie's Traitors");
  const r = house.getBoundingClientRect();
  assert.ok(r.width >= 60 && r.top >= 0 && r.left >= 0, "big enough and on screen");
  assert.ok([...traitors.document.querySelectorAll("#overview a.home")].length === 1, "and in the pause menu");
});

// Last on purpose: in the hidden test browser, a page opened after this
// one's pictures loaded never finished loading (2026-10-30), and the run
// stopped early. The castle is checked with a plain fetch, not decoded.
test("the pictures on the buttons load", async () => {
  const page = await openPage("../index.html", 1024, 768);
  const imgs = [...page.document.querySelectorAll("#street img")];
  assert.eq(imgs.length, 3, "Charlie's three bugs");
  for (const img of imgs) {
    await until(() => img.complete, img.src);
    assert.gt(img.naturalWidth, 100, img.src);
  }
  const castle = await fetch(new URL("traitors/assets/castle.jpg", page.location.href));
  assert.ok(castle.ok, "the castle picture is there");
});
