# Project Charlie — Working Rules for Claude Code

Games that **Charlie (aged 5) designs** with his dad, Gareth, built as
**web pages he plays on his iPad**, as a structured AI-assisted learning
project. Separate from Gareth's other games and from his brother Sam's
(Project Sam). See `docs/roadmap.md` for where we are.

**Two games and a home page (since 2026-10-30):**
- `index.html` (root): Charlie's home page. Two big picture buttons, no
  words: his bugs for the street game, the castle for Charlie's Traitors.
  Each game has a house button back to it (from the Home Screen there's
  no browser back button). Tests in `tests/`.
- `street/`: **the street game**, Charlie's own (the beat-'em-up with his
  bugs, helpers and trees). Everything below about the canvas, the bugs,
  walking and so on is this game.
- `traitors/`: **Charlie's Traitors**, a copy of Project Sam's Traitors
  game (see "Charlie's Traitors" below).
Each game is self-contained in its folder (its own `index.html`, `js/`,
`css/`, `assets/`, `tests/` and `js/version.js`).

The street game was first built in Godot (v0.1.0 to v0.8.0). On 2026-10-25
Gareth asked for it on Charlie's iPad "like Sam's game", and chose to
rebuild it as a plain web page rather than export it from Godot. The Godot
game is kept in `archive/godot/` (git tag `godot-v0.8.0`); it still runs
and passes its tests, and it is the reference for every rule and number
being carried over.

## THE CRITICAL RULE: talk so a 5-year-old can read it
Set up 2026-09-26, the same as Project Sam's rule but simpler still, because
Charlie is 5 and reads simple sentences.
- **Every message is at a 5-year-old's reading level.** Interviews with
  Charlie, updates, and write-ups of what was done. Like an early reader
  book: very short sentences (about 3 to 8 words), small everyday words
  (big, red, jump, fast), one idea per sentence.
- **Keep it tiny.** Say what changed in the game. Never how the code works.
  No computer words at all ("code", "test", "file", "scene", "GitHub",
  "version"). If a word is hard, pick an easier one.
- **Questions for Charlie:** ONE at a time, with two or three numbered
  choices, each only a few words ("1. A dog  2. A dragon  3. A car"), plus
  "or something else?".
- **"DAD" at the start of a message** means Gareth wants more detail. Give
  it in that ONE next reply only (normal grown-up language, still concise).
  The reply after that goes back to 5-year-old language.
- Technical detail still goes in commit messages and docs, never chat.
- This overrides any other wording in this file about how to write updates.

**Who you're talking to.** Gareth types and reads things out; Charlie sits
with him, gives the ideas and picks from the choices. Charlie is the game
designer: the ideas, the names, the look and the "is it fun?" call are his.
Gareth is the producer: he keeps the project on track, approves the roadmap,
and handles anything outside the game (GitHub, downloads, accounts). Neither
is a day-job programmer. Save technical detail for "DAD" replies, commits
and docs.

These rules are carried over from Project Sam (`~/Projects/Project Sam`),
Project 2126 (`~/Projects/project-2126/project-2126`) and Project Two
(`~/Projects/project-two`), where they were learned the hard way.

## Environment
- **A plain web page: HTML, CSS and JavaScript, no build step, no
  libraries**, the same as Project Sam. Open `index.html` and that's the
  game. JavaScript modules (`import`/`export`) need the page served over
  http, not opened as a file (`tools/playtest.sh` serves it).
- **Plays on Charlie's iPad, in Safari.** Touch first: a joystick under
  the left thumb, sword and hammer buttons on the right. Keyboard (for the
  Mac) and Xbox or Switch controllers (iPads support them) work too. Design
  for a landscape iPad; it must still work held upright.
- The street game is drawn on one `<canvas>` in world units (the Godot
  game's pixels: a 4800 by 900 street); `street/js/layout.js` `view()`
  fits it to the screen, always the full height and at least 1200 across.
- **Published with GitHub Pages:** https://84gareth.github.io/project-charlie/
  (the home page; the games are at `street/` and `traitors/`; the repo is
  PUBLIC since 2026-10-25, Gareth's call, like Sam's). Every push to `main`
  updates it within a minute or two. Never put anything private in the
  repo: no surnames, school, photos of people. Pictures aren't version-
  stamped: Pages lets browsers keep them up to 10 minutes.
- **Charlie's and Sam's games share one web address** (84gareth.github.io),
  so they share the iPad's saved data: keys in Charlie's games must never
  start `project-sam-`.
- No Node or npm on this Mac. Python 3 and Google Chrome are here. Godot
  4.7.2 (`~/Downloads/Godot.app`) and Blender are here for the archive and
  the art pipeline.
- Git from day one, `main` branch, github.com/84gareth/project-charlie. No
  `gh` CLI: git pushes fine; anything else on GitHub goes through Claude in
  Chrome, where Gareth is signed in.
- **Look at it for real** in the built-in browser at iPad size
  (`resize_window` 1024x768), served by `python3 -m http.server` on a FREE
  port in the background (8123 was taken by Project Sam's server on
  2026-10-25, and the pane showed Sam's game). The pane only draws while
  it's on screen, so take a screenshot to let a frame through. Pretend a
  touch with `PointerEvent`s (`pointerType: "touch"`) to see the on-screen
  controls. Screenshots worth keeping go in `captures/` (gitignored).
- **Art pipeline (from the Godot days, still the way):** Charlie's drawing
  → Gemini (Gareth, web UI) → Meshy image-to-3D (`meshy-job`, symlinked
  from Project 2126; `MESHY_API_KEY` is in the environment; EVERY job costs
  credits, so ask before re-rolling) → `tools/helper_sprite.py` (headless
  Blender) → a PNG in `street/assets/`. Raw photos go in `drawings/`. Since
  2026-10-25 Gareth wants Charlie's drawings in as he drew them: cut out with
  `tools/image-fix/cutout.gd` (`crop=`, `erase=`, `sat=`), no Gemini.

## How we work

1. **Read before you edit.** Understand the current state of a file, and
   what calls it, before changing it.
2. **Be direct about failures. Never ship broken code.** If something doesn't
   work, say so plainly. Don't claim success you haven't checked.
3. **Tests before trust.** We follow `docs/process.md`: **interview → spec
   before code**, and **when you claim something works, a test must confirm
   it**. Claude runs `./run_tests.sh` itself before reporting results. Two
   lanes: `tests/unit/` (pure logic) and `tests/live/` (the real page in an
   iPad-sized frame). Keep game rules in pure modules that don't touch the
   page, so they're unit-testable. Live tests open the page with
   `?manual=1` and step it with `page.gameTick(dt)`, never waiting on
   animation frames. Green means "the tested logic is correct", not
   "done": **Charlie playing it on the iPad is the real gate for anything
   visual or interactive.** Mutation-check new tests of game logic (break
   the code, watch the test fail).
4. **Keep the loop VERY fast.** A 5-year-old's attention is the scarcest
   thing here: get something new on screen in minutes, not hours. Prefer
   many tiny changes Charlie can see over one big one. Use
   `./run_tests.sh --only=<name>` while iterating. Run the full suite once,
   before the final push of a request that touches game logic. If a task
   will take more than ~5 minutes, say so BEFORE starting.
5. **Time-box debugging, then report.** Two or three focused attempts; if it
   isn't root-caused, STOP and report what's known, what was ruled out, and
   the best next idea. Stop immediately if the same code gives different
   results between runs (that's noise; don't tune against it). A question
   about process ("why did that take so long?") wants an answer, not another
   investigation.
6. **Bump the version on every gameplay change**, per game. Single source
   of truth: `VERSION` in that game's `js/version.js` (`street/` and
   `traitors/` each have their own). **Then run `python3 tools/stamp.py`**:
   it stamps each game's version onto every file its index.html loads, so
   the iPad fetches the new copy (a test fails if you forget). Say which
   game in the push line: `✅ Pushed to GitHub (street v0.14.2)`.
7. **When you suggest options, number them** so Charlie can pick by number.
   Two or three options at most, a few words each.
8. **No emoji in game UI.** Pictures drawn on the canvas, never words a
   5-year-old has to read. (Chat-status marks in rule 10 are fine.)
9. **One change at a time, each landing at a runnable state.** Small commits,
   descriptive messages. Commit after each working step, then push straight
   away without being asked. (Pushing also publishes the game.)
10. **Every update follows THE CRITICAL RULE above**: 5-year-old reading
    level, tiny, what changed in the GAME. Each heading gets ONE short
    sentence. Technical detail belongs in commit messages and docs.
    - Tests line: `✅ 12/12 passed` or `❌ 3/12 failed` (say which).
    - Push line: `✅ Pushed to GitHub (v0.2.0)` only once `git push` has
      actually succeeded, or `❌ not pushed` and why.
    - **Every update ends with these five headings, in this order:**
      1. **Phase**: which roadmap phase was just finished, or is in progress.
      2. **Non-player-facing**: what changed behind the scenes and why.
      3. **Player-facing**: what's different if Charlie plays RIGHT NOW. If
         nothing, say so.
      4. **What's next**
      5. **Model and effort level required**, e.g. `Opus 5.5 · high`.
    - Never use the phrase "load-bearing". Say the actual thing.
    - **EVERY update ends with the link to play** (Gareth, 2026-09-26;
      widened 2026-09-27 to every update): after the five headings, the
      iPad link (https://84gareth.github.io/project-charlie/) and a `bash`
      code block that runs the launcher with the page that shows the newest
      thing (no argument, the home page, when nothing changed), so the Run
      button starts it:
      ```bash
      cd "/Users/gareth/Projects/Project Charlie" && tools/playtest.sh fight
      ```
      Pages: `home` (default), `traitors` (Charlie's Traitors), and for the
      street game `street`, `practice` (no baddies), `fight` (a wave
      straight away), `helpers` (700 gems, all three helpers), plus `boy`
      or `girl`; test pages `tests`, `traitors-tests`, `home-tests`. Add a
      mode to the launcher (and `street/js/playtest.js`) when a new screen
      needs one. The launcher uses port 8020 (Sam's uses 8000).
11. **Work the roadmap in order; don't silently insert.** `docs/roadmap.md` is
    the single ordered list. When something new comes up, propose where it
    goes and get an OK before adding it.
12. **Multi-task requests: ask every clarifying question up front**, in one
    batch, before starting any of the work. A mid-list question stalls
    everything. (Questions for Charlie himself still go one at a time.)
13. **Every prompt, in full, in a code block, in the FINAL message.** Any
    prompt to paste elsewhere (art, music, an image edit) goes whole in the
    closing message of the turn. "See above" doesn't count.

## Working with Charlie
- **Charlie's ideas lead.** Build what Charlie asks for, the way he
  describes it. If an idea is too big, say so kindly and offer a tiny first
  version he can play today. Never swap in your own idea without asking.
- **Interviews are short and fun.** One easy question at a time, with two or
  three numbered choices plus "or something else?". Stop and build something
  after a few answers; don't make him answer a long list. Big design
  decisions get written into `docs/` in Charlie's own words where possible.
- **Celebrate, then be honest.** Say what's good about an idea, then any
  real problem with it, gently and simply.
- **Don't teach.** No lessons about how games are made unless Gareth asks.
- **Keep the game right for a 5-year-old.** Friendly, bright and silly.
  Nothing scary, gory, mean or grown-up; bumping, bouncing and "oops, try
  again" are fine.
- **Playable by a 5-year-old.** The game must never need reading to play:
  pictures, colours and sounds carry the meaning. Big targets (buttons at
  least 60 px), a few simple controls, and no way to get stuck or lose
  everything.
- **Never ask Charlie for personal details** (full name, school, address,
  photos). Anything outside the game itself (GitHub, downloads, accounts,
  sharing the game, anything that costs money) needs Gareth's OK.

## Hard limits — do not work around them
Two layers, in this repo, deliberate, loosened only by Gareth:
`.claude/settings.json` deny/ask rules and `.claude/hooks/guard.py` (blocks
destructive commands, any delete outside the project, file edits outside it,
credentials, system settings, and any change to `.claude/` itself). If a
command the task needs is blocked, SAY which limit it hit and stop; never
look for another route. `curl`/`wget` ask first. The OS-level Bash sandbox
is OFF on purpose (it broke pushing and windowed Godot captures in Project
2126); don't propose turning it back on. The guard matches on command TEXT:
a shell command (even a commit message) that names the limits files' path
alongside `>`, `cp`, `mv`, `tee` or `python` is blocked, so describe them in
words instead (Project Sam, 2026-09-26). It also blocks `rm -rf` (so the
leftover `.godot/` cache at the root stays; it's gitignored) and any
`; open(` in shell text, so a Python heredoc that opens a file is refused:
edit files with the Edit tool.

## Web conventions for this project
- The home page `index.html` at the root (GitHub Pages serves it); each
  game in its own folder with `index.html`, `js/` (ES modules), `css/`,
  `assets/` and `tests/`. Shared tools stay in `tools/`.
- Game rules live in pure modules (no `document`, no timers) so unit tests
  can import them. Street game: `layout.js`, `walk.js`, `controls.js`,
  `attacks.js`, `baddie_brain.js`, `baddies.js`, `waves.js`, `gems.js`,
  `fight.js`, `playtest.js`; its page code (`main.js`, `input.js`,
  `art.js`, `hud.js`) only draws and listens.
- Every test file is listed in its game's `tests/index.html` (or the home
  page's `tests/index.html`); the runner fails a file that doesn't load
  or registers no tests. `./run_tests.sh` runs all three pages;
  `--game=street|traitors|home` runs one.
- Touch: Pointer Events (`pointerdown`/`pointermove`/`pointerup`), not
  mouse events. Buttons at least 60 px. `touch-action: none` on the game so
  Safari doesn't scroll or zoom.
- Carry numbers over from the Godot game unchanged unless Charlie or Gareth
  asks; its pure scripts in `archive/godot/scripts/` are the reference.

## Charlie's Traitors (`traitors/`)
Charlie wanted "his own version of the traitors game the same as in Sam's
but with his own drawings" (2026-10-30). Copied from Project Sam at
d67901c (Sam's v0.29.0); Charlie's copy restarted at v0.1.0. From then on
the two games are separate: Sam's later changes don't come over by
themselves, and nothing Charlie changes reaches Sam's.
- **Name:** "Charlie's Traitors" (Charlie's choice).
- **Saves:** keys start `charlie-traitors-`, never `project-sam-`.
- **Online play shares Sam's Firebase database, kept apart** (Gareth's
  choice): Charlie's rooms live under `charlie-rooms/`
  (`traitors/js/firebase-net.js`); Sam's live under `rooms/`. The database
  needs a `charlie-rooms` rule beside Sam's `rooms` rule (given to Gareth
  2026-10-30); until it's pasted, Charlie's multiplayer is refused.
  Single player never touches the database.
- **Pictures:** every character, the shield, dagger, fire pit and flames
  start as made-up placeholders (`tools/placeholders/`), swapped for
  Charlie's drawings one at a time: how in `traitors/docs/characters.md`.
  The station, castle and rooms are made pictures from Sam's game and stay.
- **It's Sam's code, with Sam's lessons.** Before changing anything in
  `traitors/`, read Project Sam's CLAUDE.md "Project landmines" (speech and
  sound only after a tap, `fit.js` and `cqw` units for phones, the puppet
  castle's paused frames and `castleTick`, the local net for tests) and
  `traitors/docs/`. Its tests are Sam's 226, run with
  `./run_tests.sh --game=traitors`.
- Sam's game is for 8 to 11 year olds and has words to read; voices read
  most of it aloud. If Charlie gets stuck on reading, that's a design
  question for Charlie and Gareth, not something to change unasked.

## Don't add what wasn't asked for
In Project Two, sound effects went in unasked and stayed through five
versions before anyone noticed. A design doc listing something is not a
request to build it now. If a phase seems to need something Charlie or
Gareth hasn't asked for, ask first.

## Check the view that matters
For anything visual, look where things MEET (a character and the ground,
the on-screen buttons and the street, the iPad's rounded corners and home
bar), close up, at iPad size, before calling it done.

## What matters most (hold us to this)
Make the core game FUN before making anything NICE. The biggest risk is
scope-exploding into menus, polish, effects or story before the core loop is
fun to play again and again. If you catch us doing that, push back and say
so, kindly.

## Project landmines (things that have bitten us — check before repeating)
- **Browsers keep old copies of the game's files** (Project Sam,
  2026-10-24). `tools/stamp.py` version-stamps every module and the CSS;
  `tools/playtest.sh` sends `Cache-Control: no-store`. GitHub Pages caches
  for up to 10 minutes: after a push, a short wait or a refresh.
- **Browsers pause animation frames in hidden or off-screen pages**, and
  headless Chrome may never send them. Live tests step the game by hand
  (`?manual=1`, `page.gameTick`); the test frame sits on-screen at 2%
  opacity.
- **iPad Safari only plays sound after a tap.** If sound ever comes in,
  start it from a tap handler.
- **A test helper that searches must give up**, or a broken rule loops
  forever. The runner has a 120 s stopwatch; keep it.
- **Gate a commit on run_tests.sh's own exit code**, never on `| tail`'s
  (Project Sam pushed a failing test that way).
- **Test the crash trap when changing the runner.** Without it, a test that
  crashes partway can look like a pass.
- **Don't name functions or variables after built-ins** of the language.
- From the Godot days, still true for the archive: never put a freed node
  in a typed variable; don't pipe a windowed Godot run into `head`;
  `sips --cropOffset 0 0` crops from the centre.

## Current status
Updated 2026-10-30 (street v0.14.2, Charlie's Traitors v0.2.0).
- **Two games and a home page (2026-10-30):** the street game moved into
  `street/`; Charlie's Traitors (a copy of Sam's game, placeholder
  pictures) is in `traitors/`; the home page picks between them. Waiting on
  Gareth: the `charlie-rooms` database rule for online play.
- **Phases 0 to 3 done in Godot** (v0.1.0 to v0.8.0, all in
  `archive/godot/`): a belt beat-'em-up in a city (like Power Rangers:
  Rita's Rewind); walk, sword and spin hammer; waves of purple baddies that
  punch back and sink into the ground leaving gems (worth 10); 12 hearts;
  out of hearts restarts the fight and keeps gems; pick a boy or a girl
  (two pigtails); Charlie's three helpers (blue waves at 200 gems, yellow
  sneaky at 500, green flying at 700) who also give hearts. Charlie's
  verdicts: "It's great", "Super fun!".
- **Phase 4: the web rebuild, in progress.** Step 1 done (v0.9.0): the
  street and walking, with the on-screen joystick, keyboard and controller,
  tests in headless Chrome, and GitHub Pages (live and checked). Step 2
  done (v0.10.0): sword and hammer buttons (`js/attacks.js`).
- **Step 3 done (v0.11.0):** Charlie's three bugs replace the purple
  monsters (Gareth's call), one of each per wave, drawn as simple shapes
  from his drawings in `js/art.js` until their real pictures exist
  (prompts in `docs/art_prompts.md`); `js/baddies.js` is the pure bug state
  machine. Gems worth 10 and the counter. v0.11.1: the bugs are Charlie's own
  drawings, cut out of the paper by `tools/image-fix/cutout.gd` (Gareth: "put
  Charlie's drawings in as they are", no Gemini); the shapes only show while
  a picture loads. New drawings: `cutout.gd` with `erase=` for any tablecloth
  in the photo and `sat=` if the paper looks blue.
- **Step 4 done (v0.12.0):** hearts, punches, falling down (`js/fight.js`).
- **Step 5 in progress:** the teleportation bug's teleport is done
  (v0.13.0; `TELEPORT` and `teleportSpot` in `js/baddies.js`). The Acorn
  dropping from Charlie's trees is done (v0.14.0; `TREES` in
  `js/layout.js`, `TREE_DROP` in `js/baddies.js`, the tree cut from his
  hide and seek drawing with `cutout.gd crop=`). Still to come: the house
  bug's grab (needs Charlie's button drawing).
- **Home Screen icon (v0.14.1):** Charlie chose his blue helper; his drawing
  cut out and put on yellow by `tools/image-fix/icon.gd`.
- **Next:** the house bug's grab once the button is drawn; otherwise the
  pick screen and the helpers (roadmap order). Open for Gareth: helpers as
  Charlie's plain drawings instead of the 3D renders?
- **Waiting for Gareth's OK on placement:** Charlie's ball-and-goal mini
  game and his hide and seek (tree, bush, trampoline; the teleportation
  bug seeks). Both in `docs/pitch.md`.
- Testing happens on the laptop (keyboard) and the iPad (touch): check
  both sizes (1440x900 and 1024x768) for anything visual.
- Open question for Gareth: saving (gems and helpers reset when the game
  closes). Charlie's next idea after the rebuild: dragons, islands, the
  talking sword, or more drawings.
