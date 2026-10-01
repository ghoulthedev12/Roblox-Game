"""Batch 2 of the meme sculptures (see memes_batch1.py for the conventions:
z is up, the model faces -y, about 4-5 studs tall)."""
import math

from memekit import Meme


def turned(p, deg, about=(0, 0)):
    """Turns a point around the vertical axis (for heads that look to one side)."""
    a = math.radians(deg)
    x, y = p[0] - about[0], p[1] - about[1]
    return (about[0] + x * math.cos(a) - y * math.sin(a), about[1] + x * math.sin(a) + y * math.cos(a), p[2])


def sus_bean():
    m = Meme("SusBean")
    for s in (-1, 1):
        m.cyl("red", 0.3, 0.6, (s * 0.34, 0.0, 0.35), seg=28, scale=(1, 1.25, 1))
        m.blob("red", (0.6, 0.75, 0.3), (s * 0.34, 0.0, 0.08))
    m.cyl("red", 0.72, 1.3, (0, 0, 1.25), seg=36)
    m.blob("red", (1.44, 1.34, 1.3), (0, 0, 1.95))
    m.blob("red", (1.44, 1.34, 0.5), (0, 0, 0.62))
    m.box("darkred", (1.0, 0.5, 1.15), (0, 0.78, 1.35), bevel=0.2)  # backpack
    m.blob("visor", (1.05, 0.5, 0.62), (0, -0.58, 2.0))  # visor
    m.blob("white", (0.36, 0.1, 0.12), (0.2, -0.8, 2.14))  # visor shine
    m.blob("navy", (1.08, 0.46, 0.66), (0, -0.55, 1.98))  # visor rim
    return m


def jawline_chad():
    m = Meme("JawlineChad")
    m.cyl("ink", 0.7, 0.45, (0, 0, 0.22), seg=40)  # round pedestal
    m.cyl("darkgray", 0.56, 0.1, (0, 0, 0.5), seg=40)
    m.cyl("lightgray", 0.5, 0.75, (0, 0, 0.92), seg=40, scale=(1.6, 0.8, 1), radius2=0.66)  # torso, widening up
    m.blob("lightgray", (2.2, 1.0, 0.6), (0, 0, 1.36))  # broad shoulders
    m.cyl("lightgray", 0.36, 0.6, (0, 0.05, 1.72), seg=28)  # thick neck
    yaw = 18  # head turned a little toward the viewer's right, chin up
    S = 1.25  # big head, the star of the bust

    def at(x, y, z):
        return turned((x * S, y * S, 1.95 + (z - 1.95) * S), yaw)
    def sz(x, y, z):
        return (x * S, y * S, z * S)
    m.blob("lightgray", sz(1.0, 1.12, 1.15), at(0, 0.05, 2.75), rot=(0, 0, yaw))  # skull
    m.squircle("lightgray", sz(1.24, 1.0, 0.62), at(0, -0.02, 2.27), rot=(0, 0, yaw), power=3.5)  # the square jaw
    m.squircle("lightgray", sz(0.72, 0.42, 0.42), at(0, -0.42, 2.12), rot=(0, 0, yaw), power=3.5)  # chin
    m.squircle("lightgray", sz(0.94, 0.22, 0.14), at(0, -0.5, 2.84), rot=(0, 0, yaw), power=3)  # brow
    m.cyl("lightgray", 0.09 * S, 0.26 * S, at(0, -0.58, 2.62), rot=(-70, 0, yaw), radius2=0.04)  # nose
    for s in (-1, 1):
        m.blob("ink", sz(0.2, 0.05, 0.06), at(s * 0.23, -0.53, 2.74), rot=(0, 0, yaw))  # narrow eyes
        m.blob("lightgray", sz(0.12, 0.24, 0.32), at(s * 0.52, 0.1, 2.62), rot=(0, 0, yaw))  # ears
    m.blob("ink", sz(1.06, 1.26, 0.5), at(0, 0.12, 3.18), rot=(0, 0, yaw))  # slicked-back hair
    m.blob("ink", sz(0.9, 0.5, 0.35), at(0, 0.5, 2.98), rot=(0, 0, yaw))
    return m


def croc_bomber():
    m = Meme("CrocBomber")
    m.cyl("darkgray", 1.0, 0.16, (0, 0, 0.08), seg=40)  # display stand
    m.cyl("lightgray", 0.08, 1.6, (0, 0, 0.9))
    m.blob("crocgreen", (3.6, 0.95, 0.95), (0, 0, 2.0))  # fuselage = crocodile body
    m.blob("cream", (3.2, 0.8, 0.5), (0, 0, 1.78))  # belly
    m.box("crocgreen", (1.3, 0.55, 0.32), (-2.2, 0, 1.98), bevel=0.12)  # snout
    m.box("crocgreen", (1.2, 0.5, 0.18), (-2.15, 0, 1.72), rot=(0, 8, 0), bevel=0.06)  # open lower jaw
    for i in range(5):
        for s in (-1, 1):
            m.cyl("teeth", 0.05, 0.14, (-2.7 + i * 0.25, s * 0.24, 1.82), rot=(180, 0, 0), radius2=0.0)
    for s in (-1, 1):
        m.blob("crocgreen", (0.3, 0.28, 0.28), (-1.5, s * 0.25, 2.42))  # eye bumps
        m.blob("yellow", (0.14, 0.1, 0.16), (-1.58, s * 0.34, 2.46))
        m.blob("black", (0.04, 0.05, 0.12), (-1.63, s * 0.37, 2.46))
        m.cyl("silverback", 0.2, 0.8, (-0.4, s * 1.1, 1.9), rot=(0, 90, 0))  # engines
        m.cyl("darkgray", 0.08, 0.15, (-0.85, s * 1.1, 1.9), rot=(0, 90, 0))
        m.box("black", (0.05, 0.12, 0.95), (-0.9, s * 1.1, 1.9), bevel=0.02)  # propellers
        m.box("black", (0.05, 0.95, 0.12), (-0.9, s * 1.1, 1.9), bevel=0.02)
        m.blob("darkgray", (0.8, 0.28, 0.28), (0.2, s * 0.35, 1.45))  # bombs
    m.box("silverback", (0.9, 3.4, 0.1), (-0.1, 0, 2.0), bevel=0.04)  # wings
    m.blob("crocgreen", (1.8, 0.45, 0.45), (2.1, 0, 2.1))  # tail
    m.box("crocgreen", (0.6, 0.08, 0.7), (2.7, 0, 2.4), rot=(0, 15, 0), bevel=0.03)  # tail fin
    m.box("silverback", (0.5, 1.4, 0.08), (2.6, 0, 2.1), bevel=0.03)
    for k in range(6):  # ridge scales along the back
        m.cyl("darkgreen", 0.1, 0.18, (-1.2 + k * 0.5, 0, 2.5), radius2=0.0)
    return m


def hundred_men_gorilla():
    m = Meme("HundredMenGorilla")
    m.blob("rock", (3.6, 3.0, 1.0), (0, 0, 0.35))  # rocky mound
    m.blob("rock", (1.8, 1.6, 0.9), (0.1, 0.2, 0.9))
    # the gorilla on top, chest out, fists down (knuckle stance)
    gz = 1.3
    m.blob("gorilla", (1.6, 1.2, 1.5), (0, 0.2, gz + 1.0))  # torso
    m.blob("silverback", (1.3, 0.9, 0.8), (0, 0.45, gz + 1.1))  # silver back
    m.blob("gorillaface", (1.1, 0.4, 0.9), (0, -0.32, gz + 0.95))  # chest
    m.blob("gorilla", (0.85, 0.8, 0.8), (0, -0.25, gz + 1.9))  # head
    m.blob("gorillaface", (0.6, 0.35, 0.45), (0, -0.6, gz + 1.8))  # face
    m.blob("gorilla", (0.6, 0.25, 0.14), (0, -0.62, gz + 2.05))  # brow ridge
    for s in (-1, 1):
        m.blob("black", (0.08, 0.05, 0.07), (s * 0.13, -0.77, gz + 1.92))
        m.tube("gorilla", [(s * 0.8, 0.0, gz + 1.45), (s * 1.15, -0.3, gz + 0.8), (s * 1.0, -0.45, gz + 0.1)], lambda t: 0.3 - 0.06 * t)
        m.blob("gorilla", (0.42, 0.42, 0.32), (s * 1.0, -0.48, gz + 0.06))  # fists
        m.tube("gorilla", [(s * 0.4, 0.3, gz + 0.5), (s * 0.5, 0.2, gz + 0.1)], 0.22)
    # the men: little figures charging up the rock from every side
    colors = ["blue", "red", "green", "orange", "purple", "sky", "yellow", "hotpink"]
    k = 0
    for ring, (r, z) in enumerate([(1.75, 0.15), (1.35, 0.55)]):
        for i in range(10 if ring == 0 else 6):
            a = (i + ring * 0.5) / (10 if ring == 0 else 6) * math.tau
            x, y = math.cos(a) * r, math.sin(a) * r * 0.85
            c = colors[k % len(colors)]
            k += 1
            m.cyl(c, 0.09, 0.32, (x, y, z + 0.2))
            m.blob("skin", (0.16, 0.16, 0.16), (x, y, z + 0.43))
            m.tube(c, [(x, y, z + 0.3), (x * 0.9, y * 0.9, z + 0.5)], 0.035)  # arm raised
    return m


def pedro_raccoon():
    m = Meme("PedroRaccoon")
    m.cyl("turntable", 1.3, 0.25, (0, 0, 0.12), seg=48)  # turntable
    m.cyl("red", 0.4, 0.27, (0, 0, 0.13), seg=32)  # label
    m.torus("darkgray", 1.0, 0.02, (0, 0, 0.25))
    m.torus("darkgray", 0.7, 0.02, (0, 0, 0.25))
    # the raccoon, upright mid-spin, arms out
    for s in (-1, 1):
        m.tube("raccoondark", [(s * 0.25, 0, 0.3), (s * 0.28, 0, 0.9)], 0.13)  # legs
        m.tube("raccoon", [(s * 0.45, 0, 1.8), (s * 0.9, -0.2, 1.95), (s * 1.2, -0.3, 2.15)], 0.12)  # arms out
        m.blob("raccoondark", (0.2, 0.2, 0.2), (s * 1.22, -0.3, 2.17))
    m.blob("raccoon", (1.0, 0.85, 1.4), (0, 0, 1.45))  # body
    m.blob("lightgray", (0.6, 0.3, 0.9), (0, -0.33, 1.4))  # belly
    m.blob("raccoon", (0.95, 0.85, 0.75), (0, -0.05, 2.45))  # head
    m.blob("lightgray", (0.5, 0.45, 0.32), (0, -0.4, 2.33))  # muzzle
    m.blob("black", (0.14, 0.1, 0.1), (0, -0.64, 2.38))  # nose
    m.blob("raccoondark", (0.92, 0.3, 0.26), (0, -0.33, 2.55))  # the bandit mask
    for s in (-1, 1):
        m.blob("white", (0.18, 0.06, 0.16), (s * 0.2, -0.47, 2.56))
        m.blob("black", (0.08, 0.05, 0.09), (s * 0.2, -0.5, 2.56))
        m.cyl("raccoon", 0.16, 0.3, (s * 0.32, 0, 2.85), rot=(0, s * 15, 0), radius2=0.03)  # ears
        m.blob("white", (0.3, 0.05, 0.12), (s * 0.18, -0.46, 2.72))  # brows
    for k in range(6):  # ringed tail curling out behind
        t = k / 5
        m.blob("raccoondark" if k % 2 else "raccoon", (0.34 - t * 0.08, 0.34, 0.34),
               (0.3 + t * 0.6, 0.45 + t * 0.2, 0.9 + math.sin(t * 3) * 0.3))
    return m


def stonks_head():
    m = Meme("StonksHead")
    m.box("navy", (2.0, 1.0, 1.4), (0, 0.1, 0.7), bevel=0.3)  # suit
    m.box("white", (0.5, 0.1, 1.1), (0, -0.42, 0.85), bevel=0.04)  # shirt
    m.cyl("red", 0.16, 0.85, (0, -0.47, 0.85), radius2=0.05, rot=(180, 0, 0))  # tie
    for s in (-1, 1):
        m.box("navy", (0.4, 0.08, 1.1), (s * 0.32, -0.44, 0.95), rot=(0, s * 20, 0), bevel=0.03)  # lapels
    m.cyl("mememan", 0.28, 0.5, (0, 0, 1.55))
    m.blob("mememan", (1.0, 1.05, 1.35), (0, 0, 2.3))  # the smooth bald head
    m.blob("mememan", (0.16, 0.3, 0.3), (0, -0.55, 2.25))  # nose
    for s in (-1, 1):
        m.blob("ink", (0.12, 0.06, 0.08), (s * 0.2, -0.47, 2.48))
        m.blob("mememan", (0.12, 0.2, 0.3), (s * 0.5, 0, 2.3))
    m.tube("ink", [(-0.12, -0.5, 2.0), (0.12, -0.5, 2.02)], 0.02)
    # the rising "stonks" arrow behind, zigzagging up and to the right
    pts = [(-1.4, 0.7, 0.5), (-0.7, 0.7, 1.6), (-0.2, 0.7, 1.2), (0.6, 0.7, 2.7), (1.1, 0.7, 2.3), (1.7, 0.7, 3.6)]
    m.tube("orange", pts, 0.12)
    m.cyl("orange", 0.3, 0.6, (1.82, 0.7, 3.9), rot=(0, 25, 0), radius2=0.0)  # arrow head
    m.box("ink", (3.6, 0.1, 3.8), (0.1, 0.85, 2.1), bevel=0.05)  # chart board
    for z in (1.0, 2.0, 3.0):
        m.box("darkgray", (3.4, 0.05, 0.03), (0.1, 0.78, z), bevel=0.0)
    return m


def vibing_cat():
    m = Meme("HeadBobCat")
    m.blob("white", (1.1, 1.1, 1.3), (0, 0.1, 0.75))  # sitting body
    for s in (-1, 1):
        m.blob("white", (0.3, 0.45, 0.25), (s * 0.25, -0.42, 0.12))  # paws
    m.tube("white", [(0.4, 0.5, 0.2), (0.85, 0.4, 0.4), (0.95, 0.1, 0.8)], 0.1)  # tail
    # the head, tilted mid-bob, eyes closed, totally vibing
    tilt = 16
    m.blob("white", (1.05, 0.95, 0.85), (0, -0.05, 1.75), rot=(0, tilt, 0))
    for s in (-1, 1):
        ex = s * 0.24
        m.cyl("white", 0.22, 0.4, (ex * 1.6 - 0.05 * s, 0.0, 2.2 - s * 0.12), rot=(0, tilt + s * 15, 0), radius2=0.03)  # ears
        m.cyl("pink", 0.12, 0.25, (ex * 1.6 - 0.05 * s, -0.06, 2.18 - s * 0.12), rot=(0, tilt + s * 15, 0), radius2=0.02)
        m.tube("ink", [(ex - 0.1, -0.5, 1.82 - s * 0.07), (ex, -0.53, 1.78 - s * 0.07), (ex + 0.1, -0.5, 1.82 - s * 0.07)], 0.025)  # closed eyes
    m.blob("pink", (0.1, 0.06, 0.07), (0.02, -0.53, 1.66))
    m.box("ink", (0.6, 0.55, 0.85), (1.15, -0.1, 0.43), bevel=0.08)  # little speaker
    for z in (0.25, 0.62):
        m.cyl("darkgray", 0.17, 0.05, (1.15, -0.38, z), rot=(90, 0, 0))
    m.tube("ink", [(-0.9, -0.2, 1.8), (-0.9, -0.2, 2.3), (-0.7, -0.2, 2.35)], 0.03)  # music note
    m.blob("ink", (0.18, 0.12, 0.13), (-0.97, -0.2, 1.78))
    return m


def polka_cow():
    m = Meme("PolkaSpinCow")
    m.cyl("hotpink", 1.6, 0.15, (0, 0, 0.08), seg=48)  # little dance floor
    m.torus("yellow", 1.5, 0.05, (0, 0, 0.16))
    for x in (-0.55, 0.55):
        for y in (-0.3, 0.3):
            m.cyl("white", 0.13, 0.75, (x, y, 0.5))
            m.cyl("ink", 0.14, 0.12, (x, y, 0.2))  # hooves
    m.blob("white", (1.9, 1.0, 0.95), (0, 0, 1.25))  # body
    for p, sz in [((-0.4, -0.3, 1.45), (0.6, 0.5, 0.5)), ((0.4, 0.35, 1.3), (0.7, 0.45, 0.5)), ((0.6, -0.35, 1.1), (0.4, 0.4, 0.35)), ((-0.2, 0.4, 1.0), (0.5, 0.35, 0.4))]:
        m.blob("ink", sz, p)  # black patches
    m.blob("cowpink", (0.45, 0.35, 0.25), (0.15, 0, 0.75))  # udder
    m.blob("white", (0.7, 0.6, 0.7), (-1.05, 0, 1.6))  # head
    m.blob("cowpink", (0.45, 0.5, 0.35), (-1.3, 0, 1.42))  # muzzle
    for s in (-1, 1):
        m.blob("ink", (0.06, 0.06, 0.06), (-1.5, s * 0.1, 1.45))  # nostrils
        m.blob("ink", (0.1, 0.06, 0.1), (-1.25, s * 0.26, 1.72))  # eyes
        m.cyl("cream", 0.06, 0.32, (-1.0, s * 0.3, 2.0), rot=(s * -35, 0, 0), radius2=0.02)  # horns
        m.blob("white", (0.12, 0.3, 0.16), (-0.95, s * 0.38, 1.82))  # ears
    m.tube("white", [(0.95, 0, 1.4), (1.15, 0, 1.0), (1.2, 0, 0.75)], 0.04)  # tail
    m.blob("ink", (0.1, 0.1, 0.18), (1.2, 0, 0.7))
    # motion swooshes showing the spin
    m.torus("lilac", 1.25, 0.03, (0, 0, 1.25), rot=(8, 0, 0), scale=(1, 0.7, 1))
    return m


def gentle_pill_squad():
    m = Meme("GentlePillSquad")

    def pill(x, h):
        m.cyl("pillyellow", 0.5, h, (x, 0, 0.5 + h / 2), seg=32)
        m.blob("pillyellow", (1.0, 1.0, 0.8), (x, 0, 0.5 + h))
        m.blob("ink", (1.0, 1.0, 0.6), (x, 0, 0.55))  # suit bottom
        m.cyl("ink", 0.51, h * 0.55, (x, 0, 0.5 + h * 0.27), seg=32)  # black suit
        m.cyl("white", 0.1, h * 0.45, (x, -0.48, 0.5 + h * 0.3), radius2=0.16, scale=(1, 0.3, 1))  # shirt v
        m.cyl("ink", 0.06, h * 0.32, (x, -0.52, 0.5 + h * 0.3), radius2=0.02, rot=(180, 0, 0))  # tie
        for s in (-1, 1):
            m.box("ink", (0.22, 0.24, 0.3), (x + s * 0.16, -0.05, 0.15), bevel=0.08)  # shoes
            m.tube("ink", [(x + s * 0.5, 0, 0.5 + h * 0.5), (x + s * 0.3, -0.45, 0.5 + h * 0.3)], 0.08)  # arms, hands clasped
        m.blob("ink", (0.2, 0.15, 0.15), (x, -0.5, 0.5 + h * 0.3))  # gloved hands
        m.torus("ink", 0.5, 0.05, (x, 0, 0.5 + h * 0.82))  # goggle strap
        for s in (-1, 1):
            m.cyl("ink", 0.17, 0.08, (x + s * 0.2, -0.47, 0.5 + h * 0.82), rot=(90, 0, 0))  # dark shades
        m.tube("ink", [(x, 0, 0.9 + h), (x + 0.05, 0, 1.15 + h)], 0.02)  # sprig of hair
    pill(-0.6, 1.5)  # a short one...
    pill(0.6, 2.0)   # ...and a tall one
    return m


def chicken_jockey():
    m = Meme("ZombieChickenRider")
    for s in (-1, 1):  # chicken legs
        m.tube("beak", [(s * 0.25, 0, 1.0), (s * 0.25, 0, 0.1)], 0.06)
        m.box("beak", (0.4, 0.5, 0.06), (s * 0.25, -0.12, 0.05), bevel=0.02)
    m.blob("chicken", (1.3, 1.6, 1.15), (0, 0.1, 1.45))  # chicken body
    m.blob("chicken", (0.9, 0.6, 0.6), (0, 0.85, 1.75), rot=(-30, 0, 0))  # tail feathers
    for s in (-1, 1):
        m.blob("chicken", (0.18, 0.9, 0.6), (s * 0.66, 0.1, 1.45))  # wings
    m.blob("chicken", (0.75, 0.75, 0.9), (0, -0.75, 2.2))  # chicken head
    m.cyl("beak", 0.16, 0.4, (0, -1.2, 2.15), rot=(90, 0, 0), radius2=0.0)
    m.blob("red", (0.18, 0.2, 0.3), (0, -1.05, 1.92))  # wattle
    m.blob("red", (0.14, 0.5, 0.3), (0, -0.7, 2.65))  # comb
    for s in (-1, 1):
        m.blob("black", (0.1, 0.08, 0.1), (s * 0.32, -0.92, 2.3))
    # the baby zombie riding on its back
    m.box("navy", (0.5, 0.5, 0.35), (0, 0.15, 2.05), bevel=0.1)  # pants (sitting)
    for s in (-1, 1):
        m.tube("navy", [(s * 0.3, 0.05, 2.05), (s * 0.6, -0.2, 1.85), (s * 0.62, -0.25, 1.5)], 0.11)  # legs hug the chicken
    m.box("zombieshirt", (0.65, 0.42, 0.65), (0, 0.15, 2.55), bevel=0.12)  # shirt
    for s in (-1, 1):
        m.tube("zombie", [(s * 0.35, 0.05, 2.75), (s * 0.3, -0.5, 2.75), (s * 0.28, -0.85, 2.7)], 0.1)  # arms reaching forward
    m.blob("zombie", (0.85, 0.8, 0.85), (0, 0.1, 3.25))  # big round baby head
    for s in (-1, 1):
        m.blob("black", (0.18, 0.08, 0.16), (s * 0.18, -0.28, 3.32))  # hollow eyes
        m.blob("zombie", (0.14, 0.2, 0.2), (s * 0.43, 0.1, 3.25))  # ears
    m.tube("darkgreen", [(-0.15, -0.3, 3.03), (0, -0.33, 3.0), (0.15, -0.3, 3.03)], 0.03)  # groaning mouth
    return m


ALL = [sus_bean, jawline_chad, croc_bomber, hundred_men_gorilla, pedro_raccoon, stonks_head, vibing_cat, polka_cow,
       gentle_pill_squad, chicken_jockey]
