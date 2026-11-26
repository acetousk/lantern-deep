"""Makes the pixel art for Lantern Deep. Uses only the Ember Cave palette.

Run:  python3 tools/make_sprites.py
Writes 16x16 PNGs into art/.
"""
import random
from pathlib import Path

from PIL import Image

# Ember Cave palette (from DESIGN.md)
BLACK = "#1a1410"   # black-brown
DARK = "#3b2f2a"    # dark stone
ROCK = "#6b5a4e"    # rock
ORANGE = "#f2a33a"  # lantern orange
YELLOW = "#ffd966"  # flame yellow
GREEN = "#7fae5a"   # slime green
RED = "#c8443a"     # blood red
BONE = "#e8dcc4"    # bone white

SIZE = 16
OUT = Path(__file__).resolve().parent.parent / "art"


def new(color=None):
    """A blank 16x16 image. No color = see-through."""
    if color is None:
        return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    return Image.new("RGBA", (SIZE, SIZE), color)


def from_rows(rows, colors):
    """Draw a sprite from 16 text rows. Each letter is a color, '.' is see-through."""
    img = new()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                img.putpixel((x, y), _rgb(colors[ch]))
    return img


def floor_tile():
    rng = random.Random(1)  # same seed = same picture every time
    img = new(DARK)
    for _ in range(10):  # little pebbles
        img.putpixel((rng.randrange(SIZE), rng.randrange(SIZE)), _rgb(ROCK))
    for _ in range(6):   # little cracks
        img.putpixel((rng.randrange(SIZE), rng.randrange(SIZE)), _rgb(BLACK))
    return img


def wall_tile():
    # Rough stone bricks: rock with dark lines, light top edge.
    rows = [
        "BBBBBBBBBBBBBBBB",
        "RRRRRRRDRRRRRRRR",
        "RRRRRRRDRRRRRRRR",
        "RRRRRRRDRRRRRRRR",
        "RRRRRRRDRRRRRRRR",
        "RRRRRRRDRRRRRRRR",
        "RRRRRRRDRRRRRRRR",
        "DDDDDDDDDDDDDDDD",
        "RRRDRRRRRRRRRDRR",
        "RRRDRRRRRRRRRDRR",
        "RRRDRRRRRRRRRDRR",
        "RRRDRRRRRRRRRDRR",
        "RRRDRRRRRRRRRDRR",
        "RRRDRRRRRRRRRDRR",
        "DDDDDDDDDDDDDDDD",
        "KKKKKKKKKKKKKKKK",
    ]
    return from_rows(rows, {"B": BONE, "R": ROCK, "D": DARK, "K": BLACK})


def stairs_tile():
    # Steps going down into the dark, with an orange glow at the bottom.
    rows = [
        "DDDDDDDDDDDDDDDD",
        "DBBBBBBBBBBBBBBD",
        "DRRRRRRRRRRRRRRD",
        "DKKKKKKKKKKKKKKD",
        "DDBBBBBBBBBBBBDD",
        "DDRRRRRRRRRRRRDD",
        "DDKKKKKKKKKKKKDD",
        "DDDBBBBBBBBBBDDD",
        "DDDRRRRRRRRRRDDD",
        "DDDKKKKKKKKKKDDD",
        "DDDDBBBBBBBBDDDD",
        "DDDDRRRRRRRRDDDD",
        "DDDDKKKKKKKKDDDD",
        "DDDDDKKOOKKDDDDD",
        "DDDDDKOYYOKDDDDD",
        "DDDDDDDDDDDDDDDD",
    ]
    return from_rows(rows, {"B": BONE, "R": ROCK, "D": DARK, "K": BLACK, "O": ORANGE, "Y": YELLOW})


def player():
    # The lantern guy: dark hood, bone face, red cloak, lantern in his right hand.
    rows = [
        "................",
        "......DDDD......",
        ".....DRRRRD.....",
        ".....RBBBBR.....",
        ".....RBKBKR.....",
        ".....RBBBBR.....",
        "......RRRR...K..",
        ".....DRRRRD..K..",
        "....DRRRRRRBOYO.",
        "....RRRRRRR.OYO.",
        "....RRRRRRR.OOO.",
        "....DRRRRRD.....",
        ".....RRRRR......",
        ".....RR.RR......",
        ".....DD.DD......",
        "................",
    ]
    return from_rows(rows, {"D": DARK, "R": RED, "B": BONE, "K": BLACK, "O": ORANGE, "Y": YELLOW})


def slime():
    # Mire Slime: a green blob with bone eyes.
    rows = [
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "......GGGG......",
        "....GGGGGGGG....",
        "...GGBKGGBKGG...",
        "..GGGGGGGGGGGG..",
        "..GGGGGKKGGGGG..",
        "..GGGGGGGGGGGG..",
        "...KKKKKKKKKK...",
        "................",
        "................",
    ]
    return from_rows(rows, {"G": GREEN, "B": BONE, "K": BLACK})


def moth():
    # Cave Moth: pale wings with rock spots and red eyes.
    rows = [
        "................",
        "................",
        "..WW........WW..",
        ".WSWW..EE..WWSW.",
        ".WWWWW.EE.WWWWW.",
        "..WWWWBEEBWWWW..",
        "...WWWBBBBWWW...",
        "....WWBBBBWW....",
        "...WWWBBBBWWW...",
        "..WSWW.BB.WWSW..",
        "..WWW..BB..WWW..",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    return from_rows(rows, {"W": BONE, "S": ROCK, "B": ROCK, "E": RED})


def warden():
    # Bone Warden: a skeleton guard with glowing red eyes.
    rows = [
        "................",
        ".....BBBBBB.....",
        "....BBBBBBBB....",
        "....BKKBBKKB....",
        "....BKRBBKRB....",
        "....BBBBBBBB....",
        ".....BKBKBKB....",
        "......BBBB......",
        "...BBBBBBBBBB...",
        "..B..BKBKBK..B..",
        "..B..BBBBBB..B..",
        "..B..BKBKBK..B..",
        ".....BBBBBB.....",
        ".....BB..BB.....",
        ".....BB..BB.....",
        "....BBB..BBB....",
    ]
    return from_rows(rows, {"B": BONE, "K": BLACK, "R": RED})


def relic():
    # The Ember Relic: a glowing ember gem on a bone stand.
    rows = [
        "................",
        "................",
        ".......YY.......",
        "......YOOY......",
        ".....YOROOY.....",
        "....YORRROOY....",
        "....YORRROOY....",
        ".....YORROY.....",
        "......YOOY......",
        ".......YY.......",
        "................",
        "....BBBBBBBB....",
        ".....BBBBBB.....",
        "......BBBB......",
        "....BBBBBBBB....",
        "................",
    ]
    return from_rows(rows, {"Y": YELLOW, "O": ORANGE, "R": RED, "B": BONE})


def potion():
    # A white potion. The game tints it a random color each run.
    # (White and gray are not palette colors, but the tint turns them into one.)
    rows = [
        "................",
        "................",
        "................",
        "......GGGG......",
        ".......WW.......",
        ".......WW.......",
        "......WWWW......",
        ".....WWWWWW.....",
        "....WWWWWWGG....",
        "...WWWWWWWWGG...",
        "...WWWWWWWWGG...",
        "...WWWWWWWWGG...",
        "....WWWWWWGG....",
        ".....GGGGGG.....",
        "................",
        "................",
    ]
    return from_rows(rows, {"W": "#ffffff", "G": "#a0a0a0"})


def _rgb(hex_color):
    h = hex_color.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


SPRITES = {
    "floor": floor_tile,
    "wall": wall_tile,
    "stairs": stairs_tile,
    "player": player,
    "slime": slime,
    "moth": moth,
    "warden": warden,
    "relic": relic,
    "potion": potion,
}


def main():
    OUT.mkdir(exist_ok=True)
    for name, make in SPRITES.items():
        path = OUT / f"{name}.png"
        make().save(path)
        print("wrote", path.relative_to(OUT.parent))


if __name__ == "__main__":
    main()
