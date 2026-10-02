"""Batch 2 of the meme sculptures (remodeled in the full meme remodel, same ids).
Conventions: z is up, the model faces -y, about 4-5 studs tall. Original parody designs.
(sus_bean, jawline_chad, stonks_head and polka_cow are also the bases of later themed variants:
keep the colors they use, the variants recolor them by name.)"""
import math

from memekit import Meme
import memeparts as mp


def sus_bean():
    m = Meme("SusBean")
    # a bean-shaped little astronaut in a round fishbowl helmet, side-eyeing everyone: sus
    for s in (-1, 1):
        m.squircle("red", (0.55, 0.7, 0.75), (s * 0.34, 0.0, 0.42), power=2.4)  # stubby legs
        m.squircle("darkred", (0.6, 0.8, 0.25), (s * 0.34, -0.05, 0.12), power=3)  # boots
        m.tube("red", [(s * 0.72, 0, 2.0), (s * 0.95, -0.25, 1.55), (s * 0.85, -0.45, 1.25)], 0.16)  # little arms
        m.blob("white", (0.32, 0.3, 0.32), (s * 0.85, -0.48, 1.2))  # mittens
    m.lathe("red", [(0, 0.6), (0.65, 0.65), (0.78, 1.1), (0.8, 2.0), (0.7, 2.5), (0, 2.6)], (0, 0, 0), seg=40)  # bean body
    m.squircle("darkred", (1.0, 0.5, 1.1), (0, 0.78, 1.55), power=3)  # backpack
    m.cyl("navy", 0.03, 0.5, (0.3, 0.8, 2.35), seg=6)  # antenna
    m.blob("red", (0.12, 0.12, 0.12), (0.3, 0.8, 2.62))
    m.torus("navy", 0.6, 0.07, (0, -0.05, 2.45))  # helmet collar ring
    m.blob("visor", (1.35, 1.3, 1.2), (0, -0.05, 2.95))  # fishbowl helmet
    m.blob("white", (0.25, 0.1, 0.4), (-0.38, -0.66, 3.18), rot=(0, 20, 0))  # helmet shine
    for s in (-1, 1):  # the shifty eyes peering out through the glass
        m.eye((s * 0.22, -0.66, 2.95), (0.26, 0.12, 0.28), iris="black", look=(0.8, 0), lid="red", lid_drop=0.45)
    m.box("darkred", (0.3, 0.05, 0.06), (0.22, -0.7, 3.18), rot=(0, -15, 0), bevel=0.02)  # one raised brow
    m.tube("darkred", [(-0.14, -0.68, 2.68), (0.14, -0.68, 2.66)], 0.022)
    return m


def jawline_chad():
    m = Meme("JawlineChad")
    # a marble bust of the ultimate jawline, head turned in a dramatic three-quarter profile
    m.lathe("ink", [(0, 0), (0.75, 0), (0.75, 0.3), (0.55, 0.42), (0.5, 0.6), (0, 0.6)], (0, 0, 0), seg=40)  # pedestal
    m.squircle("lightgray", (2.2, 1.15, 1.2), (0, 0, 1.3), power=2.3)  # broad shoulders
    m.squircle("lightgray", (1.0, 0.6, 0.55), (0, -0.25, 1.75), power=2.4)  # chest
    m.cyl("lightgray", 0.38, 0.55, (0, 0, 2.05), seg=20)  # thick neck
    turn = 30
    def T(x, y, z):
        a = math.radians(turn)
        return (x * math.cos(a) - y * math.sin(a), x * math.sin(a) + y * math.cos(a), z)
    m.squircle("lightgray", (1.05, 1.15, 1.35), T(0, -0.05, 2.95), rot=(0, 0, turn), power=2.8)  # head
    m.squircle("lightgray", (1.2, 0.95, 0.6), T(0, -0.25, 2.45), rot=(0, 0, turn), power=5.0)  # the enormous square jaw
    m.blob("lightgray", (0.2, 0.32, 0.36), T(0, -0.68, 2.95))  # nose
    for s in (-1, 1):
        m.box("darkgray", (0.34, 0.08, 0.1), T(s * 0.24, -0.6, 3.25), rot=(0, s * -8, turn), bevel=0.03)  # heavy brows
        m.blob("darkgray", (0.2, 0.06, 0.1), T(s * 0.24, -0.6, 3.1))  # deep-set eyes
        m.blob("lightgray", (0.22, 0.3, 0.34), T(s * 0.56, -0.05, 2.95))  # ears
    m.tube("darkgray", [T(-0.18, -0.67, 2.62), T(0.18, -0.67, 2.64)], 0.03)  # firm mouth
    m.blob("darkgray", (0.12, 0.06, 0.1), T(0, -0.67, 2.32))  # chin cleft
    m.squircle("darkgray", (1.1, 1.15, 0.45), T(0, 0.05, 3.62), rot=(0, 0, turn), power=2.4)  # slicked-back hair
    m.blob("darkgray", (0.7, 0.5, 0.25), T(0, -0.35, 3.75))  # quiff
    return m


def croc_bomber():
    m = Meme("CrocBomber")
    # a crocodile that is also a bomber plane: snout cockpit, wings, propellers, on a display stand
    m.cyl("ink", 0.9, 0.12, (0, 0, 0.06), seg=32)
    m.cyl("darkgray", 0.06, 1.5, (0, 0, 0.8), seg=8)
    z = 2.0
    m.lathe("crocgreen", [(0, -2.0), (0.3, -1.6), (0.55, -0.6), (0.62, 0.3), (0.5, 1.2), (0.2, 2.0), (0, 2.1)], (0, 0, z), rot=(90, 0, 0), seg=28,
            scale=(1, 1, 1))  # fuselage body along y
    m.squircle("crocgreen", (0.8, 1.6, 0.35), (0, -2.1, z - 0.05), power=2.4)  # long snout
    m.squircle("cream", (0.75, 1.5, 0.12), (0, -2.1, z - 0.2), power=2.4)  # pale jaw
    for k in range(8):  # teeth along the jaw
        y = -2.7 + k * 0.17
        for s in (-1, 1):
            m.cyl("teeth", 0.04, 0.14, (s * 0.36, y, z - 0.14), rot=(180, 0, 0), radius2=0.0, seg=6)
    for s in (-1, 1):
        m.eye((s * 0.3, -1.25, z + 0.4), (0.25, 0.25, 0.25), iris="yellow", pupil="black")
        m.squircle("crocgreen", (2.0, 0.8, 0.12), (s * 1.35, -0.2, z - 0.05), rot=(0, s * -6, 0), power=3)  # wings
        m.cyl("darkgray", 0.18, 0.5, (s * 1.3, -0.65, z - 0.2), rot=(90, 0, 0), seg=16)  # engines
        m.squircle("lightgray", (0.85, 0.05, 0.12), (s * 1.3, -0.92, z - 0.2), rot=(0, 30, 0), power=3)  # propellers
        m.squircle("lightgray", (0.12, 0.05, 0.85), (s * 1.3, -0.92, z - 0.2), rot=(0, 30, 0), power=3)
        m.blob("black", (0.25, 0.25, 0.25), (s * 0.5, -0.2, z - 0.55))  # bombs underneath
    for k in range(6):  # bumpy back scutes
        m.cyl("darkgreen", 0.12, 0.25, (0, -1.0 + k * 0.4, z + 0.6), radius2=0.0, seg=8)
    m.relief("crocgreen", [(0, 0), (0.6, 0), (0.2, 0.8)], 0.1, (0, 1.6, z + 0.2), rot=(0, 0, 90), bevel=0.03)  # tail fin
    m.squircle("crocgreen", (1.4, 0.4, 0.1), (0, 1.9, z + 0.15), power=3)  # tail plane
    m.blob("visor", (0.45, 0.6, 0.3), (0, -0.7, z + 0.55))  # cockpit bubble
    return m


def hundred_men_gorilla():
    m = Meme("HundredMenGorilla")
    # a huge silverback beating its chest on a little arena, ringed by tiny men about to charge
    m.cyl("rock", 2.0, 0.25, (0, 0, 0.12), seg=48)
    m.torus("darkgray", 2.0, 0.08, (0, 0, 0.25))
    for s in (-1, 1):
        m.squircle("gorilla", (0.7, 0.8, 0.9), (s * 0.55, 0.1, 0.7), power=2.3)  # squat legs
        m.squircle("gorillaface", (0.55, 0.8, 0.25), (s * 0.6, -0.15, 0.32), power=2.5)
    m.squircle("gorilla", (2.2, 1.5, 1.9), (0, 0.15, 2.0), power=2.1)  # huge body
    m.squircle("silverback", (2.0, 1.2, 0.8), (0, 0.4, 2.0), power=2.4)  # silver back
    m.blob("gorillaface", (1.2, 0.5, 0.9), (0, -0.55, 2.2))  # chest
    for s in (-1, 1):
        m.tube("gorilla", [(s * 1.0, 0.0, 2.6), (s * 1.3, -0.4, 2.1), (s * 0.45, -0.75, 2.35)], 0.32)  # fists to chest
        m.blob("gorillaface", (0.45, 0.4, 0.4), (s * 0.4, -0.8, 2.35))
    m.squircle("gorilla", (1.0, 0.95, 0.95), (0, -0.25, 3.25), power=2.3)  # head
    m.squircle("gorilla", (0.7, 0.6, 0.35), (0, 0.0, 3.7), power=2.4)  # crest
    m.squircle("gorillaface", (0.7, 0.4, 0.55), (0, -0.65, 3.1), power=2.4)  # face
    for s in (-1, 1):
        m.eye((s * 0.16, -0.75, 3.35), (0.14, 0.08, 0.12), iris="black", white="gorillaface")
        m.blob("black", (0.08, 0.05, 0.06), (s * 0.08, -0.86, 3.12))  # nostrils
    m.box("black", (0.5, 0.08, 0.1), (0, -0.8, 3.45), bevel=0.03)  # brow
    m.blob("mouth", (0.35, 0.1, 0.18), (0, -0.85, 2.95))
    for k in range(18):  # the hundred men (well, eighteen), tiny and brave
        a = k / 18 * math.tau
        x, y = math.cos(a) * 1.7, math.sin(a) * 1.7
        c = ("red", "blue", "orange", "lime", "purple", "yellow")[k % 6]
        m.cyl(c, 0.08, 0.3, (x, y, 0.45), seg=8)
        m.blob("skin", (0.13, 0.13, 0.13), (x, y, 0.68))
    return m


def pedro_raccoon():
    m = Meme("PedroRaccoon")
    # a raccoon spinning on a record with its arms out, mask and stripy tail, mid-twirl
    m.cyl("turntable", 1.5, 0.25, (0, 0, 0.12), seg=48)
    for r in (0.6, 0.95, 1.3):
        m.torus("darkgray", r, 0.02, (0, 0, 0.26))
    m.cyl("red", 0.4, 0.04, (0, 0, 0.27), seg=24)
    for s in (-1, 1):
        m.tube("raccoondark", [(s * 0.3, 0, 1.4), (s * 0.35, -0.05, 0.75), (s * 0.35, 0, 0.4)], 0.14)
        m.squircle("raccoondark", (0.32, 0.5, 0.2), (s * 0.35, -0.1, 0.32), power=2.5)
    m.squircle("raccoon", (1.3, 1.0, 1.5), (0, 0, 1.9), power=2.3)  # body
    m.blob("mememan", (0.8, 0.4, 1.0), (0, -0.42, 1.85))  # pale belly
    for s in (-1, 1):  # arms flung out, spinning
        m.tube("raccoon", [(s * 0.55, 0, 2.4), (s * 1.1, -0.15, 2.65), (s * 1.6, -0.1, 2.75)], 0.12)
        m.blob("raccoondark", (0.24, 0.22, 0.2), (s * 1.65, -0.1, 2.75))
    m.squircle("raccoon", (1.15, 1.0, 0.95), (0, -0.05, 3.1), power=2.3)  # head
    m.squircle("mememan", (0.6, 0.5, 0.35), (0, -0.5, 2.95), power=2.4)  # muzzle
    m.blob("black", (0.16, 0.12, 0.12), (0, -0.75, 3.02))
    m.squircle("raccoondark", (1.0, 0.2, 0.3), (0, -0.42, 3.25), power=3)  # bandit mask
    for s in (-1, 1):
        m.eye((s * 0.24, -0.5, 3.25), (0.2, 0.1, 0.2), iris="black")
        m.blob("mememan", (0.24, 0.06, 0.08), (s * 0.24, -0.5, 3.43))  # white brows
        mp.ear(m, "raccoon", (s * 0.35, 0, 3.45), (s * 0.5, 0, 3.85), width=0.2, inner="mememan", thick=0.08)
    m.tube("mouth", [(-0.1, -0.72, 2.85), (0, -0.74, 2.82), (0.1, -0.72, 2.85)], 0.018)
    for k in range(6):  # ringed tail curling out behind
        t = k / 5
        m.blob("raccoondark" if k % 2 else "raccoon", (0.35 - t * 0.08,) * 3, (0.5 + t * 0.6, 0.7 + t * 0.2, 1.5 + math.sin(t * 2.5) * 0.4))
    for k in range(3):  # spin lines
        m.torus("white", 1.9 + k * 0.15, 0.015, (0, 0, 1.0 + k * 0.6), scale=(1, 0.6, 1))
    return m


def stonks_head():
    m = Meme("StonksHead")
    # the smooth-faced suit man in front of a chart, the arrow shooting up: stonks
    m.squircle("ink", (3.2, 0.15, 3.0), (0, 0.9, 2.2), power=8)  # chart board
    for k in range(5):
        m.box("darkgray", (3.0, 0.16, 0.02), (0, 0.88, 1.0 + k * 0.6), bevel=0)  # grid lines
        m.box("darkgray", (0.02, 0.16, 2.8), (-1.2 + k * 0.6, 0.88, 2.2), bevel=0)
    pts = [(-1.4, 0.75, 1.0), (-0.8, 0.75, 1.6), (-0.4, 0.75, 1.3), (0.3, 0.75, 2.3), (0.7, 0.75, 2.0), (1.3, 0.75, 3.3)]
    m.tube("orange", pts, 0.07, seg=8)
    m.relief("orange", [(-0.25, 0), (0.25, 0), (0, 0.45)], 0.14, (1.35, 0.75, 3.3), rot=(0, -28, 0), bevel=0.02)
    m.squircle("navy", (2.1, 1.0, 1.3), (0, 0.1, 0.7), power=2.6)  # suit shoulders
    m.relief("navy", [(-0.5, 0), (0, -0.7), (0.5, 0)], 0.1, (0, -0.4, 1.3), bevel=0.02)  # lapels
    m.squircle("white", (0.45, 0.1, 1.0), (0, -0.42, 0.85), power=4)  # shirt
    m.box("red", (0.16, 0.06, 0.7), (0, -0.48, 0.8), bevel=0.03)  # tie
    m.cyl("mememan", 0.28, 0.35, (0, 0, 1.45), seg=16)
    m.squircle("mememan", (1.2, 1.15, 1.55), (0, -0.05, 2.25), power=2.2)  # the smooth bald head
    m.blob("mememan", (0.24, 0.35, 0.4), (0, -0.64, 2.2))  # big nose
    for s in (-1, 1):
        m.blob("darkgray", (0.2, 0.08, 0.1), (s * 0.25, -0.55, 2.45))  # blank, heavy-lidded eyes
        m.blob("mememan", (0.24, 0.1, 0.06), (s * 0.25, -0.58, 2.5))
        m.blob("mememan", (0.15, 0.25, 0.3), (s * 0.6, -0.05, 2.25))  # ears
    m.tube("darkgray", [(-0.15, -0.6, 1.9), (0.15, -0.6, 1.92)], 0.025)
    return m


def vibing_cat():
    m = Meme("HeadBobCat")
    # a white cat with headphones, eyes shut, head tilted mid-bob, next to a boombox
    m.squircle("white", (1.5, 1.3, 1.6), (0, 0.1, 0.95), power=2.2)  # sitting body
    for s in (-1, 1):
        m.squircle("white", (0.35, 0.5, 0.22), (s * 0.3, -0.5, 0.12), power=2.5)
    m.tube("white", [(0.6, 0.6, 0.4), (1.0, 0.5, 0.8), (0.9, 0.3, 1.25), (0.75, 0.2, 1.35)], lambda t: 0.14 - 0.04 * t)
    tilt = 15
    m.squircle("white", (1.4, 1.2, 1.15), (0, -0.05, 2.25), rot=(0, tilt, 0), power=2.4)  # tilted head
    for s in (-1, 1):
        mp.ear(m, "white", (s * 0.45 - 0.08, 0.0, 2.65 + s * -0.1), (s * 0.6 - 0.15, 0.0, 3.15 + s * -0.12), width=0.28, inner="pink", thick=0.1)
        m.tube("black", [(s * 0.17 - 0.05, -0.62, 2.35 - s * 0.04), (s * 0.3 - 0.05, -0.63, 2.3 - s * 0.04), (s * 0.43 - 0.05, -0.62, 2.35 - s * 0.04)], 0.025)
        m.cyl("black", 0.25, 0.18, (s * 0.72 - 0.05, -0.05, 2.25 - s * 0.18), rot=(0, 90 + tilt, 0), seg=20)  # headphone cups
    m.tube("black", [(-0.75, -0.05, 2.45), (-0.4, -0.05, 2.95), (0.2, -0.05, 3.0), (0.65, -0.05, 2.25)], 0.05, seg=8)  # band
    m.blob("pink", (0.12, 0.08, 0.08), (-0.03, -0.66, 2.15))
    m.tube("black", [(-0.13, -0.64, 2.02), (-0.03, -0.66, 1.98), (0.07, -0.64, 2.02)], 0.018)
    # the boombox
    m.squircle("turntable", (1.2, 0.5, 0.75), (-1.35, -0.1, 0.38), power=5)
    for s in (-1, 1):
        m.cyl("darkgray", 0.22, 0.06, (-1.35 + s * 0.32, -0.36, 0.38), rot=(90, 0, 0), seg=20)
    m.tube("darkgray", [(-1.75, -0.1, 0.75), (-1.75, -0.1, 0.95), (-0.95, -0.1, 0.95), (-0.95, -0.1, 0.75)], 0.04)
    for k in range(3):
        m.blob("black", (0.16, 0.08, 0.12), (-1.6 + k * 0.35, -0.3, 1.4 + k * 0.25), rot=(0, -20, 0))
        m.cyl("black", 0.02, 0.35, (-1.53 + k * 0.35, -0.3, 1.57 + k * 0.25), seg=6)
    return m


def polka_cow():
    m = Meme("PolkaSpinCow")
    # a cow spinning on a little pink dance floor, eyes closed, a twirl ribbon round it
    m.cyl("hotpink", 1.6, 0.15, (0, 0, 0.08), seg=48)
    m.torus("yellow", 1.5, 0.05, (0, 0, 0.16))
    for sx in (-1, 1):
        for sy in (-0.55, 0.55):
            m.tube("white", [(sx * 0.4, sy, 1.0), (sx * 0.42, sy, 0.45)], 0.13)
            m.squircle("ink", (0.26, 0.3, 0.18), (sx * 0.42, sy, 0.27), power=2.5)  # hooves
    m.squircle("white", (1.3, 2.0, 1.0), (0, 0, 1.35), power=2.3)  # body
    for k, (x, y, z, sz) in enumerate([(0.55, -0.4, 1.6, 0.55), (-0.5, 0.3, 1.5, 0.7), (0.3, 0.6, 1.75, 0.45), (-0.62, -0.5, 1.2, 0.35)]):
        m.blob("ink", (sz * 0.3, sz, sz), (x + (0.1 if x > 0 else -0.1), y, z))  # black patches on the sides
    m.blob("cowpink", (0.55, 0.5, 0.45), (0, 0.4, 0.9))  # udder
    m.tube("white", [(0, 1.0, 1.6), (0.1, 1.3, 1.3), (0.15, 1.35, 1.0)], 0.05)
    m.blob("ink", (0.15, 0.15, 0.22), (0.15, 1.36, 0.92))
    m.squircle("white", (0.9, 0.95, 0.85), (0, -1.15, 1.85), power=2.3)  # head
    m.squircle("cowpink", (0.75, 0.45, 0.5), (0, -1.6, 1.68), power=2.4)  # muzzle
    for s in (-1, 1):
        m.blob("darkred", (0.1, 0.06, 0.12), (s * 0.15, -1.82, 1.72))
        m.tube("ink", [(s * 0.27 - 0.07, -1.55, 2.0), (s * 0.27, -1.57, 1.96), (s * 0.27 + 0.07, -1.55, 2.0)], 0.022)  # happy shut eyes
        m.cyl("cream", 0.07, 0.35, (s * 0.35, -1.0, 2.35), rot=(0, s * 35, 0), radius2=0.02, seg=10)  # horns
        m.blob("white", (0.4, 0.15, 0.2), (s * 0.55, -1.0, 2.05), rot=(0, s * -20, 0))  # ears
    pts = [(math.cos(t) * 1.4, math.sin(t) * 1.4, 0.6 + t * 0.25) for t in [i * 0.4 for i in range(16)]]
    m.tube("lilac", pts, 0.05, seg=6)  # twirl ribbon
    return m


def gentle_pill_squad():
    m = Meme("GentlePillSquad")
    # two capsule pills in black suits and shades, walking in step to the cinema, very gentle
    for k, x in enumerate((-0.75, 0.75)):
        y = k * 0.25
        m.lathe("pillyellow", [(0, 2.0), (0.62, 2.0), (0.62, 2.8), (0.5, 3.35), (0, 3.55)], (x, y, 0), seg=32)  # yellow top half
        m.lathe("white", [(0, 0.55), (0.5, 0.75), (0.62, 1.2), (0.62, 2.0), (0, 2.0)], (x, y, 0), seg=32)  # white bottom half
        m.torus("darkgray", 0.62, 0.025, (x, y, 2.0))
        m.lathe("black", [(0.64, 0.75), (0.66, 1.6), (0.68, 2.25), (0, 2.3)], (x, y, 0), seg=32)  # suit jacket
        m.relief("white", [(-0.18, 0), (0.18, 0), (0, -0.45)], 0.05, (x, y - 0.67, 2.25), bevel=0)  # shirt V
        m.box("black", (0.1, 0.05, 0.3), (x, y - 0.69, 2.0), bevel=0.02)  # tie
        m.squircle("black", (0.95, 0.15, 0.28), (x, y - 0.55, 2.9), power=4)  # sunglasses
        m.tube("mouth", [(x - 0.15, y - 0.6, 2.55), (x, y - 0.62, 2.5), (x + 0.15, y - 0.6, 2.55)], 0.022)
        for s in (-1, 1):
            m.tube("black", [(x + s * 0.6, y, 2.1), (x + s * 0.75, y - 0.1, 1.6), (x + s * 0.65, y - 0.2, 1.25)], 0.1)
            m.blob("white", (0.2, 0.2, 0.2), (x + s * 0.65, y - 0.22, 1.2))
            m.tube("black", [(x + s * 0.25, y, 0.7), (x + s * 0.27, y - (0.15 if s * (k * 2 - 1) > 0 else -0.15), 0.25)], 0.12)  # walking legs
            m.squircle("black", (0.28, 0.45, 0.16), (x + s * 0.27, y - (0.3 if s * (k * 2 - 1) > 0 else 0.0), 0.1), power=2.5)
    m.cyl("ink", 0.3, 0.02, (0, -0.6, 0.01), seg=12)
    return m


def chicken_jockey():
    m = Meme("ZombieChickenRider")
    # a tiny green zombie kid riding a big white chicken, one arm raised in triumph
    for s in (-1, 1):
        m.tube("beak", [(s * 0.3, 0.1, 1.2), (s * 0.35, 0.0, 0.6), (s * 0.35, -0.1, 0.15)], 0.07)
        for f in range(3):
            m.tube("beak", [(s * 0.35, -0.1, 0.1), (s * 0.35 + (f - 1) * 0.15, -0.4, 0.05)], 0.035)
    m.squircle("chicken", (1.4, 2.0, 1.3), (0, 0.1, 1.75), power=2.1)  # chicken body
    for s in (-1, 1):
        m.blob("chicken", (0.3, 1.2, 0.8), (s * 0.68, 0.2, 1.8), rot=(10, 0, 0))  # wings
    for k in range(3):
        m.blob("chicken", (0.35, 0.3, 0.6), (0, 1.1 + k * 0.1, 2.1 + k * 0.15), rot=(-30 - k * 10, 0, 0))  # tail feathers
    m.squircle("chicken", (0.75, 0.8, 0.9), (0, -0.95, 2.6), power=2.3)  # neck and head
    m.cyl("beak", 0.15, 0.35, (0, -1.45, 2.6), rot=(90, 0, 0), radius2=0.0, seg=10)
    m.blob("red", (0.18, 0.18, 0.35), (0, -1.3, 2.35))  # wattle
    for k in range(3):
        m.blob("red", (0.18, 0.2, 0.22), (0, -1.0 + k * 0.15, 3.05 + (1 - abs(k - 1)) * 0.08))  # comb
    for s in (-1, 1):
        m.eye((s * 0.3, -1.15, 2.75), (0.16, 0.1, 0.16), iris="black")
    # the zombie kid rider
    m.squircle("zombieshirt", (0.75, 0.55, 0.75), (0, 0.15, 2.75), power=2.4)
    for s in (-1, 1):
        m.tube("jeans", [(s * 0.2, 0.1, 2.45), (s * 0.55, -0.1, 2.3), (s * 0.6, -0.15, 1.95)], 0.1)  # legs astride
    m.squircle("zombie", (0.75, 0.7, 0.75), (0, 0.1, 3.5), power=2.3)
    for s in (-1, 1):
        m.blob("black", (0.12, 0.06, 0.12), (s * 0.16, -0.25, 3.55))
    m.tube("black", [(-0.12, -0.26, 3.3), (0.12, -0.26, 3.32)], 0.018)
    m.tube("zombie", [(-0.35, 0.1, 3.0), (-0.55, -0.2, 3.5), (-0.55, -0.25, 4.0)], 0.08)  # arm raised
    m.blob("zombie", (0.18, 0.18, 0.18), (-0.55, -0.25, 4.05))
    m.tube("zombie", [(0.35, 0.1, 3.0), (0.4, -0.45, 2.75)], 0.08)
    return m


ALL = [sus_bean, jawline_chad, croc_bomber, hundred_men_gorilla, pedro_raccoon, stonks_head, vibing_cat, polka_cow,
       gentle_pill_squad, chicken_jockey]
