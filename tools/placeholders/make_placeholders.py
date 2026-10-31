#!/usr/bin/env python3
"""Placeholder pictures for Charlie's Traitors, until Charlie draws his own
(Gareth, 2026-10-30: "images you've generated as placeholders for now that
we can swap out later").

Writes simple cartoon SVGs: one per character (each in their own colour,
with a hint of who they are: a pirate hat, a chef's hat, a crown...), plus
the shield, the dagger, the fire pit and the two flames. Then
tools/image-fix/svg_to_png.gd turns them into the files the game loads:

    python3 tools/placeholders/make_placeholders.py
        writes the SVGs into tools/placeholders/svg/ and prints the Godot
        commands that make traitors/assets/... from them.

Every placeholder is replaced the same way Sam's drawings went in: see
traitors/docs/characters.md.
"""
import pathlib, re, sys

HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE / "svg"
INK = "#261a40"
PAPER = "#f7f3ea"
SKINS = ["#f5c9a0", "#e0a878", "#c68a5a", "#8d5a3b", "#f2d0b4", "#b9784f"]
HAIRS = ["#5a3a1e", "#1f1a17", "#c9792b", "#e8c46a", "#9a9a9a", "#7a2e1d"]


def shade(hex_colour, k):
    """Darker (k < 1) or lighter (k > 1) version of a colour."""
    r, g, b = (int(hex_colour[i:i + 2], 16) for i in (1, 3, 5))
    if k < 1:
        r, g, b = (int(c * k) for c in (r, g, b))
    else:
        r, g, b = (int(c + (255 - c) * (k - 1)) for c in (r, g, b))
    return f"#{r:02x}{g:02x}{b:02x}"


# What makes each one look like who they are. Keys are the ids in
# traitors/js/characters.js.
EXTRAS = {
    "puddle": {"hat": "pirate"},
    "gumdrop": {"hair": "bun", "hairc": "#cfcfcf", "prop": "sweets"},
    "fizz": {"hat": "goggles", "prop": "flask"},
    "ruby": {"hat": "stripy-cap"},
    "pepper": {"hat": "chef", "prop": "pie"},
    "waffle": {"hat": "helmet", "prop": "sword"},
    "plaster": {"hat": "doctor"},
    "lola": {"hat": "pink-cap", "prop": "mic"},
    "fern": {"hat": "straw"},
    "dot": {"hat": "deerstalker", "prop": "magnifier"},
    "benny": {"hat": "chef", "prop": "biscuit"},
    "mystic": {"hat": "crown", "prop": "ball"},
    "tom": {"tall": True},
    "zara": {"hat": "bike-helmet"},
    "grumble": {"glasses": True, "frown": True, "prop": "stick"},
    "penny": {"hat": "hood", "prop": "gem"},
    "kick": {"prop": "megaphone", "hair": "short"},
    "stan": {"hat": "station-cap", "tache": True},
    "ivy": {"glasses": True, "prop": "pencil"},
    "max": {"prop": "question"},
    "olive": {"oddsocks": True},
    "barry": {"hair": "big", "hairc": "#1f1a17", "prop": "banjo"},
}


def figure(i, colour, extra):
    """The character's drawing, feet at y=660, in a 440 x 700 box."""
    skin = SKINS[i % len(SKINS)]
    hairc = extra.get("hairc", HAIRS[i % len(HAIRS)])
    dark = shade(colour, 0.6)
    tall = extra.get("tall")
    leg_top = 420 if not tall else 330
    head_y = 175 if not tall else 95
    body_top = head_y + 70
    s = []
    # Legs and shoes (odd socks for Olive).
    for side, x in ((-1, 185), (1, 235)):
        s.append(f'<rect x="{x}" y="{leg_top}" width="30" height="{640 - leg_top}" rx="12" fill="{dark}" stroke="{INK}" stroke-width="7"/>')
        sock = ("#3fae5a" if side < 0 else "#e8e8e8") if extra.get("oddsocks") else None
        if sock:
            s.append(f'<rect x="{x}" y="590" width="30" height="40" fill="{sock}" stroke="{INK}" stroke-width="6"/>')
        s.append(f'<ellipse cx="{x + 15 + side * 6}" cy="648" rx="30" ry="15" fill="{INK}"/>')
    # Body and arms.
    s.append(f'<path d="M150 {leg_top + 10} Q140 {body_top + 40} 180 {body_top} L260 {body_top} Q300 {body_top + 40} 290 {leg_top + 10} Z" fill="{colour}" stroke="{INK}" stroke-width="8" stroke-linejoin="round"/>')
    s.append(f'<path d="M168 {body_top + 30} Q120 {body_top + 90} 130 {body_top + 150}" fill="none" stroke="{INK}" stroke-width="30" stroke-linecap="round"/>')
    s.append(f'<path d="M168 {body_top + 30} Q120 {body_top + 90} 130 {body_top + 150}" fill="none" stroke="{colour}" stroke-width="18" stroke-linecap="round"/>')
    s.append(f'<path d="M272 {body_top + 30} Q320 {body_top + 90} 310 {body_top + 150}" fill="none" stroke="{INK}" stroke-width="30" stroke-linecap="round"/>')
    s.append(f'<path d="M272 {body_top + 30} Q320 {body_top + 90} 310 {body_top + 150}" fill="none" stroke="{colour}" stroke-width="18" stroke-linecap="round"/>')
    hand_l, hand_r = (130, body_top + 158), (310, body_top + 158)
    for hx, hy in (hand_l, hand_r):
        s.append(f'<circle cx="{hx}" cy="{hy}" r="16" fill="{skin}" stroke="{INK}" stroke-width="6"/>')
    # Hair behind the head.
    hair = extra.get("hair", "short" if i % 3 else "long")
    if hair == "long":
        # Hanging down each side of the face (not under the chin, which
        # looked like a beard).
        for x in (140, 268):
            s.append(f'<rect x="{x}" y="{head_y - 30}" width="32" height="140" rx="16" fill="{hairc}" stroke="{INK}" stroke-width="6"/>')
    if hair == "big":
        s.append(f'<circle cx="220" cy="{head_y - 10}" r="95" fill="{hairc}" stroke="{INK}" stroke-width="6"/>')
    if hair == "bun":
        s.append(f'<circle cx="220" cy="{head_y - 80}" r="30" fill="{hairc}" stroke="{INK}" stroke-width="6"/>')
    # Head and face.
    s.append(f'<circle cx="220" cy="{head_y}" r="68" fill="{skin}" stroke="{INK}" stroke-width="8"/>')
    if hair in ("short", "long", "bun"):
        s.append(f'<path d="M154 {head_y - 10} Q160 {head_y - 80} 220 {head_y - 72} Q280 {head_y - 80} 286 {head_y - 10} Q250 {head_y - 45} 154 {head_y - 10} Z" fill="{hairc}" stroke="{INK}" stroke-width="6"/>')
    s.append(f'<circle cx="197" cy="{head_y + 2}" r="8" fill="{INK}"/><circle cx="243" cy="{head_y + 2}" r="8" fill="{INK}"/>')
    s.append(f'<circle cx="185" cy="{head_y + 28}" r="10" fill="#f28c8c" opacity="0.6"/><circle cx="255" cy="{head_y + 28}" r="10" fill="#f28c8c" opacity="0.6"/>')
    mouth = (f'M200 {head_y + 40} Q220 {head_y + 26} 240 {head_y + 40}' if extra.get("frown")
             else f'M198 {head_y + 30} Q220 {head_y + 52} 242 {head_y + 30}')
    s.append(f'<path d="{mouth}" fill="none" stroke="{INK}" stroke-width="6" stroke-linecap="round"/>')
    if extra.get("glasses"):
        s.append(f'<circle cx="197" cy="{head_y + 2}" r="20" fill="none" stroke="{INK}" stroke-width="6"/><circle cx="243" cy="{head_y + 2}" r="20" fill="none" stroke="{INK}" stroke-width="6"/><line x1="217" y1="{head_y + 2}" x2="223" y2="{head_y + 2}" stroke="{INK}" stroke-width="6"/>')
    if extra.get("tache"):
        s.append(f'<path d="M190 {head_y + 24} Q220 {head_y + 10} 250 {head_y + 24} Q220 {head_y + 36} 190 {head_y + 24} Z" fill="#5a3a1e" stroke="{INK}" stroke-width="4"/>')
    s.append(hat(extra.get("hat"), head_y, colour))
    s.append(prop(extra.get("prop"), hand_r, head_y))
    return "\n".join(x for x in s if x)


def hat(kind, y, colour):
    k = INK
    hats = {
        "pirate": f'<path d="M130 {y - 50} Q220 {y - 150} 310 {y - 50} Q220 {y - 75} 130 {y - 50} Z" fill="#1f1a17" stroke="{k}" stroke-width="6"/><circle cx="220" cy="{y - 88}" r="12" fill="#fff"/>',
        "goggles": f'<rect x="160" y="{y - 40}" width="120" height="30" rx="14" fill="#7fd3e8" stroke="{k}" stroke-width="6"/>',
        "stripy-cap": f'<path d="M150 {y - 40} Q220 {y - 120} 290 {y - 40} Z" fill="#3b6fb6" stroke="{k}" stroke-width="6"/><path d="M175 {y - 70} H265 M160 {y - 52} H280" stroke="#fff" stroke-width="7"/><rect x="270" y="{y - 46}" width="55" height="12" rx="6" fill="#3b6fb6" stroke="{k}" stroke-width="5"/>',
        "chef": f'<rect x="170" y="{y - 85}" width="100" height="40" fill="#fff" stroke="{k}" stroke-width="6"/><circle cx="185" cy="{y - 100}" r="28" fill="#fff" stroke="{k}" stroke-width="6"/><circle cx="220" cy="{y - 115}" r="32" fill="#fff" stroke="{k}" stroke-width="6"/><circle cx="255" cy="{y - 100}" r="28" fill="#fff" stroke="{k}" stroke-width="6"/>',
        "helmet": f'<path d="M150 {y} Q150 {y - 95} 220 {y - 95} Q290 {y - 95} 290 {y} Z" fill="#c9a24a" stroke="{k}" stroke-width="7"/><path d="M165 {y - 60} H275 M165 {y - 35} H275 M195 {y - 90} V{y - 5} M245 {y - 90} V{y - 5}" stroke="#8a6a2a" stroke-width="5"/>',
        "doctor": f'<path d="M160 {y - 45} Q220 {y - 110} 280 {y - 45} Z" fill="#fff" stroke="{k}" stroke-width="6"/><path d="M220 {y - 85} V{y - 55} M205 {y - 70} H235" stroke="#d63031" stroke-width="8"/>',
        "pink-cap": f'<path d="M150 {y - 40} Q220 {y - 120} 290 {y - 40} Z" fill="#f78fb3" stroke="{k}" stroke-width="6"/><rect x="270" y="{y - 46}" width="55" height="12" rx="6" fill="#f78fb3" stroke="{k}" stroke-width="5"/>',
        "straw": f'<ellipse cx="220" cy="{y - 50}" rx="110" ry="22" fill="#e8c46a" stroke="{k}" stroke-width="6"/><path d="M170 {y - 55} Q220 {y - 130} 270 {y - 55} Z" fill="#e8c46a" stroke="{k}" stroke-width="6"/>',
        "deerstalker": f'<path d="M150 {y - 35} Q220 {y - 125} 290 {y - 35} Z" fill="#9c6b3c" stroke="{k}" stroke-width="6"/><path d="M160 {y - 70} L130 {y - 40} M280 {y - 70} L310 {y - 40}" stroke="#9c6b3c" stroke-width="14" stroke-linecap="round"/>',
        "crown": f'<path d="M165 {y - 50} L165 {y - 110} L195 {y - 80} L220 {y - 120} L245 {y - 80} L275 {y - 110} L275 {y - 50} Z" fill="#f1c40f" stroke="{k}" stroke-width="6" stroke-linejoin="round"/>',
        "bike-helmet": f'<path d="M150 {y - 20} Q150 {y - 105} 220 {y - 105} Q300 {y - 105} 295 {y - 20} Z" fill="{colour}" stroke="{k}" stroke-width="7"/><path d="M190 {y - 100} V{y - 30} M250 {y - 100} V{y - 30}" stroke="#fff" stroke-width="6"/>',
        "hood": f'<path d="M140 {y + 40} Q130 {y - 110} 220 {y - 110} Q310 {y - 110} 300 {y + 40} Q290 {y - 60} 220 {y - 70} Q150 {y - 60} 140 {y + 40} Z" fill="#2e8b57" stroke="{k}" stroke-width="6"/>',
        "station-cap": f'<rect x="160" y="{y - 85}" width="120" height="40" rx="8" fill="#1f3a5f" stroke="{k}" stroke-width="6"/><rect x="150" y="{y - 50}" width="140" height="14" rx="7" fill="#1f3a5f" stroke="{k}" stroke-width="5"/><circle cx="220" cy="{y - 66}" r="8" fill="#f1c40f"/>',
    }
    return hats.get(kind, "")


def prop(kind, hand, y):
    hx, hy = hand
    k = INK
    props = {
        "sweets": f'<rect x="{hx - 30}" y="{hy}" width="60" height="55" rx="10" fill="#f78fb3" stroke="{k}" stroke-width="6"/><circle cx="{hx - 10}" cy="{hy + 25}" r="7" fill="#fff"/><circle cx="{hx + 12}" cy="{hy + 32}" r="7" fill="#7fd3e8"/>',
        "flask": f'<path d="M{hx - 10} {hy - 60} V{hy - 30} L{hx - 35} {hy + 20} H{hx + 35} L{hx + 10} {hy - 30} V{hy - 60} Z" fill="#9be36b" stroke="{k}" stroke-width="6"/><circle cx="{hx}" cy="{hy - 85}" r="16" fill="#f7dc6f" stroke="{k}" stroke-width="4"/>',
        "pie": f'<ellipse cx="{hx}" cy="{hy - 10}" rx="48" ry="20" fill="#d4a056" stroke="{k}" stroke-width="6"/><circle cx="{hx - 12}" cy="{hy - 16}" r="7" fill="#d63031"/><circle cx="{hx + 14}" cy="{hy - 12}" r="7" fill="#d63031"/>',
        "sword": f'<rect x="{hx - 6}" y="{hy - 150}" width="22" height="130" fill="#d4a056" stroke="{k}" stroke-width="5"/><path d="M{hx - 6} {hy - 120} H{hx + 16} M{hx - 6} {hy - 90} H{hx + 16} M{hx - 6} {hy - 60} H{hx + 16}" stroke="#8a6a2a" stroke-width="4"/>',
        "mic": f'<line x1="{hx}" y1="{hy}" x2="{hx}" y2="{hy - 70}" stroke="{k}" stroke-width="8"/><circle cx="{hx}" cy="{hy - 82}" r="16" fill="#555" stroke="{k}" stroke-width="5"/>',
        "magnifier": f'<line x1="{hx}" y1="{hy}" x2="{hx + 30}" y2="{hy - 40}" stroke="#7a4b23" stroke-width="10" stroke-linecap="round"/><circle cx="{hx + 48}" cy="{hy - 64}" r="28" fill="#cfefff" stroke="{k}" stroke-width="7"/>',
        "biscuit": f'<circle cx="{hx}" cy="{hy - 20}" r="30" fill="#d4a056" stroke="{k}" stroke-width="6"/><circle cx="{hx - 10}" cy="{hy - 26}" r="5" fill="#5a3a1e"/><circle cx="{hx + 9}" cy="{hy - 14}" r="5" fill="#5a3a1e"/>',
        "ball": f'<circle cx="{hx}" cy="{hy - 35}" r="36" fill="#a29bfe" stroke="{k}" stroke-width="6" opacity="0.9"/><circle cx="{hx - 12}" cy="{hy - 48}" r="9" fill="#fff" opacity="0.8"/>',
        "stick": f'<path d="M{hx} {hy} V{hy + 150}" stroke="#7a4b23" stroke-width="12" stroke-linecap="round"/>',
        "gem": f'<path d="M{hx} {hy - 70} L{hx + 28} {hy - 40} L{hx} {hy - 5} L{hx - 28} {hy - 40} Z" fill="#3498db" stroke="{k}" stroke-width="6"/>',
        "megaphone": f'<path d="M{hx - 10} {hy - 20} L{hx + 50} {hy - 55} V{hy + 15} Z" fill="#e74c3c" stroke="{k}" stroke-width="6" stroke-linejoin="round"/>',
        "pencil": f'<path d="M{hx} {hy} L{hx + 20} {hy - 90}" stroke="#f1c40f" stroke-width="16" stroke-linecap="round"/><path d="M{hx} {hy} L{hx + 4} {hy - 16}" stroke="{k}" stroke-width="8"/>',
        # Drawn, not typed: the SVG reader can't draw text.
        "question": (f'<path d="M300 {y - 100} Q300 {y - 145} 340 {y - 145} Q380 {y - 145} 380 {y - 105} Q380 {y - 75} 340 {y - 60} V{y - 35}" fill="none" stroke="{k}" stroke-width="26" stroke-linecap="round"/>'
                     f'<path d="M300 {y - 100} Q300 {y - 145} 340 {y - 145} Q380 {y - 145} 380 {y - 105} Q380 {y - 75} 340 {y - 60} V{y - 35}" fill="none" stroke="#e67e22" stroke-width="16" stroke-linecap="round"/>'
                     f'<circle cx="340" cy="{y}" r="14" fill="#e67e22" stroke="{k}" stroke-width="5"/>'),
        "banjo": f'<line x1="{hx}" y1="{hy}" x2="{hx - 60}" y2="{hy - 130}" stroke="#7a4b23" stroke-width="14" stroke-linecap="round"/><circle cx="{hx + 10}" cy="{hy + 15}" r="40" fill="#f3e5c0" stroke="{k}" stroke-width="7"/>',
    }
    return props.get(kind, "")


def character_svg(i, c, background):
    bg = f'<rect width="440" height="700" fill="{PAPER}"/>' if background else ""
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="440" height="700" viewBox="0 0 440 700">'
            f'{bg}{figure(i, c["colour"], EXTRAS.get(c["id"], {}))}</svg>')


# The shield, dagger, fire pit and flames, in the sizes the game uses.
ITEMS = {
    "shield": (169, 240, f'<path d="M15 25 Q85 0 154 25 V120 Q150 200 85 232 Q20 200 15 120 Z" fill="#3b6fb6" stroke="{INK}" stroke-width="10"/><path d="M85 60 L100 100 L142 100 L108 124 L121 166 L85 140 L49 166 L62 124 L28 100 L70 100 Z" fill="#f1c40f" stroke="{INK}" stroke-width="5"/>'),
    "dagger": (181, 240, f'<path d="M90 8 L112 150 H68 Z" fill="#d9e2ec" stroke="{INK}" stroke-width="8" stroke-linejoin="round"/><rect x="35" y="148" width="110" height="20" rx="8" fill="#c0392b" stroke="{INK}" stroke-width="7"/><rect x="78" y="168" width="24" height="56" rx="8" fill="#6d4c2e" stroke="{INK}" stroke-width="7"/>'),
    "fire-pit": (235, 200, f'<path d="M50 120 L185 170 M50 170 L185 120" stroke="#7a4b23" stroke-width="22" stroke-linecap="round"/><ellipse cx="117" cy="160" rx="108" ry="34" fill="none" stroke="#8a8f99" stroke-width="22"/><ellipse cx="117" cy="160" rx="108" ry="34" fill="none" stroke="{INK}" stroke-width="4"/>'),
    "flame-green": (180, 300, f'<path d="M90 10 Q160 110 150 200 Q140 290 90 292 Q40 290 30 200 Q22 120 70 90 Q75 140 95 150 Q80 80 90 10 Z" fill="#3fd06a" stroke="{INK}" stroke-width="8" stroke-linejoin="round"/><path d="M90 140 Q125 200 115 250 Q90 275 65 250 Q60 210 90 140 Z" fill="#b8f5a6"/>'),
    "flame-red": (180, 300, f'<path d="M90 10 Q160 110 150 200 Q140 290 90 292 Q40 290 30 200 Q22 120 70 90 Q75 140 95 150 Q80 80 90 10 Z" fill="#e8452c" stroke="{INK}" stroke-width="8" stroke-linejoin="round"/><path d="M90 140 Q125 200 115 250 Q90 275 65 250 Q60 210 90 140 Z" fill="#f9c74f"/>'),
}


# Charlie has drawn these: never make a placeholder over his drawing. Add
# each new one here (and delete its SVGs). See tools/image-fix/charlie_traitors.sh.
DRAWN = {"dot", "max", "zara", "kick", "fizz", "tom", "dagger", "shield"}


def characters():
    """Each character's id and colour, read from the game's own list."""
    src = (HERE.parent.parent / "traitors/js/characters.js").read_text()
    return [{"id": m.group(1), "colour": m.group(2)}
            for m in re.finditer(r'id: "([a-z]+)",.*?colour: "(#[0-9a-f]{6})"', src, re.S)]


def main():
    chars = characters()
    if len(chars) != 22:
        sys.exit(f"expected 22 characters in traitors/js/characters.js, found {len(chars)}")
    OUT.mkdir(exist_ok=True)
    for i, c in enumerate(chars):
        if c["id"] in DRAWN:
            continue
        (OUT / f'{c["id"]}.svg').write_text(character_svg(i, c, True))
        (OUT / f'{c["id"]}-puppet.svg').write_text(character_svg(i, c, False))
    for name, (w, h, body) in ITEMS.items():
        if name in DRAWN:
            continue
        (OUT / f"{name}.svg").write_text(
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{body}</svg>')
    print(f"wrote the SVGs to {OUT}, skipping Charlie's drawings")


main()
