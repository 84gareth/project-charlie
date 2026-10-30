// Playtest options from the page address, as tools/playtest.sh passes
// them:  index.html?mode=fight&hero=girl
//   street    the normal game (the default)
//   practice  no baddies: try walking, the sword and the hammer
//   fight     the first wave arrives straight away, close by
//   helpers   start with 700 gems (all three helpers), then a close wave
// hero=boy|girl picks the hero (later: skips the pick screen).
// manual=1 stops the game running by itself, so tests can step it.

export const MODES = ["street", "practice", "fight", "helpers"];
export const LOOKS = ["boy", "girl"];

export function options(search) {
  const q = new URLSearchParams(search);
  const mode = q.get("mode");
  const hero = q.get("hero");
  return {
    mode: MODES.includes(mode) ? mode : "street",
    hero: LOOKS.includes(hero) ? hero : "",
    manual: q.get("manual") === "1",
  };
}
