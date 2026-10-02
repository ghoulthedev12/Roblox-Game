"""Batch 10 of the meme sculptures: World 6 (the ocean world).
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp

for _name, _c in [
    ("stone", (165, 160, 150)), ("stonedark", (110, 105, 98)), ("rgb1", (255, 40, 120)), ("rgb2", (40, 220, 255)),
    ("chairblack", (30, 30, 36)), ("chipbag", (240, 80, 60)), ("seasand", (230, 210, 160)), ("coralpink", (255, 120, 140)),
    ("velvet", (150, 30, 70)), ("egg", (250, 245, 235)), ("hawaii", (60, 170, 220)), ("glassdome", (210, 235, 250)),
    ("pedestal", (245, 245, 245)), ("fish", (255, 150, 60)), ("beret", (30, 30, 40)), ("baguette", (220, 165, 90)),
    ("briefcase", (90, 55, 35)), ("paperclip", (190, 195, 205)), ("paper", (250, 250, 245)), ("plane", (60, 200, 200)),
    ("planered", (230, 60, 60)), ("brass", (200, 150, 60)), ("brassdark", (140, 95, 35)), ("porthole", (60, 90, 110)),
    ("angler", (55, 50, 75)), ("lure", (255, 240, 120)), ("brain", (255, 160, 190)), ("whale", (70, 110, 170)),
    ("whalebelly", (200, 215, 230)), ("glitch1", (255, 0, 200)), ("glitch2", (0, 255, 220)), ("seastone", (110, 160, 150)),
    ("barnacle", (220, 215, 200)), ("seaweed", (40, 130, 70)),
]:
    rgb(_name, *_c)


def heart_pts(w, h, n=24):
    return [(w * math.sin(t) ** 3, h * (0.8 * math.cos(t) - 0.32 * math.cos(2 * t) - 0.14 * math.cos(3 * t) - 0.06 * math.cos(4 * t)))
            for t in [i / n * math.tau for i in range(n)]]


def shush_up_tablet():
    m = Meme("ShushUpTablet")
    # a weathered stone tablet carved with a face pressing one finger to its lips
    m.squircle("stonedark", (3.0, 1.4, 0.4), (0, 0, 0.2), power=4)
    m.relief("stone", [(-1.2, 0), (1.2, 0), (1.2, 3.2), (0.9, 3.75), (0, 3.95), (-0.9, 3.75), (-1.2, 3.2)], 0.45, (0, 0, 0.4), bevel=0.08)
    y = -0.25
    m.blob("stonedark", (1.3, 0.12, 1.5), (0, y, 2.4))  # carved face
    m.blob("stone", (1.2, 0.12, 1.4), (0, y - 0.03, 2.42))
    for s in (-1, 1):
        m.tube("stonedark", [(s * 0.45, y - 0.1, 2.75), (s * 0.25, y - 0.12, 2.72), (s * 0.05, y - 0.1, 2.75)], 0.04)  # closed eyes
    m.tube("stonedark", [(-0.22, y - 0.1, 2.05), (0.22, y - 0.1, 2.05)], 0.05)  # pressed lips
    m.squircle("stonedark", (0.18, 0.15, 0.85), (0.0, y - 0.15, 2.15), power=2.5)  # the finger
    m.squircle("stonedark", (0.4, 0.18, 0.4), (0.05, y - 0.13, 1.6), power=2.5)  # hand
    m.text("stonedark", "SHHH", (0, y - 0.05, 1.0), size=0.42, depth=0.06)
    for k in range(5):  # chips and cracks
        m.blob("stonedark", (0.2, 0.1, 0.15), (-1.0 + k * 0.5, y + 0.02, 3.4 - (k % 2) * 0.3))
    return m


def big_gamer_chair():
    m = Meme("BigGamerChair")
    # an oversized RGB gaming chair sunk in the sand with empty snack bags drifting round it
    m.squircle("seasand", (3.6, 2.6, 0.25), (0, 0, 0.12), power=3)
    m.cyl("chairblack", 0.15, 0.9, (0, 0, 0.6), seg=12)
    for k in range(5):
        a = k / 5 * math.tau
        m.tube("chairblack", [(0, 0, 0.3), (math.cos(a) * 0.9, math.sin(a) * 0.9, 0.25)], 0.07)
        m.blob("darkgray", (0.2, 0.2, 0.2), (math.cos(a) * 0.9, math.sin(a) * 0.9, 0.18))
    m.squircle("chairblack", (1.8, 1.6, 0.4), (0, -0.1, 1.15), power=3)  # seat
    m.squircle("chairblack", (1.8, 0.45, 2.9), (0, 0.6, 2.6), rot=(-10, 0, 0), power=3)  # tall back
    for s in (-1, 1):
        m.squircle("rgb1" if s < 0 else "rgb2", (0.22, 0.47, 2.7), (s * 0.7, 0.58, 2.6), rot=(-10, 0, 0), power=4)  # RGB stripes
        m.squircle("chairblack", (0.25, 1.2, 0.18), (s * 0.95, -0.1, 1.75), power=3)  # armrests
        m.cyl("chairblack", 0.06, 0.5, (s * 0.95, 0.1, 1.45), seg=8)
        m.squircle("rgb2" if s < 0 else "rgb1", (0.5, 0.25, 0.4), (s * 0.55, 0.42, 3.95), rot=(-10, 0, 0), power=3)  # wings
    m.squircle("red", (0.8, 0.2, 0.4), (0, 0.4, 3.6), rot=(-10, 0, 0), power=3)  # neck pillow
    for k, (x, y, r) in enumerate([(-1.3, -0.8, 30), (1.2, -0.9, -20), (-1.4, 0.7, 70)]):  # empty snack bags
        m.squircle("chipbag", (0.5, 0.12, 0.7), (x, y, 0.45), rot=(60, 0, r), power=3)
    for k in range(3):  # bubbles
        m.blob("bubble", (0.15 + k * 0.05,) * 3, (1.0, -0.3, 3.3 + k * 0.5))
    m.cyl("coralpink", 0.08, 0.7, (1.5, 0.8, 0.5), rot=(0, 15, 0), seg=8)
    m.cyl("coralpink", 0.06, 0.5, (1.6, 0.8, 0.7), rot=(0, -30, 0), seg=8)
    return m


def take_egg_cushion():
    m = Meme("TakeEggCushion")
    # one perfect egg on a velvet cushion on a little stand, with a polite brass plaque
    m.lathe("gold", [(0, 0), (0.7, 0), (0.7, 0.1), (0.25, 0.2), (0.2, 1.4), (0.5, 1.5), (0, 1.5)], (0, 0, 0), seg=32)
    m.squircle("velvet", (2.2, 2.2, 0.55), (0, 0, 1.75), power=3.2)
    for sx in (-1, 1):
        for sy in (-1, 1):
            m.tube("gold", [(sx * 1.0, sy * 1.0, 1.8), (sx * 1.15, sy * 1.15, 1.5)], 0.04)
            m.blob("gold", (0.18, 0.18, 0.28), (sx * 1.18, sy * 1.18, 1.4))
    m.lathe("egg", [(0, 0), (0.35, 0.08), (0.48, 0.35), (0.45, 0.7), (0.3, 0.98), (0, 1.08)], (0, 0, 1.95), seg=32)
    m.squircle("brass", (1.2, 0.1, 0.3), (0, -0.75, 1.2), rot=(-15, 0, 0), power=6)
    m.text("darkbrown", "TAKE EGG", (0, -0.82, 1.2), size=0.17, depth=0.02, rot=(-15, 0, 0))
    for k in range(4):  # sparkles
        m.relief("yellow", [(0, 0.15), (0.04, 0.04), (0.15, 0), (0.04, -0.04), (0, -0.15), (-0.04, -0.04), (-0.15, 0), (-0.04, 0.04)],
                 0.03, (math.cos(k * 1.6) * 0.8, -0.2, 2.9 + math.sin(k * 1.6) * 0.4))
    return m


def ibiza_boss_dancer():
    m = Meme("IbizaBossDancer")
    # an older raver in a loud beach shirt and shades, lost in the beat, arms flung up
    p = mp.person(m, skin="skin", shirt="hawaii", pants="khaki", shoes="sneaker", hair="hairgray", hair_style="short",
                  sleeves_short=True, belly=1.05, expr="open",
                  legs={-1: ((-0.35, -0.25, 0.9), (-0.45, -0.2, 0.16)), 1: ((0.4, -0.4, 1.0), (0.45, -0.1, 0.4))},
                  arms={"l": ((-1.0, -0.3, 3.3), (-0.8, -0.4, 4.15)), "r": ((1.05, -0.2, 3.0), (1.6, -0.3, 3.6))})
    hc, hs = p["head"], p["head_size"]
    for k in range(10):  # flowers on the shirt
        m.blob(("yellow", "pink", "white")[k % 3], (0.14, 0.05, 0.14), (-0.4 + (k % 4) * 0.27, -0.33 + (k % 2) * -0.02, 1.95 + (k // 4) * 0.4))
    m.squircle("black", (0.95, 0.12, 0.22), (hc.x, hc.y - hs * 0.42, hc.z + 0.06), power=4)  # shades
    m.squircle("darkgray", (2.6, 2.0, 0.12), (0, 0, 0.06), power=4)  # dance floor
    for k in range(4):
        m.squircle(("rgb1", "rgb2", "lime", "yellow")[k], (0.6, 0.6, 0.02), (-0.9 + (k % 2) * 1.8, -0.5 + (k // 2) * 1.0, 0.13), power=6)
    return m


def boutique_rock():
    m = Meme("BoutiqueRock")
    # an ordinary rock on a white pedestal under a glass dome, $200 tag, SOLD OUT
    m.squircle("pedestal", (1.6, 1.6, 2.0), (0, 0, 1.0), power=6)
    m.squircle("pedestal", (1.8, 1.8, 0.15), (0, 0, 2.05), power=6)
    m.squircle("rock", (1.1, 0.9, 0.75), (0, 0, 2.45), power=2.0)
    m.blob("rockgray", (0.45, 0.4, 0.3), (0.25, -0.2, 2.6))
    for k in range(4):  # a wire-frame display dome, so the rock shows
        m.torus("gold", 0.8, 0.025, (0, 0, 2.95), rot=(90, 0, k * 45), scale=(1, 1, 1.05))
    m.torus("gold", 0.8, 0.03, (0, 0, 2.2))
    m.cyl("gold", 0.82, 0.08, (0, 0, 2.15), seg=40)
    m.relief("white", [(0, 0), (0.6, 0), (0.75, 0.15), (0.6, 0.3), (0, 0.3)], 0.03, (0.45, -0.85, 1.6), rot=(0, 0, 0))
    m.text("darkgreen", "$200", (0.75, -0.88, 1.75), size=0.16, depth=0.02)
    m.squircle("red", (1.4, 0.06, 0.3), (0, -0.82, 0.9), rot=(0, -12, 0), power=6)
    m.text("white", "SOLD OUT", (0, -0.86, 0.9), size=0.18, depth=0.02, rot=(0, -12, 0))
    return m


def little_french_fish():
    m = Meme("LittleFrenchFish")
    # a little orange fish in a beret with a curly mustache, carrying a baguette bigger than itself
    m.squircle("seasand", (3.0, 2.0, 0.2), (0, 0, 0.1), power=3)
    m.cyl("seaweed", 0.06, 1.6, (-1.2, 0.6, 0.9), rot=(0, 10, 0), seg=8)
    m.cyl("seaweed", 0.06, 1.2, (-1.35, 0.5, 0.7), rot=(0, -12, 0), seg=8)
    m.blob("fish", (2.0, 1.1, 1.5), (0, 0, 2.3))  # body
    m.relief("fish", [(0, 0), (0.7, 0.6), (0.55, 0), (0.7, -0.6)], 0.15, (0.9, 0, 2.3), bevel=0.04)  # tail
    m.relief("orange", [(0, 0), (0.25, 0.5), (0.5, 0.0)], 0.1, (-0.3, 0, 2.95), bevel=0.03)  # dorsal fin
    for s in (-1, 1):
        m.blob("orange", (0.4, 0.12, 0.25), (0.1, s * 0.5, 2.05), rot=(0, 30, s * 20))  # side fins
    m.eye((-0.55, -0.35, 2.55), (0.35, 0.2, 0.38), iris="black", look=(-0.3, 0))
    m.eye((-0.55, 0.35, 2.55), (0.35, 0.2, 0.38), iris="black")
    m.tube("black", [(-0.95, -0.25, 2.12), (-1.1, -0.35, 2.05), (-1.25, -0.32, 2.15)], 0.035)  # mustache
    m.tube("black", [(-0.95, 0.25, 2.12), (-1.1, 0.35, 2.05), (-1.25, 0.32, 2.15)], 0.035)
    m.blob("mouth", (0.12, 0.2, 0.1), (-1.0, 0, 1.98))
    m.lathe("beret", [(0, 0), (0.55, 0.02), (0.6, 0.12), (0.3, 0.25), (0, 0.27)], (-0.2, 0, 2.95), rot=(0, -15, 0))
    m.cyl("beret", 0.04, 0.15, (-0.25, 0, 3.27), seg=6)
    m.cyl("baguette", 0.18, 2.6, (0.1, -0.6, 1.55), rot=(0, 70, 0), seg=16)  # the baguette under its fin
    for k in range(4):
        m.box("tan", (0.25, 0.05, 0.04), (-0.8 + k * 0.5, -0.78, 1.55 + (k - 1.5) * 0.17 * 0.35), rot=(0, 45, 0), bevel=0)
    m.text("navy", "OUI", (0.9, -0.3, 3.4), size=0.3, depth=0.04)
    return m


def standing_on_business():
    m = Meme("StandingOnBusiness")
    # a businessman standing proudly ON a giant briefcase, literally
    m.squircle("briefcase", (3.0, 1.1, 1.8), (0, 0, 0.9), power=6)
    m.squircle("brassdark", (3.02, 1.12, 0.1), (0, 0, 1.35), power=6)
    for s in (-1, 1):
        m.box("gold", (0.3, 0.06, 0.2), (s * 0.8, -0.56, 1.35), bevel=0.02)  # clasps
        m.tube("brassdark", [(s * 1.0, 0, 1.8), (s * 0.98, 0, 2.0)], 0.06)  # handle posts at the ends
    m.tube("brassdark", [(-0.98, 0.35, 2.0), (0.98, 0.35, 2.0)], 0.06)
    mp.person(m, skin="skin3", shirt="suit", pants="suit", shoes="black", hair="hairblack", hair_style="fade",
              height=0.62, build=0.64, head=0.64, expr="smirk", z=1.8, sole=None,
              arms={"l": ((-0.45, 0.05, 1.55), (-0.25, -0.25, 1.5)), "r": ((0.45, 0.05, 1.55), (0.3, -0.3, 1.45))})
    m.squircle("tie", (0.1, 0.05, 0.35), (0, -0.24, 1.8 + 1.62), power=4)
    return m


def paperclip_helper():
    m = Meme("PaperclipHelper")
    # a bent-wire paperclip with big googly eyes and eyebrows, leaning on a sheet of paper
    m.squircle("paper", (2.4, 0.08, 3.2), (-0.2, 0.4, 1.6), rot=(-8, 0, 0), power=8)
    for k in range(7):
        m.box("lightgray", (1.8, 0.02, 0.05), (-0.3, 0.33, 0.6 + k * 0.38), rot=(-8, 0, 0), bevel=0)
    # the paperclip: two nested loops of wire
    pts = [(0.35, 0, 0.4), (0.35, 0, 3.6), (0.0, 0, 3.95), (-0.35, 0, 3.6), (-0.35, 0, 0.9), (-0.1, 0, 0.65), (0.15, 0, 0.9),
           (0.15, 0, 3.2)]
    smooth = []
    for a, b in zip(pts, pts[1:]):
        for k in range(6):
            t = k / 6
            smooth.append(tuple(a[j] + (b[j] - a[j]) * t for j in range(3)))
    smooth.append(pts[-1])
    m.tube("paperclip", smooth, 0.07, seg=10)
    for s in (-1, 1):
        m.eye((s * 0.22, -0.3, 2.9), (0.36, 0.25, 0.46), iris="black", look=(-0.3, 0.2))
        m.tube("black", [(s * 0.1, -0.3, 3.25), (s * 0.25, -0.32, 3.35), (s * 0.4, -0.3, 3.28)], 0.035)
    m.squircle("yellow", (1.6, 0.08, 0.7), (-1.0, -0.2, 4.3), power=4)  # speech bubble
    m.text("ink", "Need help?", (-1.0, -0.25, 4.3), size=0.2, depth=0.02)
    return m


def jet_too_holiday():
    m = Meme("JetTooHoliday")
    # a cheerful little plane wearing sunglasses, flying toward a smiling sun over a palm tree
    m.squircle("seasand", (3.6, 2.0, 0.2), (0, 0, 0.1), power=3)
    m.cyl("wood", 0.1, 2.0, (1.3, 0.5, 1.1), rot=(0, 8, 0), seg=10)
    for k in range(5):
        a = k / 5 * math.tau
        m.blob("leaf", (1.0, 0.3, 0.1), (1.45 + math.cos(a) * 0.45, 0.5 + math.sin(a) * 0.45, 2.1), rot=(0, 20, math.degrees(a)))
    m.cyl("darkgray", 0.05, 2.3, (-0.3, 0, 1.3), seg=8)  # display stand
    z = 2.6
    m.squircle("plane", (2.8, 0.9, 0.9), (-0.3, 0, z), power=2.2)  # fuselage
    m.squircle("planered", (2.8, 0.92, 0.25), (-0.3, 0, z - 0.25), power=3)
    m.relief("plane", [(-0.5, 0), (0.5, 0), (0.2, 0.05)], 2.6, (-0.3, 0, z - 0.05), rot=(0, 0, 0), bevel=0.04)  # wings
    m.relief("planered", [(0.9, 0), (1.3, 0), (1.35, 0.9), (1.15, 0.9)], 0.12, (-0.3, 0, z + 0.2), bevel=0.03)  # tail fin
    m.squircle("black", (0.25, 0.75, 0.3), (-1.55, 0, z + 0.15), power=4)  # sunglasses on the nose
    m.tube("mouth", [(-1.7, -0.25, z - 0.2), (-1.72, 0, z - 0.3), (-1.7, 0.25, z - 0.2)], 0.03)
    for k in range(4):
        m.blob("sky", (0.15, 0.05, 0.12), (-0.8 + k * 0.4, -0.45, z + 0.1))  # windows
    m.text("white", "HOLIDAY", (-0.3, -0.47, z - 0.15), size=0.18, depth=0.02)
    m.blob("yellow", (0.8, 0.3, 0.8), (1.0, 0.6, 4.2))  # the sun
    for k in range(8):
        a = k / 8 * math.tau
        m.cyl("yellow", 0.08, 0.3, (1.0 + math.cos(a) * 0.6, 0.6, 4.2 + math.sin(a) * 0.6), rot=(0, -math.degrees(a) + 90, 0), radius2=0.0, seg=6)
    return m


def pressure_diver_helmet():
    m = Meme("PressureDiverHelmet")
    # a brass deep-sea diving helmet, dented by the pressure, bubbles still leaking out
    m.squircle("seasand", (3.0, 2.4, 0.2), (0, 0, 0.1), power=3)
    m.lathe("brassdark", [(0, 0.2), (1.2, 0.2), (1.25, 0.45), (1.0, 0.7), (0, 0.7)], (0, 0, 0))  # collar/breastplate
    m.squircle("brass", (2.1, 2.0, 2.2), (0, 0, 1.8), power=2.1)  # helmet dome
    m.blob("brassdark", (0.7, 0.4, 0.5), (0.7, -0.6, 2.4))  # the dent
    m.cyl("brassdark", 0.62, 0.15, (0, -1.0, 1.85), rot=(90, 0, 0), seg=32)  # front porthole frame
    m.cyl("porthole", 0.5, 0.18, (0, -1.0, 1.85), rot=(90, 0, 0), seg=32)
    for k in range(4):  # grille bars, one bent
        m.box("brassdark", (0.06, 0.06, 1.0), (-0.3 + k * 0.2, -1.12, 1.85), rot=(0, 15 if k == 3 else 0, 0), bevel=0.01)
    for s in (-1, 1):
        m.cyl("brassdark", 0.4, 0.12, (s * 1.0, 0, 1.9), rot=(0, 90, 0), seg=24)
        m.cyl("porthole", 0.3, 0.14, (s * 1.0, 0, 1.9), rot=(0, 90, 0), seg=24)
    m.cyl("brassdark", 0.2, 0.4, (0, 0, 3.0), seg=16)  # air valve
    for k in range(5):
        m.blob("bubble", (0.2 + k * 0.06,) * 3, (0.15 * math.sin(k), -0.1, 3.4 + k * 0.4))
    return m


def abyssal_angler():
    m = Meme("AbyssalAngler")
    # a deep-sea anglerfish on three legs in sneakers, dangling a glowing brain on its lure
    for k, (x, y) in enumerate([(-0.5, -0.2), (0.5, -0.2), (0.0, 0.5)]):
        m.tube("angler", [(x * 0.6, y * 0.6, 1.4), (x, y, 0.7), (x, y, 0.3)], 0.12)
        m.squircle("sneakgreen" if k % 2 else "white", (0.38, 0.6, 0.28), (x, y - 0.1, 0.16), power=2.6)
    m.squircle("angler", (2.2, 1.7, 1.7), (0, 0, 2.2), power=2.0)  # round body
    m.blob("angler", (0.9, 0.4, 0.7), (0.0, 0.85, 2.3), rot=(30, 0, 0))  # tail
    m.blob("mouth", (1.7, 0.4, 0.75), (0, -0.7, 1.9))  # huge mouth
    for k in range(9):  # needle teeth
        x = -0.7 + k * 0.175
        m.cyl("bone", 0.05, 0.3, (x, -0.92, 2.15), rot=(180, 0, 0), radius2=0.0, seg=6)
        m.cyl("bone", 0.04, 0.25, (x + 0.08, -0.9, 1.62), radius2=0.0, seg=6)
    for s in (-1, 1):
        m.eye((s * 0.45, -0.7, 2.75), (0.3, 0.16, 0.3), iris="lure", pupil="black")
        m.relief("angler", [(0, 0), (s * 0.5, 0.25), (s * 0.45, -0.25)], 0.06, (s * 1.0, 0, 2.2))  # side fins
    m.tube("angler", [(0, -0.2, 3.0), (0.1, -0.4, 3.7), (-0.2, -0.9, 4.1), (-0.5, -1.2, 3.8)], lambda t: 0.06 - 0.03 * t)  # lure stalk
    m.blob("brain", (0.55, 0.45, 0.45), (-0.55, -1.25, 3.55))  # glowing brain lure
    for k in range(4):
        m.tube("hotpink", [(-0.78, -1.45 + k * 0.05, 3.55 + (k - 1.5) * 0.08), (-0.55, -1.48, 3.65), (-0.32, -1.45, 3.55 + (k - 1.5) * 0.08)], 0.02, seg=5)
    m.torus("lure", 0.4, 0.02, (-0.55, -1.25, 3.55), rot=(90, 0, 0))
    return m


def glitch_whale():
    m = Meme("GlitchWhale")
    # a smooth blue whale whose back half never loaded: it breaks up into floating voxels
    m.squircle("water", (4.0, 2.0, 0.2), (0, 0, 0.1), power=3)
    m.cyl("darkgray", 0.06, 1.0, (0, 0, 0.6), seg=8)
    m.blob("whale", (2.4, 1.6, 1.7), (-0.6, 0, 2.0))  # loaded front half
    m.blob("whalebelly", (2.0, 1.3, 0.9), (-0.7, -0.15, 1.6))
    for k in range(6):
        m.box("whale", (1.4, 0.04, 0.04), (-0.8, -0.72, 1.4 + k * 0.08), bevel=0)  # throat grooves
    m.eye((-1.35, -0.62, 2.2), (0.22, 0.12, 0.22), iris="black")
    m.tube("mouth", [(-1.8, -0.35, 1.85), (-1.4, -0.6, 1.75), (-0.9, -0.7, 1.8)], 0.03)
    m.cyl("whale", 0.06, 0.35, (-0.5, 0, 2.95), seg=8)  # blowhole spray
    for k in range(5):
        m.blob("bubble", (0.15,) * 3, (-0.5 + math.cos(k * 1.3) * 0.25, 0, 3.25 + k * 0.08))
    # the unloaded half: voxels drifting apart, glitch colors creeping in
    for i in range(40):
        x = 0.3 + (i % 8) * 0.22
        z = 1.3 + (i // 8) * 0.28
        if (x - 0.3) / 1.8 + abs(z - 2.0) * 0.6 > 1.2:
            continue
        spread = (x - 0.3) * 0.35
        c = "whale" if i % 5 else ("glitch1" if i % 2 else "glitch2")
        m.box(c, (0.2, 0.2, 0.2), (x + spread, ((i * 7) % 5 - 2) * 0.1 * (1 + spread), z + ((i * 3) % 4 - 1.5) * 0.05 * spread), bevel=0)
    m.relief("whale", [(0, 0), (0.6, 0.45), (0.5, 0), (0.6, -0.45)], 0.12, (2.3, 0, 2.1), bevel=0)  # a floating tail fluke
    m.text("glitch2", "LOADING...", (0.9, -0.4, 3.3), size=0.2, depth=0.03)
    return m


def atlantis_jawline_chad():
    m = Meme("AtlantisJawlineChad")
    # a sunken stone bust of the ultimate jawline: barnacles, seaweed, a coral crown
    m.lathe("seastone", [(0, 0), (1.0, 0), (1.0, 0.3), (0.75, 0.4), (0.7, 0.9), (0, 0.9)], (0, 0, 0), seg=32)
    m.squircle("seastone", (2.3, 1.2, 1.2), (0, 0, 1.45), power=2.4)  # shoulders
    m.cyl("seastone", 0.38, 0.6, (0, 0, 2.2), seg=16)
    m.squircle("seastone", (1.15, 1.15, 1.45), (0, -0.05, 3.1), power=2.8)  # head
    m.squircle("seastone", (1.3, 0.9, 0.65), (0, -0.25, 2.6), power=4.5)  # the enormous square jaw
    m.blob("seastone", (0.2, 0.3, 0.32), (0, -0.68, 3.05))  # nose
    for s in (-1, 1):
        m.box("stonedark", (0.36, 0.08, 0.1), (s * 0.25, -0.62, 3.35), rot=(0, s * -8, 0), bevel=0.03)  # heavy brows
        m.blob("stonedark", (0.2, 0.06, 0.1), (s * 0.25, -0.62, 3.2))  # deep-set eyes
        m.blob("seastone", (0.25, 0.3, 0.35), (s * 0.6, -0.05, 3.05))  # ears
    m.tube("stonedark", [(-0.2, -0.68, 2.7), (0.2, -0.68, 2.72)], 0.03)  # firm mouth
    m.blob("stonedark", (0.12, 0.06, 0.08), (0, -0.68, 2.45))  # chin dimple
    m.squircle("stonedark", (1.2, 1.2, 0.45), (0, 0.05, 3.75), power=2.4)  # slicked hair
    for k in range(9):  # barnacles
        a = k * 0.8
        m.blob("barnacle", (0.16, 0.16, 0.12), (math.cos(a) * 0.9, -0.35 + math.sin(a) * 0.3, 1.4 + (k % 3) * 0.12))
    for k in range(4):  # seaweed
        x = -1.0 + k * 0.6
        m.tube("seaweed", [(x, 0.6, 0.1), (x + 0.15, 0.6, 1.0), (x - 0.1, 0.6, 1.8), (x + 0.05, 0.6, 2.4 - k * 0.2)], lambda t: 0.08 - 0.05 * t)
    for k in range(5):  # coral crown
        a = math.radians(-60 + k * 30)
        m.cyl("coralpink", 0.07, 0.5, (0.0 + math.sin(a) * 0.45, 0.05, 4.0 + math.cos(a) * 0.1), rot=(0, math.degrees(a), 0), seg=8)
        m.blob("coralpink", (0.15,) * 3, (math.sin(a) * 0.6, 0.05, 4.25))
    return m


ALL = [shush_up_tablet, big_gamer_chair, take_egg_cushion, ibiza_boss_dancer, boutique_rock, little_french_fish,
       standing_on_business, paperclip_helper, jet_too_holiday, pressure_diver_helmet, abyssal_angler, glitch_whale,
       atlantis_jawline_chad]
