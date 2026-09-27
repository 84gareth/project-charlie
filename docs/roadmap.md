# Roadmap

The single ordered list. Work it top to bottom; new items get proposed and
agreed before they're added (CLAUDE.md rule 11).

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

## After the touch test (to plan with Charlie and Gareth)
- Dragons (boss or baddie: Charlie decides), a name, real art
- The talking sword: an in-game microphone; you tell the sword what to do
  (Gareth OK'd placing it here, 2026-09-26)
- Islands, each with a boss; beat every boss to reach the final boss
  (Gareth OK'd placing it here, 2026-09-26)
