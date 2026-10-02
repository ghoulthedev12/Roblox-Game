"""Batch 11 of the meme sculptures: World 7 (the spooky world).
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp
from memes_batch7 import shiba

for _name, _c in [
    ("pumpkin", (245, 130, 30)), ("pumpkindark", (190, 90, 20)), ("stem", (90, 120, 50)), ("candle", (255, 220, 100)),
    ("frog", (100, 180, 80)), ("froglight", (180, 225, 140)), ("sheet", (245, 245, 250)), ("hamster2", (235, 180, 120)),
    ("violin", (160, 80, 40)), ("chalk", (250, 250, 250)), ("chalkboard", (40, 70, 55)), ("banana", (255, 225, 70)),
    ("bananatip", (110, 80, 40)), ("cookie", (200, 140, 80)), ("icing", (255, 160, 210)), ("rainbow1", (255, 60, 60)),
    ("rainbow2", (255, 160, 40)), ("rainbow3", (255, 230, 50)), ("rainbow4", (70, 210, 90)), ("rainbow5", (60, 140, 255)),
    ("rainbow6", (150, 80, 220)), ("comicpink", (255, 80, 200)), ("comiccyan", (40, 200, 230)), ("comicgreen", (60, 210, 60)),
    ("tabby", (150, 140, 130)), ("tabbydark", (95, 88, 82)), ("ginger", (220, 110, 40)), ("plaid", (190, 50, 50)),
    ("yearbook", (90, 140, 220)), ("ghostblue", (200, 230, 255)), ("lanternglow", (255, 210, 90)), ("grave", (130, 130, 140)),
    ("grass2", (60, 110, 60)), ("bandage2", (230, 225, 200)), ("rot", (110, 150, 120)), ("sanic", (40, 90, 230)),
]:
    rgb(_name, *_c)


# ------------------------------------------------------------------------------------------
# helpers
# ------------------------------------------------------------------------------------------
def bone(m, a, b, r=0.07, color="bone"):
    m.tube(color, [a, b], r)
    for p in (a, b):
        m.blob(color, (r * 3.2, r * 3.2, r * 3.2), p)


def skull(m, c, size=1.0, color="bone", grin=True):
    x, y, z = c
    m.squircle(color, (0.8 * size, 0.78 * size, 0.78 * size), (x, y, z), power=2.6)
    m.squircle(color, (0.55 * size, 0.55 * size, 0.32 * size), (x, y - 0.05 * size, z - 0.4 * size), power=3)  # jaw
    for s in (-1, 1):
        m.blob("black", (0.22 * size, 0.1 * size, 0.24 * size), (x + s * 0.17 * size, y - 0.36 * size, z + 0.02 * size))
    m.relief("black", [(-0.05 * size, 0), (0.05 * size, 0), (0, 0.1 * size)], 0.05, (x, y - 0.38 * size, z - 0.16 * size), bevel=0)
    if grin:
        m.tube("black", [(x - 0.2 * size, y - 0.35 * size, z - 0.36 * size), (x, y - 0.37 * size, z - 0.42 * size),
                         (x + 0.2 * size, y - 0.35 * size, z - 0.36 * size)], 0.015 * size + 0.005)
        for k in range(5):
            m.box("black", (0.012, 0.02, 0.1 * size), (x - 0.12 * size + k * 0.06 * size, y - 0.36 * size, z - 0.4 * size), bevel=0)


def skeleton(m, hip=(0, 0, 1.6), arms=None, legs=None, color="bone"):
    """A dancing cartoon skeleton: pelvis, spine, ribcage, skull and bone limbs.
    arms = {"l": (elbow, hand), "r": ...}, legs = {-1: (knee, foot), 1: ...} (absolute points)."""
    hx, hy, hz = hip
    m.squircle(color, (0.7, 0.4, 0.3), (hx, hy, hz), power=3)  # pelvis
    for k in range(5):  # spine
        m.blob(color, (0.16, 0.16, 0.14), (hx, hy + 0.05, hz + 0.25 + k * 0.17))
    for k in range(4):  # ribs
        m.torus(color, 0.38 - abs(k - 1) * 0.04, 0.04, (hx, hy, hz + 0.65 + k * 0.17), scale=(1, 0.7, 0.6))
    sh_z = hz + 1.32
    m.squircle(color, (1.0, 0.25, 0.12), (hx, hy, sh_z), power=3)  # collarbones
    skull(m, (hx, hy - 0.05, sh_z + 0.62), 1.0, color)
    arms = arms or {}
    for key, s in (("l", -1), ("r", 1)):
        sh = (hx + s * 0.48, hy, sh_z)
        el, ha = arms.get(key, ((hx + s * 0.6, hy, sh_z - 0.55), (hx + s * 0.65, hy - 0.05, sh_z - 1.1)))
        bone(m, sh, el, 0.055, color)
        bone(m, el, ha, 0.05, color)
        for f in range(3):
            m.cyl(color, 0.025, 0.2, (ha[0] + (f - 1) * 0.05, ha[1], ha[2] - 0.12), seg=6)
    legs = legs or {}
    for s in (-1, 1):
        top = (hx + s * 0.22, hy, hz - 0.1)
        kn, ft = legs.get(s, ((hx + s * 0.24, hy - 0.03, hz * 0.5), (hx + s * 0.25, hy, 0.12)))
        bone(m, top, kn, 0.065, color)
        bone(m, kn, ft, 0.06, color)
        m.squircle(color, (0.22, 0.45, 0.12), (ft[0], ft[1] - 0.15, ft[2] - 0.02), power=3)


def tablet(m, color="stone", dark="stonedark", width=2.6, height=3.6):
    """An upright stone tablet with a rounded top on a base; returns the carving plane y."""
    m.squircle(dark, (width + 0.4, 1.3, 0.35), (0, 0, 0.17), power=4)
    pts = [(-width / 2, 0), (width / 2, 0), (width / 2, height - width / 2)]
    for k in range(1, 12):
        a = k / 12 * math.pi
        pts.append((math.cos(a) * width / 2, height - width / 2 + math.sin(a) * width / 2))
    pts.append((-width / 2, height - width / 2))
    m.relief(color, pts, 0.45, (0, 0, 0.34), bevel=0.08)
    return -0.24


def sheet_ghost(m, c, h=2.4, w=1.6, color="sheet", eyes=True):
    """A bedsheet ghost: a rounded dome with a wavy hem and two eye holes."""
    x, y, z = c
    prof = [(0, z + h), (w * 0.3, z + h - 0.04), (w * 0.45, z + h - 0.35), (w * 0.5, z + h * 0.45), (w * 0.62, z + 0.12), (w * 0.66, z)]
    m.lathe(color, [(r, zz - z) for r, zz in prof][::-1], (x, y, z), seg=32)
    for k in range(8):  # wavy hem
        a = k / 8 * math.tau
        m.blob(color, (0.45, 0.45, 0.3), (x + math.cos(a) * w * 0.6, y + math.sin(a) * w * 0.6, z + 0.05))
    if eyes:
        for s in (-1, 1):
            m.blob("black", (0.24, 0.12, 0.34), (x + s * 0.22, y - w * 0.48, z + h * 0.72))


# ------------------------------------------------------------------------------------------
# memes
# ------------------------------------------------------------------------------------------
def spooky_skeleton():
    m = Meme("SpookySkeleton")
    # a skeleton mid-jig on a gravestone stage, top hat on, rattling away
    m.squircle("grass2", (3.2, 2.0, 0.15), (0, 0, 0.07), power=3)
    skeleton(m, hip=(0, 0, 1.7),
             arms={"l": ((-0.85, -0.2, 3.3), (-1.2, -0.3, 3.9)), "r": ((0.8, -0.2, 2.6), (1.25, -0.35, 2.95))},
             legs={-1: ((-0.35, -0.2, 0.9), (-0.45, -0.1, 0.14)), 1: ((0.5, -0.5, 1.4), (0.35, -0.3, 0.75))})
    m.lathe("black", [(0.55, 0), (0.55, 0.04), (0.3, 0.06), (0.3, 0.6), (0, 0.6)], (0.05, -0.05, 3.65), rot=(0, 10, 0))  # top hat
    m.cyl("red", 0.31, 0.1, (0.07, -0.05, 3.78), rot=(0, 10, 0), seg=24)
    for k in range(3):  # rattle lines
        m.box("white", (0.04, 0.04, 0.3), (1.0 + k * 0.15, -0.3, 1.8 + k * 0.2), rot=(0, 30, 0), bevel=0.01)
    m.relief("grave", [(-0.4, 0), (0.4, 0), (0.4, 0.8), (0, 1.05), (-0.4, 0.8)], 0.2, (1.3, 0.6, 0.14), bevel=0.05)
    return m


def pumpkin_dancer():
    m = Meme("PumpkinDancer")
    # a pumpkin-headed man in a suit, mid-dance, carved grin glowing
    p = mp.person(m, skin="skin", shirt="suit", pants="suit", shoes="black", hair=None, hair_style="bald", head=0.2,
                  expr="flat", face_kw={"brows": None, "nose": False},
                  legs={-1: ((-0.3, -0.1, 0.9), (-0.35, 0.0, 0.16)), 1: ((0.45, -0.45, 1.25), (0.4, -0.25, 0.6))},
                  arms={"l": ((-1.0, -0.2, 2.7), (-1.15, -0.3, 3.3)), "r": ((0.95, -0.2, 2.35), (1.35, -0.35, 2.0))})
    hz = p["shoulder_z"] + 0.85
    for k in range(8):  # pumpkin ribs
        a = k / 8 * math.tau
        m.blob("pumpkin", (0.7, 0.7, 1.05), (math.cos(a) * 0.35, math.sin(a) * 0.32, hz))
    m.cyl("stem", 0.1, 0.35, (0, 0, hz + 0.55), rot=(10, 0, 0), seg=10)
    for s in (-1, 1):
        m.relief("candle", [(-0.15, 0), (0.15, 0), (0, 0.22)], 0.06, (s * 0.28, -0.7, hz + 0.08), bevel=0)
    m.relief("candle", [(-0.42, 0.1), (-0.2, 0), (-0.1, 0.08), (0, -0.02), (0.1, 0.08), (0.2, 0), (0.42, 0.1), (0.25, -0.18), (-0.25, -0.18)],
             0.06, (0, -0.7, hz - 0.25), bevel=0)
    m.squircle("orange", (0.25, 0.05, 0.2), (0, -0.36, p["shoulder_z"] - 0.05), power=3)  # bow tie
    return m


def ghostly_swamp_frog():
    m = Meme("GhostlySwampFrog")
    # a round little frog hiding under a bedsheet, its webbed feet and big eyes peeking out
    m.squircle("grass2", (3.0, 2.4, 0.15), (0, 0, 0.07), power=3)
    for k in range(3):
        m.cyl("frog", 0.5 - k * 0.1, 0.06, (-1.1 + k * 0.4, 0.6 - k * 0.2, 0.15), seg=20)  # lily pads
    sheet_ghost(m, (0, 0, 0.15), h=3.0, w=2.2, eyes=False)
    for s in (-1, 1):  # holes cut out where the frog's bulging eyes push through
        m.blob("frog", (0.55, 0.5, 0.55), (s * 0.4, -0.9, 2.75))
        m.eye((s * 0.4, -1.0, 2.75), (0.42, 0.3, 0.42), iris="black", look=(0, -0.2))
        m.squircle("frog", (0.55, 0.7, 0.18), (s * 0.6, -1.4, 0.2), power=2.5)  # webbed feet
        for f in range(3):
            m.blob("froglight", (0.14, 0.14, 0.1), (s * 0.6 + (f - 1) * 0.18, -1.75, 0.22))
    m.text("ink", "boo...", (0, -1.4, 3.9), size=0.32, depth=0.04)
    return m


def bonk_shiba():
    m = Meme("BonkShiba")
    # a shiba swinging a baseball bat down onto a cowering little shiba: bonk, go to jail
    m.squircle("green", (4.2, 2.0, 0.12), (0, 0, 0.06), power=4)
    shiba(m, -0.7, 0.0, 0.95, buff=True)
    shiba(m, 1.35, -0.2, 0.7, sad=True)
    m.cyl("wood", 0.08, 2.0, (0.5, -0.4, 4.2), rot=(0, 65, 0), radius2=0.15, seg=14)  # the bat
    m.relief("yellow", [(math.cos(a) * (0.55 if i % 2 == 0 else 0.3), math.sin(a) * (0.55 if i % 2 == 0 else 0.3))
                        for i, a in enumerate([k / 16 * math.tau for k in range(16)])], 0.08, (1.4, -0.4, 2.0))
    m.text("red", "BONK", (1.4, -0.48, 2.0), size=0.26, depth=0.04)
    return m


def sad_violin_hamster():
    m = Meme("SadViolinHamster")
    # a small hamster with huge watery eyes, playing a tiny violin
    m.squircle("hamster2", (2.0, 1.7, 1.9), (0, 0, 1.15), power=2.2)
    m.blob("cream", (1.3, 0.6, 1.3), (0, -0.62, 1.05))
    m.squircle("hamster2", (1.9, 1.6, 1.55), (0, -0.05, 2.5), power=2.3)
    for s in (-1, 1):
        m.blob("hamster2", (0.5, 0.25, 0.5), (s * 0.7, 0.1, 3.25))
        m.blob("pink", (0.3, 0.15, 0.3), (s * 0.7, 0.0, 3.25))
        m.eye((s * 0.38, -0.72, 2.65), (0.6, 0.3, 0.68), iris="black", look=(0, 0.4))
        m.blob("sky", (0.12, 0.06, 0.4), (s * 0.55, -0.82, 2.25))  # big tears
        m.box("hamsterdark", (0.35, 0.05, 0.07), (s * 0.38, -0.82, 3.05), rot=(0, s * 20, 0), bevel=0.02)  # sad brows
        m.squircle("hamsterdark", (0.5, 0.6, 0.25), (s * 0.5, -0.35, 0.13), power=2.5)
    m.blob("pink", (0.16, 0.1, 0.12), (0, -0.85, 2.4))
    m.tube("mouth", [(-0.12, -0.82, 2.18), (0, -0.83, 2.23), (0.12, -0.82, 2.18)], 0.02)
    # the violin under its chin, bow in the other paw
    m.squircle("violin", (0.55, 0.2, 0.95), (-0.55, -0.85, 1.75), rot=(0, 35, 0), power=2.2)
    m.box("black", (0.08, 0.06, 0.8), (-0.95, -0.9, 2.3), rot=(0, 35, 0), bevel=0.02)
    m.tube("hamster2", [(-0.8, -0.3, 1.9), (-0.8, -0.8, 1.6)], 0.15)
    m.tube("hamster2", [(0.8, -0.3, 1.9), (0.7, -0.85, 1.7)], 0.15)
    m.cyl("wood", 0.025, 1.4, (0.2, -0.95, 1.95), rot=(0, -60, 0), seg=6)  # bow
    for k in range(3):
        m.blob("black", (0.16, 0.08, 0.12), (1.0 + k * 0.3, -0.5, 3.3 + k * 0.25), rot=(0, -20, 0))
        m.cyl("black", 0.02, 0.35, (1.07 + k * 0.3, -0.5, 3.47 + k * 0.25), seg=6)
    return m


def confused_math_cat():
    m = Meme("ConfusedMathCat")
    # a cat staring blankly while math equations float around its head
    m.squircle("tabby", (1.8, 1.5, 1.8), (0, 0.1, 1.0), power=2.2)  # sitting body
    m.blob("white", (1.0, 0.5, 1.1), (0, -0.55, 1.0))
    for s in (-1, 1):
        m.squircle("white", (0.35, 0.5, 0.25), (s * 0.35, -0.65, 0.13), power=2.5)
    m.tube("tabby", [(0.8, 0.6, 0.3), (1.2, 0.3, 0.6), (1.1, 0.0, 1.0)], lambda t: 0.15 - 0.05 * t)
    m.squircle("tabby", (1.6, 1.35, 1.25), (0, -0.05, 2.45), power=2.4)
    for k in range(3):
        m.box("tabbydark", (0.08, 0.05, 0.3), (-0.2 + k * 0.2, -0.7, 2.9), bevel=0.02)  # forehead stripes
    for s in (-1, 1):
        mp.ear(m, "tabby", (s * 0.5, 0.0, 2.9), (s * 0.65, 0.05, 3.5), width=0.3, inner="pink", thick=0.1)
        m.eye((s * 0.32, -0.62, 2.55), (0.38, 0.18, 0.4), iris="sticker2", pupil="black", look=(s * 0.5, 0.3))  # eyes looking different ways
        for k in range(3):
            m.box("gray", (0.45, 0.02, 0.02), (s * 0.7, -0.6, 2.25 + k * 0.07), rot=(0, s * (k - 1) * 12, 0), bevel=0)
    m.blob("pink", (0.12, 0.08, 0.08), (0, -0.72, 2.35))
    m.tube("mouth", [(-0.1, -0.7, 2.2), (0.1, -0.7, 2.22)], 0.02)
    for k, (eq, x, z, r) in enumerate([("x²", -1.2, 3.7, 10), ("π", 1.2, 3.6, -10), ("?", 0, 4.2, 0), ("√2", -1.4, 2.8, 0), ("=?", 1.4, 2.7, 0)]):
        m.text("comiccyan" if k % 2 else "chalk", eq, (x, -0.3, z), size=0.4, depth=0.05, rot=(0, r, 0))
    return m


def jelly_time_banana():
    m = Meme("JellyTimeBanana")
    # a dancing banana with noodle arms up, kicking a leg: it's jelly time
    pts = [(0.4, 0, 0.9), (0.1, 0, 1.8), (0.0, 0, 2.7), (0.15, 0, 3.6), (0.5, 0, 4.2)]
    m.tube("banana", pts, lambda t: 0.25 + 0.3 * math.sin(t * math.pi), seg=16)
    m.cyl("bananatip", 0.12, 0.25, (0.6, 0, 4.35), rot=(0, 40, 0), seg=10)
    m.blob("bananatip", (0.2, 0.2, 0.2), (0.38, 0, 0.82))
    for s in (-1, 1):
        m.eye((0.05 + s * 0.18, -0.48, 3.0), (0.28, 0.16, 0.34), iris="black")
    m.blob("mouth", (0.35, 0.1, 0.3), (0.05, -0.5, 2.55))
    m.tube("white", [(-0.45, 0, 2.6), (-1.0, -0.1, 3.2), (-1.1, -0.15, 3.8)], 0.06)  # arms up
    m.tube("white", [(0.55, 0, 2.6), (1.1, -0.1, 3.2), (1.25, -0.15, 3.7)], 0.06)
    for p in ((-1.1, -0.15, 3.85), (1.25, -0.15, 3.75)):
        m.blob("white", (0.25, 0.2, 0.25), p)
    m.tube("white", [(0.2, 0, 1.2), (-0.1, -0.1, 0.6), (-0.15, -0.05, 0.15)], 0.06)
    m.tube("white", [(0.5, 0, 1.2), (1.0, -0.2, 0.9), (1.3, -0.1, 0.7)], 0.06)
    m.squircle("red", (0.35, 0.55, 0.22), (-0.15, -0.15, 0.11), power=2.6)
    m.squircle("red", (0.35, 0.55, 0.22), (1.35, -0.2, 0.65), rot=(0, -30, 0), power=2.6)
    m.lathe("glass", [(0, 0), (0.3, 0), (0.32, 0.6), (0, 0.6)], (-1.3, 0.3, 0.0))  # jelly jar
    m.lathe("grape", [(0, 0), (0.28, 0), (0.29, 0.45), (0, 0.45)], (-1.3, 0.3, 0.02))
    return m


def rainbow_pastry_cat():
    m = Meme("RainbowPastryCat")
    # a cat whose body is a frosted cookie sandwich, zooming along on a rainbow trail
    for k, c in enumerate(("rainbow1", "rainbow2", "rainbow3", "rainbow4", "rainbow5", "rainbow6")):
        z = 3.0 - k * 0.22
        pts = [(-2.2 + i * 0.3, 0.1, z + math.sin(i * 1.2) * 0.12) for i in range(7)]
        m.tube(c, pts, 0.12, seg=6)
    m.squircle("cookie", (1.8, 0.7, 1.3), (0.6, 0, 2.5), power=4)  # pastry body
    m.squircle("icing", (1.6, 0.72, 1.1), (0.6, -0.02, 2.5), power=4)
    for k in range(10):
        m.box(("rainbow1", "rainbow3", "rainbow5")[k % 3], (0.12, 0.05, 0.05), (0.1 + (k % 5) * 0.25, -0.38, 2.15 + (k // 5) * 0.5),
              rot=(0, k * 37, 0), bevel=0)
    m.squircle("gray", (0.95, 0.8, 0.8), (1.6, -0.05, 2.45), power=2.4)  # cat head
    for s in (-1, 1):
        mp.ear(m, "gray", (1.6 + s * 0.3, 0, 2.75), (1.6 + s * 0.38, 0, 3.15), width=0.2, inner="pink", thick=0.07)
        m.blob("black", (0.12, 0.06, 0.14), (1.6 + s * 0.2, -0.43, 2.55))
        m.blob("pink", (0.16, 0.05, 0.1), (1.6 + s * 0.32, -0.42, 2.3))
    m.tube("black", [(1.45, -0.43, 2.25), (1.6, -0.44, 2.2), (1.75, -0.43, 2.25)], 0.02)
    for x in (0.1, 1.1):  # little gray legs
        for dy in (-0.25, 0.25):
            m.blob("gray", (0.22, 0.22, 0.25), (x, dy, 1.75))
    m.tube("gray", [(-0.3, 0, 2.5), (-0.6, 0, 2.6), (-0.75, 0, 2.45)], 0.08)
    m.cyl("darkgray", 0.05, 2.4, (0.6, 0.2, 1.2), seg=8)  # display rod
    m.cyl("ink", 0.7, 0.1, (0.6, 0.2, 0.05), seg=24)
    for k in range(5):  # stars
        m.relief("white", [(0, 0.12), (0.03, 0.03), (0.12, 0), (0.03, -0.03), (0, -0.12), (-0.03, -0.03), (-0.12, 0), (-0.03, 0.03)],
                 0.03, (-1.8 + k * 0.9, -0.2, 3.7 - (k % 2) * 0.4))
    return m


def wow_shiba(name="WowShiba", words=None):
    m = Meme(name)
    # the classic shiba: sitting sideways, side-eyeing you, surrounded by colorful floating words
    m.squircle("shiba", (1.6, 2.0, 1.4), (0, 0.3, 0.75), power=2.2)
    m.blob("shibacream", (1.0, 0.5, 1.0), (0, -0.55, 0.85))
    for s in (-1, 1):
        m.squircle("shibacream", (0.32, 0.55, 0.22), (s * 0.3, -0.6, 0.11), power=2.5)
    m.tube("shiba", [(0.4, 1.25, 0.7), (0.7, 1.4, 1.2), (0.4, 1.2, 1.5)], lambda t: 0.18 - 0.05 * t)
    m.squircle("shiba", (1.3, 1.15, 1.05), (0, -0.2, 1.95), power=2.3)
    m.blob("shibacream", (0.85, 0.7, 0.5), (-0.05, -0.68, 1.75))
    m.blob("black", (0.22, 0.15, 0.15), (-0.08, -1.05, 1.85))
    for s in (-1, 1):
        mp.ear(m, "shiba", (s * 0.38, -0.1, 2.35), (s * 0.5, -0.1, 2.85), width=0.25, inner="shibacream", thick=0.09)
        m.blob("shibacream", (0.2, 0.08, 0.1), (s * 0.27, -0.66, 2.25))
        m.eye((s * 0.27, -0.66, 2.08), (0.2, 0.1, 0.18), iris="black", look=(-0.8, 0), lid="shiba", lid_drop=0.35)  # side-eye
    m.tube("mouth", [(-0.25, -0.98, 1.6), (-0.05, -1.0, 1.55), (0.15, -0.98, 1.6)], 0.025)
    words = words or ("wow", "such meme", "very dig", "much old")
    for word, (c, x, z, r) in zip(words, (("comicpink", -1.2, 3.4, 10), ("comiccyan", 1.0, 3.1, -8), ("comicgreen", -1.1, 1.3, -6),
                                          ("rainbow6", 1.3, 1.8, 8))):
        m.text(c, word, (x, -0.6, z), size=0.3, depth=0.04, rot=(0, r, 0))
    return m


def problem_grin_coin():
    m = Meme("ProblemGrinCoin")
    # a silver coin stamped with a smug, ear-to-ear grin
    m.squircle("darkgray", (1.8, 1.0, 0.25), (0, 0.1, 0.12), power=4)
    for s in (-1, 1):
        m.box("darkgray", (0.2, 0.3, 0.9), (s * 0.85, 0.1, 0.65), bevel=0.04)
    m.cyl("medal", 1.7, 0.3, (0, 0, 2.1), rot=(90, 0, 0), seg=64)
    m.torus("gray", 1.55, 0.07, (0, -0.15, 2.1), rot=(90, 0, 0))
    y = -0.18
    m.squircle("white", (2.0, 0.08, 1.9), (0, y, 2.05), power=2.0)  # the face
    m.relief("black", [(-0.85, 0.15), (-0.5, -0.25), (0, -0.4), (0.5, -0.25), (0.85, 0.15), (0.5, -0.05), (0, -0.15), (-0.5, -0.05)],
             0.06, (0, y - 0.03, 1.75), bevel=0)  # the wide grin
    for k in range(7):
        m.box("white", (0.03, 0.07, 0.25), (-0.6 + k * 0.2, y - 0.07, 1.65), bevel=0)  # teeth lines
    for s in (-1, 1):
        m.relief("black", [(-0.25, 0), (0.25, 0.08), (0.2, -0.05)], 0.06, (s * 0.4, y - 0.03, 2.5), rot=(0, 0, 0), bevel=0)  # smug eyes
        m.tube("black", [(s * 0.15, y - 0.04, 2.75), (s * 0.4, y - 0.04, 2.85), (s * 0.65, y - 0.04, 2.78)], 0.035)
    m.text("gray", "PROBLEM?", (0, y, 0.75), size=0.22, depth=0.03)
    return m


def me_likey_tablet():
    m = Meme("MeLikeyTablet")
    # a stone tablet carved with a goofy face, tongue out, eyes squeezed happily
    y = tablet(m)
    m.blob("white", (1.9, 0.12, 1.9), (0, y, 2.2))
    for s in (-1, 1):
        m.tube("black", [(s * 0.6, y - 0.08, 2.55), (s * 0.4, y - 0.1, 2.75), (s * 0.2, y - 0.08, 2.55)], 0.05)
    m.tube("black", [(-0.6, y - 0.08, 1.8), (0, y - 0.1, 1.6), (0.6, y - 0.08, 1.8)], 0.05)
    m.blob("tongue", (0.4, 0.1, 0.45), (0.2, y - 0.08, 1.5))
    m.blob("blush", (0.35, 0.06, 0.2), (-0.65, y - 0.08, 2.15))
    m.blob("blush", (0.35, 0.06, 0.2), (0.65, y - 0.08, 2.15))
    m.text("stonedark", "ME LIKEY", (0, y, 0.85), size=0.32, depth=0.05)
    return m


def rage_scream_tablet():
    m = Meme("RageScreamTablet")
    # a cracked stone tablet carved with a red, screaming rage face
    y = tablet(m)
    m.blob("red", (1.9, 0.12, 2.0), (0, y, 2.25))
    for s in (-1, 1):
        m.blob("white", (0.45, 0.06, 0.32), (s * 0.4, y - 0.08, 2.75))
        m.blob("black", (0.12, 0.06, 0.12), (s * 0.35, y - 0.12, 2.73))
        m.box("black", (0.55, 0.07, 0.1), (s * 0.4, y - 0.1, 3.0), rot=(0, s * 25, 0), bevel=0.02)
    m.blob("mouth", (1.0, 0.1, 0.8), (0, y - 0.07, 1.75))
    m.box("teeth", (0.85, 0.06, 0.15), (0, y - 0.12, 2.05), bevel=0.02)
    m.box("teeth", (0.75, 0.06, 0.13), (0, y - 0.12, 1.45), bevel=0.02)
    for k in range(6):  # cracks
        a = k / 6 * math.tau
        m.tube("stonedark", [(0, y - 0.05, 2.25), (math.cos(a) * 0.7, y - 0.06, 2.25 + math.sin(a) * 0.9),
                             (math.cos(a + 0.3) * 1.15, y - 0.05, 2.25 + math.sin(a + 0.3) * 1.4)], 0.025, seg=5)
    m.text("darkred", "AAAAA", (0, y, 0.8), size=0.36, depth=0.05)
    return m


def forever_alone():
    m = Meme("ForeverAlone")
    # a lonely monument: a big pale face crying into its hands, one bench, one rose
    y = tablet(m, width=2.8, height=3.8)
    m.blob("white", (1.6, 0.12, 2.2), (0, y, 2.4))
    for s in (-1, 1):
        m.blob("black", (0.18, 0.06, 0.12), (s * 0.35, y - 0.08, 2.85))
        m.tube("black", [(s * 0.15, y - 0.09, 2.98), (s * 0.5, y - 0.09, 3.06)], 0.03)
        m.blob("sky", (0.12, 0.06, 0.55), (s * 0.4, y - 0.08, 2.35))  # streams of tears
        m.squircle("white", (0.45, 0.14, 0.6), (s * 0.55, y - 0.1, 1.75), rot=(0, s * -20, 0), power=2.4)  # hands
    m.tube("black", [(-0.4, y - 0.1, 2.05), (0, y - 0.11, 2.15), (0.4, y - 0.1, 2.05)], 0.04)
    m.text("stonedark", "FOREVER ALONE", (0, y, 0.85), size=0.22, depth=0.04)
    m.cyl("darkgreen", 0.025, 0.7, (1.0, -0.8, 0.5), rot=(0, 20, 0), seg=6)  # a single rose
    m.blob("red", (0.18, 0.18, 0.18), (1.12, -0.8, 0.85))
    return m


def bad_luck_bryan():
    m = Meme("BadLuckBryan")
    # a framed school-photo portrait: ginger teen in a red plaid vest, braces grin, laser background
    m.squircle("gold", (2.8, 0.25, 3.4), (0, 0, 2.6), power=8)
    m.squircle("yearbook", (2.4, 0.26, 3.0), (0, -0.02, 2.6), power=10)
    for k in range(4):  # laser-blue streaks
        m.box("sky", (2.4, 0.27, 0.04), (0, -0.02, 1.6 + k * 0.6), rot=(0, 25, 0), bevel=0)
    y = -0.2
    m.squircle("plaid", (1.7, 0.2, 1.0), (0, y, 1.6), power=3)  # vest
    for k in range(4):
        m.box("navy", (1.7, 0.21, 0.04), (0, y, 1.3 + k * 0.2), bevel=0)
        m.box("navy", (0.04, 0.21, 1.0), (-0.6 + k * 0.4, y, 1.6), bevel=0)
    m.squircle("skin", (1.0, 0.25, 1.25), (0, y, 2.75), power=2.4)
    m.squircle("ginger", (1.05, 0.27, 0.45), (0, y, 3.32), power=2.4)
    for s in (-1, 1):
        m.blob("black", (0.1, 0.05, 0.1), (s * 0.2, y - 0.14, 2.85))
        for k in range(4):
            m.blob("ginger", (0.04, 0.03, 0.04), (s * (0.2 + k * 0.05), y - 0.13, 2.65 - (k % 2) * 0.05))  # freckles
    m.blob("teeth", (0.4, 0.06, 0.15), (0, y - 0.13, 2.45))
    m.box("steel", (0.38, 0.07, 0.03), (0, y - 0.16, 2.46), bevel=0)  # braces
    for sx in (-1, 1):
        m.cyl("wood", 0.07, 4.2, (sx * 1.0, 0.35, 2.0), rot=(-8, sx * 12, 0), seg=8)
    m.cyl("wood", 0.07, 4.0, (0, 0.9, 1.9), rot=(25, 0, 0), seg=8)
    return m


def frowning_cat():
    m = Meme("FrowningCat")
    # a gray tabby bust on a pedestal with the deepest frown ever recorded
    m.lathe("pedestal", [(0, 0), (0.9, 0), (0.9, 0.3), (0.65, 0.4), (0.6, 1.2), (0.85, 1.3), (0.85, 1.45), (0, 1.45)], (0, 0, 0))
    m.squircle("tabby", (1.9, 1.3, 1.1), (0, 0, 1.95), power=2.4)  # shoulders
    m.squircle("tabby", (1.8, 1.5, 1.5), (0, -0.05, 3.0), power=2.3)
    m.blob("white", (0.9, 0.5, 0.6), (0, -0.65, 2.7))  # muzzle
    for k in range(4):
        m.box("tabbydark", (0.08, 0.05, 0.35), (-0.3 + k * 0.2, -0.72, 3.5), bevel=0.02)
    for s in (-1, 1):
        mp.ear(m, "tabby", (s * 0.55, 0.0, 3.5), (s * 0.7, 0.05, 4.1), width=0.32, inner="pink", thick=0.1)
        m.eye((s * 0.38, -0.7, 3.15), (0.36, 0.16, 0.3), iris="sky", pupil="black", lid="tabby", lid_drop=0.45)
        m.box("tabbydark", (0.38, 0.06, 0.08), (s * 0.38, -0.78, 3.38), rot=(0, s * -18, 0), bevel=0.02)  # angry brows
        for k in range(3):
            m.box("gray", (0.5, 0.02, 0.02), (s * 0.75, -0.65, 2.75 + k * 0.07), rot=(0, s * (k - 1) * 12, 0), bevel=0)
    m.blob("pink", (0.14, 0.08, 0.1), (0, -0.92, 2.88))
    m.tube("black", [(-0.3, -0.88, 2.48), (-0.15, -0.92, 2.58), (0, -0.92, 2.62), (0.15, -0.92, 2.58), (0.3, -0.88, 2.48)], 0.035)  # the frown
    return m


def phantom_chonky_bunny():
    m = Meme("PhantomChonkyBunny")
    # the giant bunny back as a pale floating ghost, still enormous, a wispy tail instead of feet
    m.squircle("ghostblue", (3.0, 2.5, 2.4), (0, 0, 2.2), power=2.1)
    m.lathe("ghostblue", [(0, 0.3), (0.3, 0.35), (0.9, 0.7), (1.2, 1.1), (0, 1.2)], (0, 0, 0), seg=24)  # wispy tail
    m.blob("white", (2.0, 0.8, 1.8), (0, -0.85, 2.1))
    m.squircle("ghostblue", (1.9, 1.7, 1.5), (0, -0.2, 3.8), power=2.3)
    for s in (-1, 1):
        m.blob("ghostblue", (0.5, 0.3, 1.5), (s * 0.5, 0.0, 5.0), rot=(0, s * 18, 0))
        m.blob("white", (0.3, 0.12, 1.1), (s * 0.5, -0.12, 5.0), rot=(0, s * 18, 0))
        m.blob("black", (0.32, 0.15, 0.42), (s * 0.42, -0.95, 3.95))  # hollow eyes
        m.tube("ghostblue", [(s * 1.3, -0.4, 2.8), (s * 0.8, -1.3, 2.3), (-s * 0.1, -1.35, 2.35)], 0.25)
        m.tube("chain", [(s * 0.9, -0.5, 1.3), (s * 1.4, -0.7, 0.9), (s * 1.6, -0.9, 0.4)], 0.05, seg=6)
    m.blob("black", (0.5, 0.15, 0.5), (0, -1.0, 3.45))  # moaning mouth
    m.cyl("darkgray", 0.9, 0.1, (0, 0, 0.05), seg=32)
    m.cyl("darkgray", 0.08, 0.6, (0, 0, 0.35), seg=8)
    return m


def cemetery_specter():
    m = Meme("CemeterySpecter")
    # a bedsheet ghost drifting over a little graveyard, holding up a glowing lantern
    m.squircle("grass2", (3.6, 2.4, 0.15), (0, 0, 0.07), power=3)
    for k, (x, y, r) in enumerate([(-1.2, 0.6, -8), (0.0, 0.8, 5), (1.2, 0.6, 10)]):
        m.relief("grave", [(-0.35, 0), (0.35, 0), (0.35, 0.8), (0, 1.0), (-0.35, 0.8)], 0.2, (x, y, 0.14), rot=(0, r, 0), bevel=0.05)
        m.text("stonedark", "RIP", (x, y - 0.12, 0.65), size=0.14, depth=0.02, rot=(0, r, 0))
    sheet_ghost(m, (0, -0.2, 1.4), h=2.6, w=1.7)
    m.blob("black", (0.3, 0.1, 0.35), (0, -1.02, 2.95))  # "oooo" mouth
    m.tube("sheet", [(0.75, -0.3, 2.6), (1.25, -0.5, 2.9), (1.3, -0.6, 3.3)], 0.12)
    m.tube("darkgray", [(1.3, -0.6, 3.35), (1.3, -0.6, 3.05)], 0.02)
    m.lathe("darkgray", [(0, 0), (0.25, 0), (0.25, 0.05), (0.2, 0.5), (0.25, 0.55), (0, 0.65)], (1.3, -0.6, 2.4))
    m.blob("lanternglow", (0.3, 0.3, 0.38), (1.3, -0.6, 2.67))
    m.cyl("darkgray", 0.04, 1.4, (0, -0.2, 0.75), seg=8)  # hover rod
    return m


def undead_sanic():
    m = Meme("UndeadSanic")
    # a badly drawn blue speed hedgehog, now a mummy: bandages, one dangling eye, still running
    for s, (knee, foot) in ((-1, ((-0.3, -0.5, 0.8), (-0.4, -0.7, 0.15))), (1, ((0.3, 0.4, 0.9), (0.35, 0.7, 0.45)))):
        m.tube("sanic", [(s * 0.25, 0, 1.4), knee, foot], 0.13)
        m.squircle("red", (0.42, 0.85, 0.35), (foot[0], foot[1] - 0.15, foot[2]), power=2.4)
    m.squircle("sanic", (1.3, 1.0, 1.4), (0, 0, 2.0), power=2.2)
    m.blob("hedgebelly", (0.8, 0.4, 0.9), (0, -0.45, 1.9))
    for k in range(5):  # bandage wraps
        m.torus("bandage2", 0.6 - abs(k - 2) * 0.05, 0.06, (0, 0, 1.5 + k * 0.22), rot=(8 * (k % 2 * 2 - 1), 0, 0), scale=(1, 0.8, 1))
    m.squircle("sanic", (1.7, 1.5, 1.5), (0, 0.05, 3.3), power=2.4)
    for k in range(5):
        a = math.radians(-50 + k * 25)
        m.cyl("sanic", 0.32, 1.6, (math.sin(a) * 0.4, 0.9, 3.4 + math.cos(a) * 0.3), rot=(-80, 0, math.degrees(a) * -0.3), radius2=0.0, seg=10)
    m.blob("white", (0.95, 0.3, 0.75), (-0.05, -0.6, 3.45))  # one big lopsided eye-patch
    m.blob("rot", (0.35, 0.12, 0.35), (-0.25, -0.78, 3.45))
    m.blob("black", (0.14, 0.08, 0.14), (-0.25, -0.85, 3.45))
    m.tube("rot", [(0.3, -0.65, 3.45), (0.45, -0.85, 3.1)], 0.02)  # dangling eye
    m.blob("white", (0.3, 0.25, 0.3), (0.45, -0.9, 3.0))
    m.blob("hedgebelly", (0.9, 0.45, 0.45), (0, -0.62, 2.95))
    m.tube("mouth", [(-0.3, -0.85, 2.9), (0.1, -0.88, 2.82), (0.35, -0.83, 2.95)], 0.04)
    m.torus("bandage2", 0.72, 0.07, (0, 0.0, 3.6), rot=(15, 0, 10), scale=(1, 0.9, 0.6))
    for s in (-1, 1):
        m.tube("sanic", [(s * 0.6, 0, 2.4), (s * 1.1, -0.5, 2.6), (s * 1.3, -1.0, 2.7)], 0.11)  # zombie arms out
        m.blob("bandage2", (0.3, 0.3, 0.3), (s * 1.3, -1.05, 2.7))
    m.text("sanic", "gota go fst", (0, -0.9, 4.6), size=0.3, depth=0.04)
    return m


def graveyard_ossuary():
    m = Meme("GraveyardOssuary")
    # a stone crypt with a pyramid of skulls on its roof and crossed bones on the door
    m.squircle("grave", (3.2, 2.2, 0.25), (0, 0, 0.12), power=4)
    m.squircle("stone", (2.6, 1.8, 1.8), (0, 0, 1.15), power=6)
    m.relief("stonedark", [(-1.5, 0), (1.5, 0), (0, 0.8)], 1.9, (0, 0, 2.05), bevel=0.04)  # roof
    m.squircle("stonedark", (0.9, 0.1, 1.3), (0, -0.92, 0.9), power=4)  # door
    for a in (40, -40):
        m.tube("bone", [(-0.3 * math.cos(math.radians(a)), -1.0, 0.95 - 0.3 * math.sin(math.radians(a))),
                        (0.3 * math.cos(math.radians(a)), -1.0, 0.95 + 0.3 * math.sin(math.radians(a)))], 0.05)
    skull(m, (0, -1.02, 1.35), 0.35)
    rows = [(-0.6, 3.0), (0.0, 3.0), (0.6, 3.0), (-0.3, 3.5), (0.3, 3.5), (0.0, 4.0)]
    for x, z in rows:
        skull(m, (x, -0.1, z - 0.15), 0.55)
    m.text("stonedark", "BRAINROT", (0, -0.92, 2.25), size=0.24, depth=0.04)
    for s in (-1, 1):
        m.cyl("darkgray", 0.04, 1.0, (s * 1.45, -0.9, 0.7), seg=8)
        m.blob("lanternglow", (0.2, 0.2, 0.25), (s * 1.45, -0.9, 1.25))
    return m


ALL = [spooky_skeleton, pumpkin_dancer, ghostly_swamp_frog, bonk_shiba, sad_violin_hamster, confused_math_cat,
       jelly_time_banana, rainbow_pastry_cat, wow_shiba, problem_grin_coin, me_likey_tablet, rage_scream_tablet,
       forever_alone, bad_luck_bryan, frowning_cat, phantom_chonky_bunny, cemetery_specter, undead_sanic, graveyard_ossuary]
