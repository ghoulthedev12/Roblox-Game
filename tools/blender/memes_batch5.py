"""Batch 5 of the meme sculptures: World 1 (Grassland Dig Pit).
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp

for _name, _c in [
    ("echidna", (205, 40, 45)), ("echidnadark", (150, 25, 35)), ("muzzle", (240, 200, 160)), ("hamster", (250, 205, 70)),
    ("hamsterdark", (205, 150, 40)), ("bunny", (150, 150, 160)), ("bunnybelly", (225, 225, 230)), ("lasagna", (235, 120, 60)),
    ("pasta", (250, 215, 140)), ("sauce", (200, 45, 30)), ("vinyl", (20, 20, 24)), ("shellgreen", (60, 150, 60)),
    ("shellrim", (245, 240, 210)), ("grapegreen", (150, 205, 90)), ("surgical", (90, 190, 170)), ("hatch", (210, 60, 60)),
    ("tire", (30, 30, 34)), ("glass", (170, 210, 240)), ("burger", (190, 110, 50)), ("bun", (230, 170, 80)),
    ("aurorag", (90, 255, 170)), ("tape", (40, 42, 46)), ("titan", (150, 90, 190)), ("titandark", (100, 55, 140)),
    ("buggy", (250, 200, 40)), ("dartred", (215, 45, 50)), ("dartgreen", (40, 140, 70)), ("cork", (225, 205, 160)),
    ("pinstripe", (60, 60, 70)), ("bone", (240, 238, 225)), ("hoodorange", (240, 140, 50)), ("glowblue", (90, 200, 255)),
    ("onesie", (130, 200, 240)), ("sugar", (252, 252, 252)), ("hatbrown", (150, 95, 50)), ("boot", (120, 70, 40)),
    ("tile", (225, 225, 215)), ("banner", (250, 250, 245)), ("mug", (240, 240, 240)), ("platter", (200, 205, 215)),
]:
    rgb(_name, *_c)


def da_wae_echidna():
    m = Meme("DaWaeEchidna")
    # a stubby red echidna: pear body, cream muzzle with big lips, red quill dreads, a signpost
    m.squircle("echidna", (1.9, 1.6, 2.0), (0, 0, 1.25), power=2.2)  # body
    m.blob("muzzle", (1.1, 0.5, 0.9), (0, -0.62, 1.15))  # belly patch
    m.squircle("echidna", (1.7, 1.5, 1.5), (0, -0.05, 2.75), power=2.3)  # head
    m.squircle("muzzle", (1.05, 0.7, 0.62), (0, -0.66, 2.42), power=2.4)  # muzzle
    m.blob("lips", (0.95, 0.34, 0.28), (0, -0.98, 2.4))  # big lips
    m.tube("mouth", [(-0.34, -1.13, 2.4), (0, -1.16, 2.38), (0.34, -1.13, 2.4)], 0.03)
    m.blob("black", (0.26, 0.16, 0.18), (0, -1.0, 2.68))  # nose
    for s in (-1, 1):
        m.eye((s * 0.32, -0.66, 3.0), (0.36, 0.2, 0.42), iris="black", lid="echidna", lid_drop=0.45, look=(0, -0.2))
    for k in range(7):  # dread quills hanging down the back
        a = math.radians(-70 + k * 23)
        base = (math.sin(a) * 0.6, 0.35, 3.25 + math.cos(a) * 0.15)
        m.tube("echidnadark", [base, (math.sin(a) * 0.95, 0.85, 2.7), (math.sin(a) * 1.05, 1.05, 2.05)], lambda t: 0.18 * (1 - 0.7 * t))
    for s in (-1, 1):
        m.tube("echidna", [(s * 0.85, -0.2, 1.7), (s * 1.15, -0.45, 1.2), (s * 1.05, -0.6, 0.9)], 0.17)  # stubby arms
        m.blob("white", (0.42, 0.42, 0.38), (s * 1.05, -0.62, 0.86))  # mittens
        m.squircle("brown", (0.6, 0.85, 0.38), (s * 0.5, -0.25, 0.19), power=2.6)  # boots
    # the signpost: it knows the way
    m.cyl("wood", 0.07, 3.6, (1.55, 0.3, 1.8), seg=10)
    m.relief("cream", [(0, 0), (1.1, 0), (1.45, 0.25), (1.1, 0.5), (0, 0.5)], 0.12, (1.25, 0.3, 3.15))
    m.text("darkbrown", "DA WAE", (1.85, 0.22, 3.4), size=0.26, depth=0.04)
    return m


def aisle_yodel_set():
    m = Meme("AisleYodelSet")
    m.squircle("tile", (3.2, 2.2, 0.16), (0, 0, 0.08), power=6)  # store floor tile
    for k in range(3):
        m.box("lightgray", (0.04, 2.2, 0.02), (-1.1 + k * 1.1, 0, 0.165), bevel=0)
    # tiny cowboy boots
    for s, turn in ((-1, 12), (1, -8)):
        x = s * 0.55
        m.squircle("boot", (0.36, 0.95, 0.24), (x, -0.25, 0.3), rot=(0, 0, turn), power=2.8)  # foot
        m.lathe("boot", [(0.2, 0.25), (0.22, 0.6), (0.24, 1.2), (0.27, 1.3), (0, 1.3)], (x, 0.05, 0.0))  # shaft
        m.cyl("darkbrown", 0.16, 0.12, (x, 0.18, 0.22), rot=(0, 0, 0), seg=12)  # heel
        m.torus("gold", 0.24, 0.025, (x, 0.05, 1.0))
        m.blob("gold", (0.12, 0.08, 0.12), (x, -0.3, 0.75))  # star stitch
    # the little hat on top of the boots, tipped forward
    m.lathe("hatbrown", [(0.95, 0), (0.95, 0.05), (0.5, 0.08), (0.42, 0.55), (0.3, 0.7), (0, 0.66)], (0, 0.0, 1.45), rot=(-14, 0, 8))
    m.torus("darkbrown", 0.44, 0.05, (0, 0.03, 1.6), rot=(-14, 0, 8))
    for s in (-1, 1):  # curled brim
        m.blob("hatbrown", (0.45, 1.6, 0.22), (s * 0.85, 0.0, 1.62), rot=(-14, s * 28, 8))
    # a price tag and floating music notes (the yodel)
    m.relief("yellow", [(0, 0), (0.6, 0), (0.6, 0.35), (0, 0.35)], 0.03, (1.25, -0.6, 0.18), rot=(-70, 0, 0))
    for i, (x, z) in enumerate([(-1.0, 2.4), (-0.4, 2.85), (0.4, 2.6)]):
        m.blob("black", (0.22, 0.12, 0.17), (x, -0.2, z), rot=(0, -20, 0))
        m.cyl("black", 0.025, 0.55, (x + 0.09, -0.2, z + 0.27), seg=6)
        m.box("black", (0.22, 0.05, 0.06), (x + 0.18, -0.2, z + 0.52), rot=(0, -20, 0), bevel=0)
    return m


def convince_me_table():
    m = Meme("ConvinceMeTable")
    # a folding table with a banner, a mug and a stack of papers; an empty chair waits behind it
    m.squircle("platter", (3.4, 1.5, 0.12), (0, 0, 1.55), power=6)  # table top
    for sx in (-1, 1):
        for sy in (-1, 1):
            m.cyl("darkgray", 0.04, 1.55, (sx * 1.5, sy * 0.55, 0.78), rot=(sy * 12, 0, 0), seg=8)
    m.squircle("banner", (3.0, 0.06, 1.1), (0, -0.8, 1.0), power=6)  # banner hanging off the front
    m.text("navy", "CONVINCE", (0, -0.85, 1.22), size=0.42, depth=0.04)
    m.text("red", "ME OTHERWISE", (0, -0.85, 0.75), size=0.3, depth=0.04)
    m.lathe("mug", [(0, 0), (0.2, 0), (0.22, 0.42), (0.2, 0.42), (0.18, 0.06), (0, 0.06)], (0.9, 0.1, 1.61))
    m.torus("mug", 0.1, 0.03, (1.13, 0.1, 1.82), rot=(90, 0, 0))
    m.cyl("coffee", 0.17, 0.02, (0.9, 0.1, 1.98))
    for k in range(4):  # stack of papers
        m.box("white", (0.8, 0.55, 0.03), (-0.8 + k * 0.02, 0.0, 1.63 + k * 0.035), rot=(0, 0, k * 4), bevel=0.005)
    m.box("red", (0.1, 0.1, 0.5), (-0.3, 0.2, 1.85), rot=(0, 20, 0), bevel=0.02)  # a marker
    # the empty folding chair behind the table
    m.squircle("darkgray", (1.0, 0.95, 0.1), (0, 1.25, 1.0), power=6)
    m.squircle("darkgray", (1.0, 0.1, 0.9), (0, 1.75, 1.6), rot=(-8, 0, 0), power=6)
    for sx in (-1, 1):
        m.cyl("gray", 0.035, 1.0, (sx * 0.45, 1.25, 0.5), rot=(20, 0, 0), seg=8)
        m.cyl("gray", 0.035, 2.0, (sx * 0.45, 1.6, 1.0), rot=(-12, 0, 0), seg=8)
    return m


def shocked_rodent():
    m = Meme("ShockedRodent")
    # a chubby yellow hamster frozen in shock: round ears, both paws on its cheeks, jaw dropped
    m.squircle("hamster", (2.4, 2.0, 2.3), (0, 0, 1.35), power=2.2)  # body
    m.blob("cream", (1.6, 0.6, 1.5), (0, -0.82, 1.25))  # belly
    m.squircle("hamster", (2.3, 1.9, 1.85), (0, -0.05, 3.0), power=2.3)  # head
    for s in (-1, 1):
        m.blob("hamster", (0.75, 0.3, 0.7), (s * 0.85, 0.2, 3.95), rot=(0, s * 20, 0))  # round ears
        m.blob("pink", (0.48, 0.2, 0.46), (s * 0.85, 0.08, 3.95), rot=(0, s * 20, 0))
        m.eye((s * 0.45, -0.88, 3.25), (0.55, 0.26, 0.65), iris="black", look=(0, 0.1))
        m.box("hamsterdark", (0.5, 0.08, 0.1), (s * 0.45, -0.95, 3.75), rot=(0, -s * 15, 0), bevel=0.03)  # raised brows
        # paws pressed on the cheeks
        m.tube("hamster", [(s * 1.05, -0.3, 2.2), (s * 1.35, -0.6, 2.55), (s * 1.0, -0.82, 2.85)], 0.2)
        m.blob("cream", (0.42, 0.3, 0.5), (s * 0.95, -0.88, 2.82))
        m.squircle("hamsterdark", (0.6, 0.85, 0.32), (s * 0.55, -0.4, 0.16), power=2.5)  # feet
    m.blob("pink", (0.22, 0.14, 0.16), (0, -1.0, 2.95))  # nose
    m.blob("mouth", (0.62, 0.3, 0.85), (0, -0.85, 2.45))  # wide-open shocked mouth
    m.blob("tongue", (0.42, 0.2, 0.3), (0, -0.92, 2.2))
    m.box("teeth", (0.28, 0.06, 0.16), (0, -1.0, 2.82), bevel=0.02)  # buck teeth
    m.tube("hamsterdark", [(0, 0.9, 1.0), (0.4, 1.3, 1.2), (0.3, 1.5, 1.6), (0.0, 1.35, 1.75)], lambda t: 0.16 - 0.08 * t)  # curly tail
    # shock lines
    for k in range(5):
        a = math.radians(-60 + k * 30)
        m.box("black", (0.06, 0.06, 0.4), (math.sin(a) * 1.6, -0.3, 4.1 + math.cos(a) * 0.4), rot=(0, math.degrees(a), 0), bevel=0.02)
    return m


def is_this_a_bird():
    m = Meme("IsThisABird")
    # a framed painting standing on an easel: a little man in glasses points at a butterfly
    m.squircle("gold", (3.4, 0.22, 2.7), (0, 0, 2.55), power=8)  # frame
    m.squircle("sky", (3.0, 0.2, 2.3), (0, -0.04, 2.55), power=10)  # canvas
    m.squircle("green", (3.0, 0.21, 0.6), (0, -0.05, 1.7), power=10)  # grass
    for sx in (-1, 1):  # easel legs
        m.cyl("wood", 0.07, 4.2, (sx * 1.0, 0.35, 2.0), rot=(-8, sx * 12, 0), seg=8)
    m.cyl("wood", 0.07, 4.0, (0, 0.9, 1.9), rot=(25, 0, 0), seg=8)
    m.box("wood", (2.8, 0.3, 0.12), (0, -0.1, 1.2), bevel=0.03)  # ledge
    # the man, in relief: head, glasses, arm pointing
    y = -0.2
    m.squircle("suit", (0.8, 0.2, 1.0), (-0.6, y, 2.05), power=3)
    m.blob("skin", (0.62, 0.22, 0.7), (-0.6, y, 2.85))
    m.blob("hairblack", (0.66, 0.24, 0.32), (-0.62, y + 0.02, 3.1))
    for s in (-1, 1):
        m.torus("black", 0.09, 0.02, (-0.48 + s * 0.13, y - 0.1, 2.88), rot=(90, 0, 0))
    m.tube("suit", [(-0.3, y, 2.3), (0.15, y - 0.02, 2.5), (0.55, y - 0.02, 2.65)], 0.1)
    m.blob("skin", (0.18, 0.12, 0.14), (0.66, y - 0.02, 2.67))
    m.box("skin", (0.18, 0.06, 0.05), (0.8, y - 0.02, 2.69), bevel=0.02)  # pointing finger
    # the butterfly
    for s in (-1, 1):
        m.relief("orange", [(0, 0), (s * 0.35, 0.25), (s * 0.4, 0.0), (s * 0.3, -0.2)], 0.03, (1.1, y - 0.05, 3.05))
        m.relief("yellow", [(0, 0), (s * 0.18, 0.12), (s * 0.2, 0.0)], 0.035, (1.1, y - 0.07, 3.05))
    m.cyl("black", 0.025, 0.35, (1.1, y - 0.06, 3.02), seg=6)
    m.text("white", "IS THIS A BIRD?", (0, y - 0.04, 1.6), size=0.24, depth=0.03)
    return m


def chonky_bunny():
    m = Meme("ChonkyBunny")
    # an enormous gray loaf of a rabbit, sitting smug with its arms folded on its belly
    m.squircle("bunny", (3.4, 2.8, 2.7), (0, 0, 1.4), power=2.1)  # body
    m.blob("bunnybelly", (2.4, 0.9, 2.0), (0, -1.0, 1.3))  # belly
    m.squircle("bunny", (2.0, 1.8, 1.6), (0, -0.25, 3.25), power=2.3)  # head
    m.blob("bunnybelly", (1.2, 0.6, 0.75), (0, -1.0, 2.95))  # muzzle
    for s in (-1, 1):
        m.blob("bunnybelly", (0.5, 0.4, 0.42), (s * 0.24, -1.15, 2.98))  # cheeks
        m.blob("bunny", (0.55, 0.32, 1.7), (s * 0.55, 0.0, 4.55), rot=(0, s * 18, 0))  # long rounded ears
        m.blob("pink", (0.32, 0.12, 1.3), (s * 0.55, -0.12, 4.55), rot=(0, s * 18, 0))
        m.eye((s * 0.45, -1.0, 3.45), (0.42, 0.2, 0.36), iris="black", lid="bunny", lid_drop=0.5, look=(-s * 0.2, 0))
        m.squircle("bunny", (0.9, 1.4, 0.55), (s * 0.85, -1.0, 0.28), power=2.4)  # big feet
        m.blob("bunnybelly", (0.6, 0.4, 0.3), (s * 0.85, -1.62, 0.3))
        m.tube("bunny", [(s * 1.4, -0.6, 2.2), (s * 0.9, -1.45, 1.7), (-s * 0.2, -1.55, 1.75)], 0.28)  # folded arms
    m.blob("pink", (0.22, 0.14, 0.15), (0, -1.32, 3.12))  # nose
    m.tube("mouth", [(-0.2, -1.32, 2.82), (0, -1.33, 2.86), (0.2, -1.32, 2.82)], 0.025)  # smug smile
    m.box("teeth", (0.18, 0.05, 0.14), (0, -1.33, 2.76), bevel=0.02)
    m.blob("white", (0.8, 0.8, 0.8), (0, 1.35, 0.9))  # cotton tail
    return m


def spicy_lasagna():
    m = Meme("SpicyLasagna")
    # a baking dish of lasagna with a vinyl record baked into it, flames licking off the top
    m.squircle("platter", (3.2, 2.2, 0.75), (0, 0, 0.38), power=6)  # dish
    m.squircle("platter", (3.5, 2.5, 0.12), (0, 0, 0.75), power=6)  # rim
    for i, (c, z) in enumerate([("pasta", 0.85), ("sauce", 0.97), ("pasta", 1.07), ("cheese", 1.18), ("pasta", 1.28), ("sauce", 1.38)]):
        m.squircle(c, (2.9 - i * 0.02, 1.95 - i * 0.02, 0.13), (0, 0, z), power=5)
    for k in range(8):  # bubbly cheese on top
        m.blob("lasagna", (0.45, 0.4, 0.12), (-1.1 + (k % 4) * 0.7, -0.45 + (k // 4) * 0.9, 1.47))
    m.cyl("vinyl", 1.05, 0.06, (0, 0.15, 2.05), rot=(80, 0, 0), seg=48)  # the record, stuck in it
    m.cyl("red", 0.32, 0.07, (0, 0.13, 2.05), rot=(80, 0, 0), seg=24)
    m.cyl("white", 0.05, 0.08, (0, 0.12, 2.05), rot=(80, 0, 0), seg=10)
    for k in range(3):
        m.torus("ink", 0.5 + k * 0.15, 0.01, (0, 0.13, 2.05), rot=(80, 0, 0))
    for k, x in enumerate((-1.2, -0.6, 0.7, 1.25)):  # flames
        h = 0.9 + (k % 2) * 0.4
        m.relief("fire", [(-0.25, 0), (0.25, 0), (0.18, h * 0.5), (0.05, h), (-0.05, h * 0.55), (-0.2, h * 0.7)], 0.12, (x, -0.6, 1.45))
        m.relief("yellow", [(-0.12, 0), (0.12, 0), (0.06, h * 0.45), (-0.08, h * 0.35)], 0.13, (x, -0.62, 1.45))
    return m


def spiked_shell_crown():
    m = Meme("SpikedShellCrown")
    # a big green spiked turtle shell sitting on a cushion, wearing a golden crown
    m.squircle("red", (2.8, 2.8, 0.6), (0, 0, 0.3), power=3)  # velvet cushion
    for s in (-1, 1):
        for t in (-1, 1):
            m.blob("gold", (0.3, 0.3, 0.3), (s * 1.3, t * 1.3, 0.35))  # tassels
    m.lathe("shellgreen", [(0, 0.55), (1.5, 0.6), (1.55, 0.9), (1.35, 1.6), (0.9, 2.15), (0, 2.35)], (0, 0, 0))
    m.torus("shellrim", 1.52, 0.16, (0, 0, 0.75))  # cream rim
    for k in range(6):  # plates
        a = k / 6 * math.tau
        m.blob("lime", (0.7, 0.7, 0.3), (math.cos(a) * 0.95, math.sin(a) * 0.95, 1.65), rot=(math.degrees(math.sin(a)) * 0.6, -math.degrees(math.cos(a)) * 0.6, 0))
        m.cyl("shellrim", 0.2, 0.55, (math.cos(a) * 1.0, math.sin(a) * 1.0, 1.95),
              rot=(-math.degrees(math.sin(a)) * 0.5, math.degrees(math.cos(a)) * 0.5, 0), radius2=0.0, seg=10)  # spikes
    m.cyl("shellrim", 0.24, 0.6, (0, 0, 2.55), radius2=0.0, seg=12)
    # the crown
    m.lathe("gold", [(0.75, 2.4), (0.78, 2.4), (0.8, 2.85), (0.0, 2.85)], (0, 0, 0.1), seg=40)
    for k in range(5):
        a = k / 5 * math.tau
        m.cyl("gold", 0.16, 0.5, (math.cos(a) * 0.68, math.sin(a) * 0.68, 3.2), radius2=0.0, seg=8)
        m.blob("red" if k % 2 else "blue", (0.18, 0.12, 0.18), (math.cos(a) * 0.8, math.sin(a) * 0.8, 2.75))
    return m


def grape_surgery():
    m = Meme("GrapeSurgery")
    # a grape on a tiny operating table under a lamp, a robot arm stitching it up
    m.squircle("lightgray", (2.8, 1.4, 0.2), (0, 0, 1.6), power=6)  # table top
    m.cyl("gray", 0.2, 1.5, (0, 0, 0.8), seg=16)
    m.cyl("darkgray", 0.8, 0.12, (0, 0, 0.06), seg=24)
    m.squircle("surgical", (2.6, 1.3, 0.06), (0, 0, 1.72), power=8)  # sheet
    m.blob("grapegreen", (1.0, 0.9, 0.85), (0, 0, 2.1))  # the patient
    m.cyl("darkgreen", 0.04, 0.2, (0, 0, 2.6), seg=6)
    for k in range(4):  # stitches
        m.box("black", (0.04, 0.03, 0.18), (-0.18 + k * 0.12, -0.42, 2.15), rot=(0, 20, 0), bevel=0)
    m.tube("black", [(-0.25, -0.43, 2.12), (0.25, -0.43, 2.14)], 0.012)
    # the robot arm
    m.cyl("gray", 0.3, 0.2, (1.6, 0.6, 0.1), seg=18)
    m.tube("lightgray", [(1.6, 0.6, 0.2), (1.6, 0.6, 2.4), (1.0, 0.3, 3.1), (0.45, -0.1, 2.7)], 0.1)
    for p in [(1.6, 0.6, 2.4), (1.0, 0.3, 3.1)]:
        m.blob("darkgray", (0.26, 0.26, 0.26), p)
    m.cyl("steel", 0.03, 0.35, (0.35, -0.2, 2.5), rot=(0, -35, 0), seg=8)  # scalpel
    m.box("steel", (0.04, 0.08, 0.14), (0.25, -0.25, 2.38), rot=(0, -35, 0), bevel=0.01)
    # the lamp
    m.cyl("gray", 0.05, 2.6, (-1.5, 0.6, 2.4), seg=8)
    m.tube("gray", [(-1.5, 0.6, 3.7), (-0.9, 0.3, 4.0), (-0.3, 0.1, 3.8)], 0.05)
    m.lathe("lightgray", [(0, 0.3), (0.5, 0.0), (0.55, -0.05), (0, -0.05)], (-0.2, 0.1, 3.5))
    m.cyl("yellow", 0.4, 0.03, (-0.2, 0.1, 3.44), seg=24)
    m.text("darkgreen", "they did surgery", (0, -0.75, 1.55), size=0.18, depth=0.03)
    return m


def bad_boy_hatchback():
    m = Meme("BadBoyHatchback")
    # a little red hatchback with memes bursting out of the windows, a hand slapping the roof
    m.squircle("hatch", (3.6, 1.8, 1.1), (0, 0, 0.95), power=3.2)  # body
    m.squircle("hatch", (2.5, 1.66, 1.15), (0.35, 0, 1.95), power=3)  # cabin
    m.squircle("hatch", (2.3, 1.6, 0.18), (0.4, 0, 2.55), power=4)  # roof
    for x in (-1.05, 1.0):
        for s in (-1, 1):
            m.cyl("tire", 0.42, 0.3, (x, s * 0.82, 0.42), rot=(90, 0, 0), seg=24)
            m.cyl("lightgray", 0.2, 0.32, (x, s * 0.82, 0.42), rot=(90, 0, 0), seg=16)
    for s in (-1, 1):  # side windows (two each) with the pillars between them
        for x in (-0.15, 0.85):
            m.squircle("glass", (0.85, 0.06, 0.55), (x, s * 0.84, 2.05), power=5)
    m.squircle("glass", (0.12, 1.4, 0.6), (-0.95, 0, 2.0), rot=(0, -30, 0), power=6)  # windshield
    for s in (-1, 1):
        m.blob("yellow", (0.25, 0.1, 0.2), (-1.8, s * 0.6, 1.05))  # headlights
        m.blob("red", (0.2, 0.1, 0.18), (1.8, s * 0.65, 1.15))
    m.squircle("darkgray", (0.25, 1.6, 0.25), (-1.82, 0, 0.6), power=4)  # bumper
    # memes stuffed inside: little colored cards poking out of the windows
    for k, (c, x, z, r) in enumerate([("yellow", -0.25, 2.05, 20), ("sky", 0.35, 2.15, -15), ("pink", 0.95, 2.0, 30), ("lime", 1.3, 2.2, -25)]):
        m.box(c, (0.45, 0.06, 0.5), (x, -0.9, z), rot=(10, r, 0), bevel=0.02)
        m.blob("black", (0.06, 0.03, 0.06), (x - 0.08, -0.95, z + 0.05))
        m.blob("black", (0.06, 0.03, 0.06), (x + 0.08, -0.95, z + 0.05))
    # the slapping hand + arm, flat on the roof
    m.tube("shirtwhite", [(1.6, -0.6, 3.9), (1.25, -0.35, 3.25), (0.95, -0.15, 2.85)], lambda t: 0.17 - 0.03 * t)
    m.squircle("skin", (0.55, 0.42, 0.16), (0.7, -0.05, 2.72), rot=(0, 8, 0), power=2.4)
    for k in range(4):
        m.squircle("skin", (0.1, 0.34, 0.09), (0.48 + k * 0.12, -0.32, 2.7), power=2.4)
    m.squircle("skin", (0.12, 0.2, 0.09), (0.98, -0.25, 2.72), rot=(0, 0, -30), power=2.4)  # thumb
    for k in range(3):  # slap lines
        a = math.radians(-35 + k * 35)
        m.box("yellow", (0.06, 0.06, 0.4), (0.7 + math.sin(a) * 0.75, -0.1, 3.1 + math.cos(a) * 0.35), rot=(0, math.degrees(a), 0), bevel=0.02)
    return m


def temple_tap():
    m = Meme("TempleTap")
    # a guy in a puffy jacket grinning slyly and tapping his temple: big brain move
    p = mp.person(m, skin="skin3", shirt="navy", pants="black", shoes="black", hair="hairblack", hair_style="fade",
                  expr="smirk", face_kw={"brow_tilt": -0.2, "look": (0.3, 0.2)},
                  arms={"r": ((1.05, -0.35, 3.0), (0.62, -0.45, 3.85))})
    hc, hs = p["head"], p["head_size"]
    m.box("skin3", (0.08, 0.3, 0.08), (hc.x + 0.48, hc.y - 0.2, hc.z + 0.12), rot=(0, 30, 0), bevel=0.03)  # finger on temple
    m.squircle("navy", (1.2, 0.75, 0.45), (0, 0, 3.0), power=2.4)  # puffy collar
    for z in (2.2, 2.55):
        m.torus("ink", 0.55, 0.03, (0, 0, z), scale=(1, 0.62, 1))  # jacket puff lines
    # the light bulb idea
    m.lathe("yellow", [(0, 0), (0.12, 0.02), (0.14, 0.15), (0.3, 0.4), (0.28, 0.65), (0, 0.78)], (0.95, -0.2, 4.95))
    m.cyl("gray", 0.13, 0.15, (0.95, -0.2, 4.95), seg=12)
    return m


def steamed_clams():
    m = Meme("SteamedClams")
    # a silver platter of plump burgers, and a little aurora glowing above them
    m.cyl("platter", 1.6, 0.1, (0, 0, 0.6), seg=48)
    m.torus("lightgray", 1.55, 0.06, (0, 0, 0.66))
    m.cyl("lightgray", 0.3, 0.55, (0, 0, 0.28), seg=20, radius2=0.5)  # stand
    for k, (x, y) in enumerate([(-0.7, 0.2), (0.7, 0.2), (0, -0.45), (0, 0.65)]):
        z = 0.72
        m.blob("bun", (0.95, 0.95, 0.3), (x, y, z + 0.1))
        m.cyl("green", 0.5, 0.05, (x, y, z + 0.22), seg=20)
        m.cyl("burger", 0.46, 0.16, (x, y, z + 0.3), seg=20)
        m.cyl("cheese", 0.48, 0.04, (x, y, z + 0.4), seg=4, rot=(0, 0, 45))
        m.blob("bun", (0.95, 0.95, 0.6), (x, y, z + 0.5))
        for j in range(5):
            m.blob("cream", (0.06, 0.04, 0.03), (x - 0.2 + j * 0.1, y - 0.3, z + 0.72))
    # the aurora: wavy glowing ribbons rising off the platter
    for k, c in enumerate(("aurorag", "lime", "sky")):
        pts = [(-1.3 + i * 0.26, 0.4 + k * 0.15, 1.75 + k * 0.3 + math.sin(i * 0.9 + k) * 0.22 + math.sin(i / 10 * math.pi) * 0.4) for i in range(11)]
        m.tube(c, pts, lambda t: 0.08 + 0.05 * math.sin(t * math.pi), seg=8)
    for i in range(6):
        a = i * 1.1
        m.blob("white", (0.08, 0.08, 0.08), (math.cos(a) * 1.4, 0.6, 2.6 + math.sin(a) * 0.45))  # stars
    return m


def mega_seal_tape():
    m = Meme("MegaSealTape")
    # a little rowboat sawn in half and taped back together with a giant roll of tape
    bx = -0.9  # the boat sits on the left, the roll stands on the right
    for s in (-1, 1):  # two hull halves, pointed bow and square stern, a gap sawn between them
        x = bx + s * 0.78
        m.squircle("wood", (1.45, 1.3, 0.75), (x, 0, 0.45), power=2.0 if s < 0 else 3.0)
        m.squircle("lightwood", (1.2, 1.05, 0.1), (x, 0, 0.8), power=2.0 if s < 0 else 3.0)  # inside
        m.box("darkbrown", (0.12, 1.1, 0.06), (x, 0, 0.86), bevel=0.02)  # bench
        for z in (0.35, 0.55):
            m.torus("darkbrown", 0.62, 0.015, (x, 0, z), scale=(1.1, 1.0, 0.2))  # planks
    m.squircle("tape", (0.45, 1.42, 0.85), (bx, 0, 0.47), power=5)  # the tape wrapped round the cut
    m.text("orange", "MEGA", (bx, -0.72, 0.5), size=0.14, depth=0.02)
    m.blob("water", (0.6, 0.5, 0.06), (bx - 0.8, 0, 0.84))  # the water stays in
    # the giant roll, standing on its edge, facing out
    rx, rz = 1.35, 1.15
    m.cyl("tape", 1.15, 0.75, (rx, 0.2, rz), rot=(90, 0, 0), seg=48)
    m.cyl("cream", 0.62, 0.77, (rx, 0.2, rz), rot=(90, 0, 0), seg=32)
    m.cyl("white", 0.52, 0.79, (rx, 0.2, rz), rot=(90, 0, 0), seg=32)
    m.text("orange", "MEGA", (rx, -0.19, rz + 0.75), size=0.22, depth=0.03)
    m.text("white", "SEAL", (rx, -0.19, rz - 0.78), size=0.2, depth=0.03)
    m.squircle("tape", (0.75, 0.9, 0.05), (rx - 0.2, -0.45, 0.03), power=6)  # a strip unrolled on the ground
    return m


def purple_titan_buggy():
    m = Meme("PurpleTitanBuggy")
    # a huge purple titan, knees up to his chin, squeezed into a tiny yellow buggy
    m.squircle("buggy", (2.8, 1.8, 0.8), (0, 0, 0.75), power=3)
    for x in (-1.0, 1.0):
        for s in (-1, 1):
            m.cyl("tire", 0.4, 0.35, (x, s * 0.95, 0.4), rot=(90, 0, 0), seg=24)
            m.cyl("gray", 0.18, 0.37, (x, s * 0.95, 0.4), rot=(90, 0, 0), seg=12)
    m.squircle("darkgray", (0.7, 1.2, 0.35), (-1.35, 0, 0.75), power=3)
    m.cyl("tire", 0.32, 0.08, (-0.6, -0.1, 1.55), rot=(0, -60, 0), seg=20)  # steering wheel
    # the titan
    m.squircle("titan", (1.9, 1.3, 1.6), (0.3, 0.1, 1.95), power=2.4)  # torso
    m.squircle("gold", (2.1, 1.4, 0.45), (0.3, 0.1, 2.65), power=3)  # armor collar
    for s in (-1, 1):
        m.blob("gold", (0.75, 0.75, 0.5), (0.3 + s * 0.95, 0.1, 2.75))  # shoulder pads
        m.tube("titan", [(0.3 + s * 0.4, -0.3, 1.25), (-0.4, s * 0.45, 2.3), (-0.95, s * 0.4, 1.3)], 0.3)  # knees up
        m.squircle("gold", (0.7, 0.55, 0.4), (-1.05, s * 0.4, 1.1), power=3)  # boots
        m.tube("titan", [(0.3 + s * 1.0, 0.1, 2.5), (-0.1 + s * 0.2, s * 0.9, 1.9), (-0.55, s * 0.25, 1.6)], 0.22)  # arms to wheel
        m.blob("gold", (0.38, 0.38, 0.38), (-0.55, s * 0.25, 1.6))  # gloves
    m.squircle("titan", (1.1, 1.05, 1.25), (0.3, 0.05, 3.4), power=2.5)  # head
    for k in range(4):
        m.box("titandark", (0.5, 0.06, 0.05), (0.3, -0.48, 3.0 - k * 0.09 + 0.0), bevel=0.02)  # chin ridges
    for s in (-1, 1):
        m.eye((0.3 + s * 0.22, -0.48, 3.52), (0.24, 0.12, 0.18), iris="black", lid="titan", lid_drop=0.55)
    m.tube("titandark", [(0.12, -0.53, 3.2), (0.3, -0.54, 3.22), (0.48, -0.53, 3.2)], 0.025)
    m.lathe("gold", [(0.58, 0.0), (0.6, 0.3), (0.45, 0.48), (0, 0.55)], (0.3, 0.12, 3.62))  # golden helmet
    for s in (-1, 1):
        m.squircle("gold", (0.18, 0.7, 0.55), (0.3 + s * 0.55, 0.12, 3.55), power=3)  # helmet cheek plates
    return m


def never_miss_dartboard():
    m = Meme("NeverMissDartboard")
    # a dartboard on a stand with every dart in the bullseye
    m.cyl("darkgray", 0.9, 0.12, (0, 0.3, 0.06), seg=32)
    m.cyl("darkgray", 0.08, 1.8, (0, 0.3, 0.95), seg=10)
    m.cyl("black", 1.6, 0.25, (0, 0, 2.9), rot=(90, 0, 0), seg=64)
    for k in range(20):  # alternating wedges
        a = k / 20 * math.tau
        pts = [(0, 0)] + [(math.cos(a + t) * 1.4, math.sin(a + t) * 1.4) for t in (0, math.tau / 20)]
        m.relief("cork" if k % 2 else "black", pts, 0.05, (0, -0.14, 2.9), bevel=0)
    for r, c in ((1.42, "dartred"), (0.9, "dartgreen")):
        m.torus(c, r, 0.07, (0, -0.16, 2.9), rot=(90, 0, 0))
    m.cyl("dartgreen", 0.2, 0.06, (0, -0.17, 2.9), rot=(90, 0, 0), seg=20)
    m.cyl("dartred", 0.1, 0.08, (0, -0.18, 2.9), rot=(90, 0, 0), seg=16)
    for k, (dx, dz, tilt) in enumerate([(0.03, 0.04, 8), (-0.05, -0.02, -6), (0.02, -0.06, 4)]):
        m.cyl("steel", 0.03, 0.3, (dx, -0.35, 2.9 + dz), rot=(90 + tilt, 0, 0), seg=8)
        m.cyl("yellow", 0.07, 0.6, (dx, -0.75, 2.9 + dz + tilt * 0.005), rot=(90 + tilt, 0, 0), seg=10)
        m.relief("red", [(-0.18, 0), (0.18, 0), (0, 0.3)], 0.02, (dx, -1.1, 2.9 + dz), rot=(90 + tilt, 0, 0))
    m.text("white", "NEVER MISSES", (0, -0.2, 4.75), size=0.3, depth=0.04)
    return m


def crime_town_boss():
    m = Meme("CrimeTownBoss")
    # the big boss of a phone-ad crime game: pinstripe suit, fedora, shades, a briefcase of cash
    p = mp.person(m, skin="skin2", shirt="pinstripe", pants="pinstripe", shoes="black", hair="hairblack", hair_style="slick",
                  expr="smirk", build=1.2, belly=1.15, sole=None,
                  arms={"l": ((-0.9, -0.2, 2.2), (-0.8, -0.45, 1.55)), "r": ((0.95, -0.3, 2.6), (0.55, -0.6, 2.75))})
    hc, hs = p["head"], p["head_size"]
    for k in range(5):  # pinstripes
        m.box("lightgray", (0.02, 0.02, 1.3), (-0.4 + k * 0.2, -0.38, 2.45), bevel=0)
    m.squircle("shirtwhite", (0.35, 0.05, 0.6), (0, -0.4, 2.85), power=4)
    m.box("tie", (0.14, 0.05, 0.55), (0, -0.43, 2.75), bevel=0.02)
    # fedora
    m.lathe("ink", [(0.95, 0), (0.95, 0.05), (0.55, 0.1), (0.52, 0.5), (0.0, 0.48)], (hc.x, hc.y + 0.02, hc.z + hs * 0.3))
    m.torus("tie", 0.53, 0.05, (hc.x, hc.y + 0.02, hc.z + hs * 0.3 + 0.16))
    m.squircle("black", (0.95, 0.12, 0.2), (hc.x, hc.y - hs * 0.42, hc.z + 0.07), power=4)  # shades
    m.box("brown", (0.08, 0.08, 0.06), (0.55, -0.85, 2.75), bevel=0.02)  # cigar
    m.blob("orange", (0.06, 0.05, 0.05), (0.55, -0.92, 2.75))
    # briefcase of money
    m.squircle("black", (0.9, 0.3, 0.65), (-0.8, -0.55, 1.2), power=5)
    for k in range(3):
        m.box("cash", (0.7, 0.04, 0.2), (-0.8, -0.72, 1.0 + k * 0.18), bevel=0.01)
    return m


def bone_comedian():
    m = Meme("BoneComedian")
    # a grinning skeleton comedian: orange hoodie, hands in pockets, one glowing eye, at a mic
    m.cyl("darkgray", 0.6, 0.08, (0.9, -0.6, 0.04), seg=24)
    m.cyl("darkgray", 0.04, 2.8, (0.9, -0.6, 1.45), seg=8)
    m.squircle("black", (0.22, 0.24, 0.34), (0.9, -0.62, 2.95), power=2.4)  # mic
    m.squircle("hoodorange", (1.6, 1.0, 1.6), (0, 0, 2.2), power=2.4)  # hoodie
    m.torus("hoodorange", 0.62, 0.22, (0, 0.05, 3.0), scale=(1, 0.8, 1))  # hood collar
    m.squircle("white", (0.6, 0.05, 0.4), (0, -0.5, 1.75), power=4)  # pocket
    for s in (-1, 1):
        m.tube("hoodorange", [(s * 0.78, 0, 2.85), (s * 0.95, -0.15, 2.1), (s * 0.35, -0.48, 1.75)], 0.2)
        m.tube("black", [(s * 0.32, 0, 1.45), (s * 0.34, 0, 0.3)], 0.2)  # shorts/legs
        m.tube("bone", [(s * 0.32, 0, 0.9), (s * 0.34, 0, 0.25)], 0.08)
        m.squircle("pink", (0.38, 0.62, 0.22), (s * 0.34, -0.12, 0.11), power=3)  # slippers
    m.squircle("bone", (1.35, 1.2, 1.15), (0, -0.05, 3.55), power=2.6)  # skull
    m.blob("black", (0.32, 0.12, 0.34), (-0.3, -0.62, 3.65))  # left socket
    m.blob("black", (0.32, 0.12, 0.34), (0.3, -0.62, 3.65))
    m.blob("glowblue", (0.14, 0.06, 0.14), (-0.3, -0.69, 3.66))  # the glowing eye
    m.blob("white", (0.08, 0.05, 0.08), (0.3, -0.69, 3.66))
    m.squircle("bone", (1.0, 0.3, 0.3), (0, -0.48, 3.12), power=3)  # jaw with a permanent grin
    m.tube("black", [(-0.42, -0.64, 3.22), (0, -0.66, 3.12), (0.42, -0.64, 3.22)], 0.025)
    for k in range(7):
        m.box("black", (0.02, 0.02, 0.12), (-0.3 + k * 0.1, -0.64, 3.17 + abs(k - 3) * 0.015), bevel=0)
    return m


def sugar_sneak_johnny():
    m = Meme("SugarSneakJohnny")
    # a toddler caught red-handed: open-mouthed laugh, sugar cubes hidden behind his back
    p = mp.person(m, skin="skin", shirt="onesie", pants="onesie", shoes="sneaker", hair="hairblond", hair_style="swoop",
                  height=0.72, head=1.25, build=1.0, expr="open", face_kw={"brow_tilt": -0.3, "blush": True},
                  arms={"l": ((-0.65, 0.3, 1.8), (-0.3, 0.55, 1.45)), "r": ((0.65, 0.3, 1.8), (0.3, 0.55, 1.45))})
    for k in range(4):  # sugar cubes behind his back
        m.box("sugar", (0.2, 0.2, 0.2), (-0.15 + (k % 2) * 0.22, 0.75, 1.35 + (k // 2) * 0.22), rot=(0, 0, 10 * k), bevel=0.02)
    m.lathe("white", [(0, 0), (0.25, 0), (0.3, 0.2), (0.28, 0.6), (0, 0.65)], (1.15, 0.0, 0.0))  # sugar jar
    m.lathe("sky", [(0, 0.6), (0.3, 0.6), (0.3, 0.68), (0, 0.72)], (1.15, 0.0, 0.0))
    m.text("darkgray", "SUGAR", (1.15, -0.32, 0.3), size=0.12, depth=0.02)
    # "ha ha ha" floating
    for k in range(3):
        m.text("orange", "HA", (-0.9 + k * 0.45, -0.3, 3.8 + k * 0.25), size=0.32, depth=0.05)
    return m


ALL = [da_wae_echidna, aisle_yodel_set, convince_me_table, shocked_rodent, is_this_a_bird, chonky_bunny, spicy_lasagna,
       spiked_shell_crown, grape_surgery, bad_boy_hatchback, temple_tap, steamed_clams, mega_seal_tape, purple_titan_buggy,
       never_miss_dartboard, crime_town_boss, bone_comedian, sugar_sneak_johnny]
