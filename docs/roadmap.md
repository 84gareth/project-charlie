# Roadmap

The single ordered list. Work it top to bottom; new items get proposed and
agreed before they're added (CLAUDE.md rule 11).

Charlie has two games since 2026-10-30: the street game (Phases 0 to 4
below, in `street/`) and Charlie's Traitors (its own section at the end,
in `traitors/`), picked from his home page.

## Phase 0: Project setup ✅ (v0.1.0)
- ✅ Godot 4.7 project, Compatibility renderer, 1600x900 window
- ✅ Placeholder main scene showing name and version
- ✅ Test runner with both lanes (unit and live), crash trap, `--only` filter
- ✅ Git repo, working rules (CLAUDE.md, docs/process.md) and hard limits
  (`.claude/`)

## Phase 1: Decide the game (with Charlie) ✅
- ✅ Interview Charlie, one easy question at a time: who you play as, what you
  do over and over, what it looks like, what makes it fun (then Gareth and
  Claude settle 2D or 3D, controls, and winning or losing)
- ✅ One-page pitch in `docs/pitch.md`, in Charlie's words where possible
- ✅ Project settings checked: 2D, 1600x900 and the Compatibility renderer
  all suit a side-scrolling brawler; nothing to change
- ✅ Gareth's decisions: belt beat-'em-up (like Power Rangers: Rita's
  Rewind), keyboard plus Xbox and Switch controllers, out of hearts means
  restart the fight and keep your gems

## Phase 2: The first touch test ✅
Shapes for art throughout; real art comes after Charlie says it's fun.
1. ✅ A city street; the hero walks left, right, up and down, on keyboard
   or an Xbox or Switch controller (v0.2.0)
2. ✅ Sword and hammer: one button each; the sword swings in front, the
   hammer does Charlie's spin attack all around (v0.3.0). Talking to the
   sword through the in-game microphone waits until after the touch test
   (Charlie agreed: button first).
3. ✅ Baddies walk in; hit one and it sinks into the ground and drops a
   gem; pick gems up and count them (v0.4.0). Waves of three, from just
   off-screen; two hits each; a new wave 1.5 s after the last one is beaten.
4. ✅ Hearts: baddies hit back; out of hearts restarts the fight, gems
   kept (v0.5.0). Charlie chose 12 hearts. Baddies wind up (fist back,
   reddish) for 0.7 s, so a punch can be dodged or stopped by hitting
   first; 1 s safe after each hit; out of hearts the hero lies down with
   stars for 1.5 s.
5. ✅ Pick a boy or a girl at the start (v0.6.0). Two big cards, no
   reading; arrows/d-pad/stick to choose, any attack button, Enter or a
   click to pick. The girl has Charlie's two pigtails.
- ✅ Gate for everything after it: Charlie plays it and says whether it's
  fun. Played v0.6.0 on 2026-09-27: "It's great."

## Phase 3: Helpers (Charlie's design; Gareth asked for them 2026-09-27) ✅
1. ✅ Helper art: Charlie's drawings → Gemini → Meshy 3D → sprites
2. ✅ Gems worth 10; helpers join at 200, 500 and 700 gems (you keep your
   gems) and follow you; all of them come (v0.7.0)
3. ✅ Powers: blue sends a wave along the street, yellow sneaks behind a
   baddie and bonks it, green flies up and swoops down on one and sinks
   it in one go (v0.8.0)
4. ✅ Helpers give you a heart now and then when you've lost some: each
   one every 15 s at most (v0.8.0)
- ✅ Gate: Charlie plays with his helpers and says whether they're fun.
  Played v0.8.0 (helpers mode) on 2026-09-27: "Super fun!"

## Phase 4: On Charlie's iPad (Gareth, 2026-10-25)
Rebuilt as a plain web page like Sam's game (Gareth chose a rebuild over a
Godot export), published on GitHub Pages, played by touch. The Godot game
is archived in `archive/godot/` (tag `godot-v0.8.0`); every rule and number
carries over unchanged.
1. ✅ Web setup: page, tests in headless Chrome, launcher, version stamps,
   GitHub Pages; the street and walking with an on-screen joystick (plus
   keyboard and controller) (v0.9.0)
2. ✅ Sword and hammer: two big buttons (v0.10.0)
3. ✅ Charlie's three bugs (house bug, Acorn bad guy, teleportation bug,
   one of each per wave, as Charlie drew them: his drawings cut out of the
   paper, v0.11.1) walk or fly in, sink into the ground, drop gems worth
   10; the gem counter (v0.11.0)
4. ✅ Hearts: bugs punch back; out of hearts restarts the fight, gems kept
   (v0.12.0)
5. The bugs' own moves, one at a time (Gareth, 2026-10-25):
   - ✅ the teleportation bug vanishes in sparkles and pops up behind,
     above (dropping down) and in front of you in turn, then punches
     soon after: the scare (v0.13.0)
   - the house bug grabs you with its tentacles and you tap a button
     three times to get free (Charlie is drawing the button)
   - ✅ the Acorn bad guy hides in one of Charlie's trees (his hide and
     seek drawing, five along the street) and drops on you (v0.14.0)
6. Pick a boy or a girl at the start
7. Charlie's three helpers, their powers and hearts
- Gate: Charlie plays it on his iPad and says whether it's as fun

## After the touch test (to plan with Charlie and Gareth)
- Dragons (boss or baddie: Charlie decides), a name, real art
- The talking sword: an in-game microphone; you tell the sword what to do
  (Gareth OK'd placing it here, 2026-09-26)
- Islands, each with a boss; beat every boss to reach the final boss
  (Gareth OK'd placing it here, 2026-09-26)

## Charlie's Traitors (Gareth, 2026-10-30)
Charlie wants "his own version of the traitors game the same as in Sam's
but with his own drawings". A separate game in `traitors/`, picked from
Charlie's home page.
1. ✅ Home page with two big picture buttons; the street game moves into
   `street/`; a house button in each game back home
2. ✅ A copy of Sam's game (Sam's v0.29.0), named "Charlie's Traitors"
   (Charlie's choice), with its own saves and its own corner of Sam's
   database (`charlie-rooms/`) (v0.1.0)
3. ✅ Made-up placeholder pictures for all 22 characters and the shield,
   dagger, fire pit and flames, instead of Sam's drawings (v0.2.0)
4. Gareth pastes the `charlie-rooms` rule into the database's rules, so
   online play works
5. Charlie's drawings replace the placeholders, one at a time, as he does
   them
- Gate: Charlie plays it on his iPad and says whether it's fun
