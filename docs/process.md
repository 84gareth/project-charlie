# Development process

Carried over from Project 2126 (adopted 2026-09-08), Project Two and
Project Sam. Moved from Godot to a web page on 2026-10-25; the Godot
version of this file is in `archive/godot/` history.

## 1. Interview, not prompt
Every non-trivial feature **starts with a numbered-question interview** until
the design has no holes. Claude asks, Charlie decides (Gareth signs off on
the roadmap). Questions come one at a time, with two or three numbered
choices, in words a 5-year-old can read. The answers
become a short spec in `docs/` **before any code**. No building on a vague
prompt.

## 2. Tests before trust
Game logic should be **pure and seeded** so rules are unit-testable. **When
Claude claims something works, a test has to say so too.**

- **Pure logic** (rules, maths, scoring, progression) → a module in `js/`
  that never touches the page, unit-tested in `tests/unit/`.
- **Anything needing the real page** (drawing, touches, keys, the game
  loop wiring) → a live test in `tests/live/`, which loads `index.html`
  in an iPad-sized frame with `?manual=1` and steps the game by hand.
- **Feel** (controls, timing, "is it fun?") → can't be tested; Charlie
  plays it on the iPad.

The framework is a tiny self-owned runner in `tests/framework.js` (no
library), copied from Project Sam. It fails a test on any error thrown,
rejected or reported by the page while it runs, so a test that crashes
partway fails instead of passing.

## 3. Balance measured, not vibed
Once there are numbers to balance, keep the numeric model out of the
real-time layer, in pure seeded modules, so a harness can simulate it and
assert bands (e.g. "a level lasts 2–4 minutes", "no power-up is strictly
best"). Prefer relative bands over exact numbers. When a band fails, fix the
design, not the assertion.

## Running the tests
```bash
./run_tests.sh
```
Serves the folder on a private port and runs every test in a hidden
(headless) Chrome. Ends with `All green.` or `FAILED.` Focus on one area
with `./run_tests.sh --only=<name>` (matches test file names). To watch them
in a visible browser: `tools/playtest.sh tests`.

## Writing a test
- **Unit**: `tests/unit/test_<thing>.js`:
  `import { test, assert } from "../framework.js";` then
  `test("what it checks", () => { ... })`.
- **Live**: `tests/live/test_<thing>_live.js`: `openPage("../index.html?manual=1")`,
  wait for `page.game`, then drive it with `page.gameTick(dt)` and real
  `KeyboardEvent`s or `PointerEvent`s.
- Asserts: `assert.ok/notOk/eq/ne/gt/lt/near`; `until(predicate, label)`
  waits for something.
- **Add every new test file to `tests/index.html`**, or it never runs.
