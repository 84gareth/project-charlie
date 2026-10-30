#!/usr/bin/env bash
# Play Charlie's games: serves this folder and opens it in the Mac's
# browser. The iPad can play the same copy over home Wi-Fi (the address is
# printed), or the published copy on GitHub Pages once changes are pushed.
#
# Usage: tools/playtest.sh [page] [boy|girl]
#   home       Charlie's home page, to pick a game (default)
#   street     the street game
#   practice   the street game, no baddies: try walking, sword and hammer
#   fight      the street game, a wave of bugs straight away, close by
#   helpers    the street game with 700 gems (all three helpers), a close wave
#   traitors   Charlie's Traitors
#   tests      the street game's tests, in a visible browser
#   traitors-tests / home-tests   the other test pages
#   boy, girl  play the street game as that hero
#
# Street game on the Mac: arrows or WASD to walk, Z or Space for the
# sword, X for the hammer. On the iPad: a thumb on the left walks, buttons
# on the right. Stop it with Ctrl+C (or the terminal's stop button).
set -euo pipefail
cd "$(dirname "$0")/.."

# Not 8000: Project Sam's launcher uses that, and an already-running Sam
# server would open Sam's game here (2026-10-30).
PORT=8020
PAGE=""
MODE=""
HERO=""
for arg in "$@"; do
  case "$arg" in
    home) PAGE="" ;;
    street) PAGE="street/" ;;
    practice|fight|helpers) PAGE="street/"; MODE="$arg" ;;
    boy|girl) PAGE="street/"; HERO="$arg" ;;
    traitors) PAGE="traitors/" ;;
    tests) PAGE="street/tests/" ;;
    traitors-tests) PAGE="traitors/tests/" ;;
    home-tests) PAGE="tests/" ;;
    -h|--help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg  (try: home, street, practice, fight, helpers, traitors, tests, boy, girl)"; exit 2 ;;
  esac
done

QUERY=""
[ -n "$MODE" ] && QUERY="mode=$MODE"
[ -n "$HERO" ] && QUERY="${QUERY:+$QUERY&}hero=$HERO"
PAGE="$PAGE${QUERY:+?$QUERY}"

STREET="$(sed -n 's/^export const VERSION = "\(.*\)";/\1/p' street/js/version.js)"
TRAITORS="$(sed -n 's/^export const VERSION = "\(.*\)";/\1/p' traitors/js/version.js)"
WIFI_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)"

echo "Starting Charlie's games (street v$STREET, Charlie's Traitors v$TRAITORS)"
echo "  On this Mac:       http://localhost:$PORT/$PAGE"
[ -n "$WIFI_IP" ] && echo "  On the iPad:       http://$WIFI_IP:$PORT/$PAGE   (same Wi-Fi)"
echo "  Published (iPad):  https://84gareth.github.io/project-charlie/"


# Already serving from an earlier run? Just open the page.
if python3 -c "import socket,sys; socket.create_connection(('127.0.0.1', $PORT), 0.2)" 2>/dev/null; then
  open "http://localhost:$PORT/$PAGE"
  exit 0
fi

( sleep 0.7; open "http://localhost:$PORT/$PAGE" ) &
# Serve to the home network too, so the iPad can reach it. Ctrl+C stops it.
# "no-store" stops browsers keeping old copies of the game's files (Project
# Sam, 2026-10-24: a stale file made a button do nothing).
exec python3 -c '
import http.server, sys
class NoCache(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()
http.server.ThreadingHTTPServer(("0.0.0.0", int(sys.argv[1])), NoCache).serve_forever()
' "$PORT"
