"""Batch 1 of the meme sculptures (remodeled in the full meme remodel, same ids).
Conventions: z is up, the model faces -y (the front), about 4-5 studs tall. Original parody designs."""
import math

from memekit import Meme
import memeparts as mp


def chill_dude():
    m = Meme("ChillDude")
    # a laid-back dog guy in a baggy gray sweater, hands in his jeans pockets, eyes half shut
    p = mp.person(m, skin="tan", shirt="sweater", pants="jeans", shoes="white", hair=None, hair_style="bald", head=1.05,
                  belly=1.0, expr="smirk", face_kw={"lids": 0.5, "nose": False, "brows": None},
                  arms={"l": ((-0.7, 0.05, 2.45), (-0.45, -0.3, 1.8)), "r": ((0.7, 0.05, 2.45), (0.45, -0.3, 1.8))})
    hc, hs = p["head"], p["head_size"]
    m.squircle("darkgray", (1.15, 0.72, 0.25), (0, 0, 1.66), power=3)  # ribbed sweater hem
    m.torus("darkgray", 0.36, 0.08, (0, 0, p["shoulder_z"] + 0.12), scale=(1, 0.8, 0.7))  # collar
    for s in (-1, 1):
        m.squircle("sky", (0.48, 0.5, 0.16), (s * 0.3, 0, 0.42), power=3)  # rolled jean cuffs
        m.box("navy", (0.3, 0.05, 0.3), (s * 0.4, -0.31, 1.75), bevel=0.02)  # pocket slits
        m.blob("brown", (0.32, 0.22, 0.9), (hc.x + s * hs * 0.48, hc.y + 0.05, hc.z - 0.15), rot=(0, s * 12, 0))  # floppy ears
    m.squircle("cream", (0.6, 0.55, 0.42), (hc.x, hc.y - hs * 0.4, hc.z - 0.2), power=2.4)  # snout
    m.blob("black", (0.24, 0.16, 0.16), (hc.x, hc.y - hs * 0.62, hc.z - 0.08))  # nose
    m.squircle("brown", (hs * 0.88, hs * 0.86, hs * 0.38), (hc.x, hc.y + 0.02, hc.z + hs * 0.33), power=2.4)  # darker top of head
    return m


def log_guy():
    m = Meme("LogBatGuy")
    # a wooden log with stubby legs, big round eyes and a toothy grin, a bat raised to knock
    for s in (-1, 1):
        m.tube("darkbrown", [(s * 0.32, 0, 0.8), (s * 0.34, -0.05, 0.2)], 0.12)
        m.squircle("darkbrown", (0.34, 0.55, 0.22), (s * 0.34, -0.12, 0.11), power=2.6)
    m.lathe("wood", [(0, 0.6), (0.62, 0.62), (0.65, 1.2), (0.63, 2.5), (0.66, 3.6), (0.62, 3.72), (0, 3.72)], (0, 0, 0), seg=36)
    m.cyl("lightwood", 0.58, 0.05, (0, 0, 3.73), seg=36)  # cut top
    for r in (0.42, 0.26, 0.12):
        m.torus("brown", r, 0.018, (0, 0, 3.76))  # tree rings
    for k in range(9):  # bark ridges
        a = k / 9 * math.tau
        m.box("brown", (0.06, 0.06, 2.6), (math.cos(a) * 0.64, math.sin(a) * 0.64, 2.2), rot=(0, 0, math.degrees(a)), bevel=0.02)
    m.blob("lightwood", (0.25, 0.1, 0.2), (0.4, -0.55, 1.4))  # knot
    for s in (-1, 1):
        m.eye((s * 0.26, -0.6, 3.0), (0.44, 0.18, 0.5), iris="black", look=(0, -0.1))
        m.box("darkbrown", (0.36, 0.08, 0.08), (s * 0.27, -0.63, 3.38), rot=(0, -s * 10, 0), bevel=0.02)
    m.blob("darkred", (0.72, 0.12, 0.32), (0, -0.62, 2.48))  # huge grin
    m.box("teeth", (0.56, 0.06, 0.09), (0, -0.67, 2.58), bevel=0.02)
    m.tube("wood", [(-0.6, 0, 2.6), (-0.85, -0.1, 2.1), (-0.82, -0.15, 1.7)], 0.1)  # arm down
    m.blob("wood", (0.22, 0.22, 0.22), (-0.82, -0.17, 1.65))
    m.tube("wood", [(0.6, 0, 2.7), (0.95, -0.1, 3.2), (1.05, -0.15, 3.55)], 0.1)  # arm up
    m.lathe("lightwood", [(0, 0), (0.07, 0), (0.08, 0.6), (0.17, 1.6), (0.19, 2.0), (0, 2.05)], (1.08, -0.18, 3.4), rot=(0, 25, 0))  # the bat
    return m


def cappuccino_ballerina():
    m = Meme("CappuccinoBallerina")
    # half dancer, half coffee cup: en pointe on one leg, arms curved over the cup head, tutu flared
    m.cyl("pink", 0.9, 0.08, (0, 0, 0.04), seg=40)  # a little stage
    m.tube("skin", [(0.1, 0, 1.6), (0.12, -0.02, 0.9), (0.06, 0, 0.25)], lambda t: 0.1 - 0.035 * t)  # standing leg
    m.squircle("pink", (0.16, 0.3, 0.25), (0.06, -0.05, 0.2), power=2.5)  # pointe shoe
    m.tube("skin", [(-0.1, 0, 1.6), (-0.45, -0.25, 1.25), (-0.25, 0.0, 0.95)], lambda t: 0.1 - 0.03 * t)  # bent passe leg
    m.squircle("pink", (0.16, 0.28, 0.22), (-0.22, 0.02, 0.92), power=2.5)
    for k in range(3):  # layered tutu
        m.cyl(("pink", "hotpink", "pink")[k], 1.05 - k * 0.12, 0.06, (0, 0, 1.58 + k * 0.05), seg=48)
    for k in range(20):
        a = k / 20 * math.tau
        m.blob("pink", (0.36, 0.22, 0.1), (math.cos(a) * 0.95, math.sin(a) * 0.95, 1.55), rot=(0, 15, math.degrees(a)))
    m.squircle("hotpink", (0.62, 0.48, 0.95), (0, 0, 2.05), power=2.4)  # leotard
    for s in (-1, 1):  # arms in an arc over the head
        m.tube("skin", [(s * 0.3, 0, 2.4), (s * 0.7, -0.05, 2.95), (s * 0.55, -0.05, 3.6), (s * 0.15, -0.05, 3.85)], 0.065)
    m.lathe("white", [(0, 0), (0.3, 0), (0.42, 0.1), (0.52, 0.5), (0.55, 0.85), (0.5, 0.85), (0.45, 0.2), (0, 0.18)], (0, 0, 2.5), seg=40)  # cup head
    m.cyl("coffee", 0.5, 0.04, (0, 0, 3.3), seg=36)
    m.blob("foam", (0.95, 0.95, 0.1), (0, 0, 3.33))
    m.relief("coffee", [(0.13 * math.sin(t) ** 3, 0.1 * math.cos(t) - 0.04 * math.cos(2 * t) - 0.02 * math.cos(3 * t))
                        for t in [i / 20 * math.tau for i in range(20)]], 0.02, (0, 0, 3.38), rot=(90, 0, 0), bevel=0)  # latte heart
    m.torus("white", 0.18, 0.05, (0.58, 0, 2.95), rot=(90, 0, 0))  # handle
    for s in (-1, 1):
        m.eye((s * 0.17, -0.5, 2.95), (0.16, 0.08, 0.2), iris="black")
        m.blob("pink", (0.13, 0.04, 0.07), (s * 0.3, -0.5, 2.8))
    m.tube("darkred", [(-0.1, -0.52, 2.74), (0, -0.54, 2.7), (0.1, -0.52, 2.74)], 0.022)
    return m


def sneaker_shark():
    m = Meme("SneakerShark")
    # a shark standing on three skinny legs in chunky blue sneakers, grinning with every tooth
    for k, (x, y) in enumerate([(-0.55, -0.2), (0.15, -0.25), (0.75, 0.15)]):
        m.tube("shark", [(x, y + 0.1, 1.75), (x, y, 1.0), (x, y, 0.32)], lambda t: 0.13 - 0.03 * t)
        m.squircle("blue", (0.42, 0.72, 0.32), (x, y - 0.12, 0.17), power=2.6)
        m.squircle("white", (0.44, 0.74, 0.1), (x, y - 0.12, 0.04), power=4)
        m.box("white", (0.3, 0.04, 0.05), (x, y - 0.47, 0.25), bevel=0.01)  # laces
    m.lathe("shark", [(0, -1.9), (0.3, -1.6), (0.62, -0.8), (0.68, 0.0), (0.55, 0.9), (0.28, 1.6), (0.12, 2.0), (0, 2.1)], (0.1, 0, 2.35),
            rot=(0, 90, 0), seg=32, scale=(1, 0.85, 1))  # body along x
    m.squircle("white", (2.6, 0.95, 0.5), (0.1, -0.05, 2.08), power=2.4)  # pale belly
    m.relief("shark", [(0, 0), (0.55, 0.0), (0.1, 0.9)], 0.12, (-0.1, 0, 2.85), bevel=0.04)  # dorsal fin
    m.relief("shark", [(0, 0), (0.7, 0.8), (0.45, 0.0), (0.7, -0.6)], 0.12, (2.05, 0, 2.35), bevel=0.04)  # tail
    for s in (-1, 1):
        m.relief("shark", [(0, 0), (0.5, -0.35), (0.25, 0.05)], 0.08, (-0.3, s * 0.55, 2.0), rot=(s * 20, 0, 0), bevel=0.03)  # pectoral fins
        m.eye((-1.05, s * 0.42, 2.55), (0.18, 0.12, 0.2), iris="black")
    m.blob("mouth", (0.8, 0.9, 0.22), (-1.25, -0.05, 2.2))
    for k in range(8):
        a = math.radians(-70 + k * 20)
        m.cyl("teeth", 0.045, 0.14, (-1.3 + abs(math.sin(a)) * 0.25, math.sin(a) * 0.42, 2.27), rot=(180, 0, 0), radius2=0.0, seg=6)
    for k in range(3):
        m.box("navy", (0.03, 0.05, 0.22), (-0.75 + k * 0.1, -0.56, 2.4), bevel=0.01)  # gills
    return m


def six_seven_hands():
    m = Meme("SixSevenHands")
    # two big hands, palms up and see-sawing, one high one low, holding a giant 6 and 7
    m.lathe("wood", [(0, 0), (1.3, 0), (1.3, 0.15), (1.1, 0.25), (0, 0.25)], (0, 0, 0), seg=40)
    for s, z, num, c in ((-1, 2.1, "6", "orange"), (1, 2.9, "7", "blue")):
        x = s * 0.75
        m.tube("skin2", [(x * 0.6, 0.1, 0.25), (x, 0.1, 1.0), (x, 0.05, z - 0.3)], lambda t: 0.2 - 0.04 * t)  # forearm
        m.squircle("skin2", (0.85, 0.75, 0.25), (x, -0.1, z), power=2.6)  # palm up
        for f in range(4):
            m.squircle("skin2", (0.15, 0.4, 0.15), (x - 0.27 + f * 0.18, -0.55, z + 0.08), rot=(15, 0, 0), power=2.5)
        m.squircle("skin2", (0.18, 0.35, 0.15), (x - s * 0.5, -0.15, z + 0.05), rot=(0, 0, s * 40), power=2.5)  # thumb
        m.squircle("white", (0.5, 0.4, 0.22), (x, 0.25, z - 0.25), power=3)  # shirt cuff
        m.text(c, num, (x, -0.15, z + 0.75), size=1.1, depth=0.25)
    for k in range(4):  # see-saw motion arcs
        m.box("white", (0.05, 0.05, 0.3), (-0.15 + k * 0.1, -0.3, 3.2 + (k % 2) * 0.15), rot=(0, 30, 0), bevel=0.02)
    return m


def low_taper_fade():
    m = Meme("LowTaperFade")
    # a guy with an absolutely massive low taper fade: the hair towers up like a monument
    p = mp.person(m, skin="skin2", shirt="white", pants="black", shoes="sneaker", hair=None, hair_style="bald",
                  expr="smirk", face_kw={"brow_tilt": 0.2},
                  arms={"r": ((0.95, -0.25, 2.9), (0.75, -0.45, 3.45))})
    hc, hs = p["head"], p["head_size"]
    m.squircle("hairblack", (hs * 0.9, hs * 0.88, hs * 0.3), (hc.x, hc.y + 0.03, hc.z + hs * 0.3), power=2.4)  # faded sides
    m.lathe("hairblack", [(0, 0), (0.55, 0), (0.6, 0.4), (0.58, 1.3), (0.5, 1.6), (0, 1.65)], (hc.x, hc.y + 0.05, hc.z + hs * 0.35), seg=24)  # the massive top
    for k in range(4):
        m.torus("darkgray", 0.6 - k * 0.01, 0.015, (hc.x, hc.y + 0.05, hc.z + hs * 0.5 + k * 0.35))  # line-up stripes
    m.lathe("gray", [(0, 0), (0.12, 0), (0.12, 0.35), (0, 0.35)], (0.72, -0.5, 3.45))  # clippers in his hand
    m.box("steel", (0.2, 0.05, 0.06), (0.72, -0.5, 3.82), bevel=0)
    m.text("orange", "MASSIVE", (0, -0.4, 6.5), size=0.4, depth=0.05)
    return m


def dubai_chocolate():
    m = Meme("DubaiChocolate")
    # a fat chocolate bar snapped in half, bright pistachio filling oozing out, on a gold stand
    m.lathe("gold", [(0, 0), (1.0, 0), (1.0, 0.12), (0.3, 0.25), (0.25, 1.0), (0, 1.0)], (0, 0, 0), seg=32)
    for s in (-1, 1):
        x = s * 0.85
        m.squircle("chocolate", (1.5, 1.1, 0.55), (x, 0, 1.3), rot=(0, s * 18, 0), power=5)  # the two halves, tipped up
        for i in range(2):
            for j in range(2):
                m.squircle("milkchoc", (0.6, 0.45, 0.12), (x + (i - 0.5) * 0.65 * math.cos(math.radians(18)), (j - 0.5) * 0.5,
                                                           1.58 + (i - 0.5) * s * -0.2), rot=(0, s * 18, 0), power=4)
        m.squircle("pistachio", (0.18, 1.0, 0.4), (s * 0.12, 0, 1.38), power=3)  # filling at the break
    for k in range(6):  # oozing drips and kataifi strands
        m.blob("pistachio", (0.18, 0.18, 0.3), (-0.1 + k * 0.05, -0.4 + k * 0.16, 1.05 - (k % 3) * 0.1))
        m.tube("lime", [(-0.05, -0.4 + k * 0.15, 1.45), (0.05, -0.45 + k * 0.15, 1.6), (-0.02, -0.4 + k * 0.15, 1.7)], 0.02, seg=5)
    m.blob("pistachio", (0.5, 0.4, 0.12), (0, -0.2, 1.02))
    for k in range(3):  # sparkles: so expensive
        m.relief("gold", [(0, 0.14), (0.04, 0.04), (0.14, 0), (0.04, -0.04), (0, -0.14), (-0.04, -0.04), (-0.14, 0), (-0.04, 0.04)],
                 0.03, (-1.0 + k * 1.0, -0.4, 2.3 + (k % 2) * 0.3))
    return m


def baby_hippo():
    m = Meme("BabyHippo")
    # a tiny wet baby hippo, round as a bean, mouth open to bite, in a splashy puddle
    m.squircle("sky", (3.0, 2.4, 0.08), (0, 0, 0.04), power=2.4)
    for k in range(6):
        a = k / 6 * math.tau
        m.blob("sky", (0.3, 0.3, 0.3), (math.cos(a) * 1.3, math.sin(a) * 1.05, 0.25))  # splash drops
    m.squircle("hippo", (1.7, 2.6, 1.6), (0, 0.2, 1.15), power=2.2)  # body
    for sx in (-1, 1):
        for sy in (-0.5, 0.75):
            m.squircle("hippo", (0.45, 0.45, 0.55), (sx * 0.55, sy, 0.3), power=2.4)  # stubby legs
    m.squircle("hippo", (1.5, 1.4, 1.2), (0, -1.2, 1.55), power=2.3)  # head
    m.squircle("hippopink", (1.4, 0.9, 0.45), (0, -1.65, 1.15), power=2.4)  # lower jaw
    m.blob("darkred", (1.1, 0.6, 0.35), (0, -1.65, 1.38))  # open mouth
    m.blob("hippopink", (0.7, 0.4, 0.2), (0, -1.75, 1.28))  # tongue
    for s in (-1, 1):
        m.cyl("teeth", 0.07, 0.25, (s * 0.45, -1.9, 1.45), radius2=0.0, seg=8)  # little tusks
        m.blob("black", (0.12, 0.08, 0.1), (s * 0.3, -1.95, 1.95))  # nostrils
        m.eye((s * 0.4, -1.55, 2.12), (0.28, 0.16, 0.3), iris="black")
        m.blob("hippo", (0.25, 0.15, 0.3), (s * 0.55, -0.85, 2.2))  # ears
        m.blob("white", (0.1, 0.05, 0.14), (s * 0.7, -1.4, 1.65))  # wet shine
    m.squircle("hippo", (1.25, 0.6, 0.6), (0, -1.75, 1.9), power=2.4)  # snout
    m.blob("hippopink", (0.3, 0.2, 0.2), (0, 1.5, 1.25))  # tail
    return m


def birthday_shake():
    m = Meme("BirthdayShake")
    # a tall purple birthday milkshake: whipped cream, sprinkles, a candle, a bendy straw and a drip
    m.lathe("lilac", [(0, 0), (0.75, 0), (0.75, 0.12), (0.3, 0.2), (0.22, 0.75), (0.5, 0.95), (0.85, 1.0), (0, 1.0)], (0, 0, 0), seg=40)  # glass foot
    m.lathe("purple", [(0, 1.0), (0.85, 1.0), (1.0, 2.9), (1.08, 3.0), (0, 3.0)], (0, 0, 0), seg=40)  # the shake
    for z in (1.6, 2.3):
        m.torus("lilac", 0.95 + (z - 1.6) * 0.05, 0.05, (0, 0, z))
    for k in range(3):  # drips down the side
        a = math.radians(-100 + k * 30)
        m.blob("purple", (0.2, 0.15, 0.6), (math.cos(a) * 1.02, math.sin(a) * 1.02, 2.55 - k * 0.12))
    for k in range(4):  # whipped cream swirl
        m.lathe("white", [(0, 0), (0.95 - k * 0.22, 0.0), (0.85 - k * 0.22, 0.28), (0, 0.32)], (0, 0, 3.0 + k * 0.26), seg=24)
    for k in range(16):
        a = k * 2.4
        m.box(("pink", "yellow", "sky", "orange")[k % 4], (0.12, 0.04, 0.04), (math.cos(a) * 0.6, math.sin(a) * 0.6, 3.25 + (k % 4) * 0.12),
              rot=(0, 30, math.degrees(a)), bevel=0)
    m.cyl("pink", 0.06, 0.6, (-0.25, -0.1, 4.25), seg=10)  # candle
    m.blob("yellow", (0.12, 0.12, 0.2), (-0.25, -0.1, 4.65))
    m.blob("orange", (0.07, 0.07, 0.12), (-0.25, -0.1, 4.68))
    m.tube("white", [(0.4, 0.1, 2.6), (0.45, 0.1, 4.4), (0.6, 0.1, 4.7), (0.85, 0.1, 4.75)], 0.06, seg=10)  # bendy straw
    for k in range(6):
        m.torus("hotpink", 0.065, 0.015, (0.45, 0.1, 3.6 + k * 0.12))
    return m


def punch_and_plushie():
    m = Meme("PunchMonkey")
    # a baby monkey hugging his stuffed orangutan tight, the plushie bigger than he is
    m.squircle("tan", (3.0, 2.2, 0.15), (0, 0, 0.07), power=3)
    # the orangutan plushie, sitting
    m.squircle("orangutan", (1.6, 1.3, 1.6), (0.45, 0.2, 1.05), power=2.2)
    m.squircle("orangutan", (1.15, 1.0, 1.0), (0.45, 0.15, 2.25), power=2.3)
    m.blob("macaqueface", (0.8, 0.4, 0.6), (0.45, -0.3, 2.15))
    for s in (-1, 1):
        m.blob("black", (0.1, 0.05, 0.1), (0.45 + s * 0.17, -0.48, 2.3))  # button eyes
        m.tube("orangutan", [(0.45 + s * 0.7, 0.2, 1.6), (0.45 + s * 0.9, -0.2, 1.0), (0.45 + s * 0.7, -0.4, 0.5)], 0.18)
        m.squircle("orangutan", (0.45, 0.6, 0.3), (0.45 + s * 0.45, -0.5, 0.2), power=2.5)
    m.tube("darkbrown", [(0.3, -0.48, 2.0), (0.45, -0.5, 1.95), (0.6, -0.48, 2.0)], 0.02)
    for k in range(4):  # stitches
        m.box("darkbrown", (0.02, 0.03, 0.12), (0.45, -0.6, 1.1 + k * 0.15), bevel=0)
    # the baby monkey hugging it from the front-left
    m.squircle("macaque", (0.75, 0.7, 0.9), (-0.45, -0.4, 0.95), power=2.3)
    m.squircle("macaque", (0.75, 0.7, 0.7), (-0.5, -0.5, 1.7), power=2.3)
    m.blob("macaqueface", (0.5, 0.3, 0.45), (-0.5, -0.82, 1.65))
    for s in (-1, 1):
        m.blob("macaqueface", (0.2, 0.1, 0.22), (-0.5 + s * 0.38, -0.5, 1.75))  # ears
        m.eye((-0.5 + s * 0.11, -0.95, 1.75), (0.13, 0.08, 0.15), iris="black", lid="macaque", lid_drop=0.5)  # content, eyes shut
        m.tube("macaque", [(-0.5 + s * 0.25, -0.3, 1.3), (-0.1 + s * 0.2, -0.05, 1.35), (0.15 + s * 0.15, 0.1, 1.3)], 0.09)  # arms round it
        m.tube("macaque", [(-0.5 + s * 0.2, -0.45, 0.6), (-0.5 + s * 0.25, -0.65, 0.3)], 0.09)
    m.tube("macaque", [(-0.8, -0.1, 0.8), (-1.2, 0.2, 0.7), (-1.3, 0.5, 1.0)], lambda t: 0.06 - 0.03 * t)  # tail
    return m


ALL = [chill_dude, log_guy, cappuccino_ballerina, sneaker_shark, six_seven_hands, low_taper_fade, dubai_chocolate, baby_hippo,
       birthday_shake, punch_and_plushie]
