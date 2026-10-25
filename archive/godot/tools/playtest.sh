#!/usr/bin/env bash
# Start Project Charlie in a normal game window, the way you'd play it.
#
# Usage: tools/playtest.sh [mode] [boy|girl] [-- extra Godot flags]
#   street     the normal game (default): pick a boy or a girl first
#   practice   no baddies: try walking, the sword and the hammer
#   fight      the first wave of baddies turns up straight away, close by
#   helpers    start with 700 gems, so all three helpers, then a close wave
#   editor     open the project in the Godot editor instead
#   boy, girl  skip the pick screen and play as that hero
#              (every mode but street skips it, as the boy by default)
#
# Controls: arrows or WASD to walk, Z or Space for the sword, X for the
# hammer. Controllers: stick or d-pad to walk, bottom/right buttons for the
# sword, left/top buttons for the hammer.
#
# Anything after `--` goes straight to Godot, e.g.
#   tools/playtest.sh fight -- --quit-after 300
# Override the Godot binary with:  GODOT="/path/to/Godot" tools/playtest.sh
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="street"
HERO=""
EXTRA=()
while [ $# -gt 0 ]; do
  case "$1" in
    street|practice|fight|helpers|editor) MODE="$1" ;;
    boy|girl) HERO="$1" ;;
    -h|--help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --) shift; EXTRA=("$@"); break ;;
    *) echo "Unknown option: $1  (try: street, practice, fight, helpers, editor, boy, girl)"; exit 2 ;;
  esac
  shift
done

GODOT="${GODOT:-}"
if [ -z "$GODOT" ]; then
  if command -v godot >/dev/null 2>&1; then
    GODOT="godot"
  else
    for p in \
      /Applications/Godot*.app/Contents/MacOS/Godot \
      "$HOME"/Applications/Godot*.app/Contents/MacOS/Godot \
      "$HOME"/Downloads/Godot*.app/Contents/MacOS/Godot \
      "$HOME"/Desktop/Godot*.app/Contents/MacOS/Godot ; do
      if [ -x "$p" ]; then GODOT="$p"; break; fi
    done
  fi
fi
if [ -z "$GODOT" ]; then
  echo "Could not find Godot. Run again like:"
  echo "  GODOT=\"/path/to/Godot.app/Contents/MacOS/Godot\" tools/playtest.sh"
  exit 1
fi

# A fresh checkout has no import cache; build it once, quietly.
if [ ! -d .godot ]; then
  echo "First run: building the import cache..."
  "$GODOT" --headless --import >/dev/null 2>&1 || true
fi

if [ "$MODE" = "editor" ]; then
  echo "Opening Project Charlie in the Godot editor..."
  exec "$GODOT" --path . --editor ${EXTRA[@]+"${EXTRA[@]}"}
fi

GAME_ARGS=(--mode="$MODE")
[ -n "$HERO" ] && GAME_ARGS+=(--hero="$HERO")
echo "Starting Project Charlie ($MODE${HERO:+, $HERO}). Close the window to stop."
exec "$GODOT" --path . ${EXTRA[@]+"${EXTRA[@]}"} -- "${GAME_ARGS[@]}"
