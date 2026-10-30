#!/usr/bin/env python3
"""Stamp each game's version onto every file its index.html loads, so
browsers and the iPad always fetch the newest copy after an update (copied
from Project Sam, where an old cached js file hid a new picture on
2026-10-24).

Charlie has two games, each in its own folder with its own js/version.js:
street/ (the street fight) and traitors/ (Charlie's Traitors). For each,
writes an import map (every js/*.js -> js/name.js?v=VERSION) and a
versioned stylesheet link into its index.html, between the STAMP markers.
Run after bumping a VERSION; a unit test in that game fails if you forget.
    python3 tools/stamp.py            both games
    python3 tools/stamp.py street     just one
"""
import pathlib, re, json, sys

top = pathlib.Path(__file__).resolve().parent.parent
games = sys.argv[1:] or ["street", "traitors"]
for game in games:
    root = top / game
    if not (root / "js/version.js").exists():
        continue
    version = re.search(r'VERSION = "([^"]+)"', (root / "js/version.js").read_text()).group(1)
    modules = sorted(p.name for p in (root / "js").glob("*.js"))
    imports = {f"./js/{m}": f"./js/{m}?v={version}" for m in modules}
    block = (
        "<!-- STAMP (tools/stamp.py writes this; don't edit by hand) -->\n"
        f'  <script type="importmap">{json.dumps({"imports": imports}, indent=2)}</script>\n'
        f'  <link rel="stylesheet" href="css/style.css?v={version}">\n'
        "  <!-- /STAMP -->"
    )
    html = (root / "index.html").read_text()
    html = re.sub(r"<!-- STAMP.*?<!-- /STAMP -->", lambda m: block, html, flags=re.S)
    html = re.sub(r'<script type="module" src="js/main\.js[^"]*"></script>',
                  f'<script type="module" src="js/main.js?v={version}"></script>', html)
    (root / "index.html").write_text(html)
    print(f"{game}: stamped v{version} on {len(modules)} modules")
