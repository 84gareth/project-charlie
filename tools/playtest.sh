#!/usr/bin/env bash
# Play the game: serves this folder and opens it in the Mac's browser.
# The iPad can play the same copy over home Wi-Fi (the address is printed),
# or the published copy on GitHub Pages once changes are pushed.
#
# Usage: tools/playtest.sh [mode] [boy|girl]
#   street     the normal game (default)
#   practice   no baddies: try walking, the sword and the hammer
#   fight      the first wave of baddies turns up straight away, close by
#   helpers    start with 700 gems, so all three helpers, then a close wave
#   tests      the test page, in a visible browser
#   boy, girl  play as that hero
#
# On the Mac: arrows or WASD to walk, Z or Space for the sword, X for the
# hammer. On the iPad: a thumb on the left walks, buttons on the right.
# Stop it with Ctrl+C (or the terminal's stop button).
set -euo pipefail
cd "$(dirname "$0")/.."

PORT=8000
MODE=""
HERO=""
TESTS=""
for arg in "$@"; do
  case "$arg" in
    street) MODE="" ;;
    practice|fight|helpers) MODE="$arg" ;;
    boy|girl) HERO="$arg" ;;
    tests) TESTS="yes" ;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg  (try: street, practice, fight, helpers, tests, boy, girl)"; exit 2 ;;
  esac
done

QUERY=""
[ -n "$MODE" ] && QUERY="mode=$MODE"
[ -n "$HERO" ] && QUERY="${QUERY:+$QUERY&}hero=$HERO"
PAGE="${QUERY:+?$QUERY}"
[ -n "$TESTS" ] && PAGE="tests/"

VERSION="$(sed -n 's/^export const VERSION = "\(.*\)";/\1/p' js/version.js)"
WIFI_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)"

echo "Starting Project Charlie v$VERSION"
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
