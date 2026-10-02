"""Batch 9 of the meme sculptures: World 5.
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp

for _name, _c in [
    ("turtleking", (150, 110, 200)), ("kingshell", (60, 130, 70)), ("piano", (25, 25, 30)), ("pianokey", (250, 250, 250)),
    ("peach", (255, 170, 130)), ("mascot", (90, 150, 255)), ("vhs", (30, 30, 35)), ("vhslabel", (250, 245, 230)),
    ("carseat", (60, 60, 70)), ("seatbelt", (40, 40, 45)), ("maskgold", (240, 200, 80)), ("masksilver", (200, 205, 220)),
    ("web", (240, 240, 250)), ("canonred", (255, 40, 80)), ("boulder", (140, 130, 120)), ("bodysuit1", (120, 60, 200)),
    ("bodysuit2", (40, 180, 170)), ("spotlight", (255, 250, 200)), ("dogtan", (60, 50, 50)), ("hatgreen", (60, 150, 70)),
    ("shirtorange", (240, 130, 50)), ("target", (240, 240, 240)), ("medal", (210, 215, 225)), ("pommel", (150, 100, 70)),
    ("leather", (120, 70, 40)), ("mat", (60, 110, 200)),
]:
    rgb(_name, *_c)


def peaches_turtle_king():
    m = Meme("PeachesTurtleKing")
    # a spiky-shelled turtle king at a tiny grand piano, belting a love song to a peach
    m.squircle("piano", (2.0, 1.4, 0.9), (-0.9, -0.3, 1.25), power=4)  # piano body
    for k in range(3):
        m.cyl("piano", 0.06, 0.8, (-1.6 + k * 0.7, -0.3 + (k % 2) * 0.5, 0.4), seg=8)
    m.squircle("pianokey", (1.9, 0.35, 0.1), (-0.9, -1.0, 1.35), power=6)
    for k in range(8):
        m.box("piano", (0.08, 0.2, 0.06), (-1.7 + k * 0.23, -1.05, 1.42), bevel=0)
    m.squircle("piano", (1.9, 0.08, 1.0), (-0.9, 0.35, 2.0), rot=(-20, 0, 0), power=6)  # open lid
    m.blob("peach", (0.4, 0.4, 0.4), (-1.5, -0.2, 1.9))  # the peach on the piano
    m.blob("leaf", (0.25, 0.08, 0.12), (-1.4, -0.2, 2.12))
    # the turtle king
    m.squircle("kingshell", (2.0, 1.4, 2.0), (0.9, 0.4, 1.9), power=2.2)  # shell
    for k in range(5):
        a = math.radians(-60 + k * 30)
        m.cyl("white", 0.18, 0.5, (0.9 + math.sin(a) * 0.8, 1.05, 2.0 + math.cos(a) * 0.6), rot=(-80, 0, 0), radius2=0.0, seg=8)
    m.squircle("cream", (1.4, 0.8, 1.6), (0.9, -0.15, 1.8), power=2.4)  # belly plates
    for z in (1.3, 1.75, 2.2):
        m.box("tan", (1.0, 0.05, 0.04), (0.9, -0.55, z), bevel=0.01)
    m.squircle("turtleking", (1.2, 1.1, 1.05), (0.85, -0.1, 3.2), power=2.3)  # head
    m.squircle("turtleking", (0.9, 0.6, 0.5), (0.8, -0.6, 2.95), power=2.4)  # snout
    m.blob("mouth", (0.6, 0.15, 0.35), (0.8, -0.88, 2.85))  # singing
    for s in (-1, 1):
        m.eye((0.85 + s * 0.25, -0.55, 3.38), (0.24, 0.12, 0.28), iris="red", pupil="black", look=(-0.4, 0.3))
        m.cyl("cream", 0.12, 0.45, (0.85 + s * 0.45, -0.1, 3.75), rot=(0, s * 25, 0), radius2=0.0, seg=10)  # horns
        m.tube("turtleking", [(0.9 + s * 0.7, -0.2, 2.6), (0.4 + s * 0.3, -0.6, 2.0), (-0.3 + s * 0.4, -0.95, 1.5)], 0.18)  # arms to keys
        m.squircle("turtleking", (0.5, 0.7, 0.4), (0.9 + s * 0.55, -0.5, 0.3), power=2.5)  # feet
        m.tube("turtleking", [(0.9 + s * 0.5, -0.1, 1.1), (0.9 + s * 0.55, -0.4, 0.5)], 0.22)
    m.lathe("gold", [(0.35, 0), (0.38, 0.32), (0, 0.32)], (0.85, -0.1, 3.65))  # crown
    for k in range(5):
        a = k / 5 * math.tau
        m.cyl("gold", 0.08, 0.22, (0.85 + math.cos(a) * 0.32, -0.1 + math.sin(a) * 0.32, 4.05), radius2=0.0, seg=6)
    for k in range(3):  # hearts floating up
        m.relief("hotpink", [(0.2 * math.sin(t) ** 3, 0.16 * math.cos(t) - 0.065 * math.cos(2 * t) - 0.03 * math.cos(3 * t))
                             for t in [i / 20 * math.tau for i in range(20)]], 0.05, (-0.2 + k * 0.5, -0.6, 3.9 + k * 0.3))
    return m


def kindergarten_mascot():
    m = Meme("KindergartenMascot")
    # a tall, round, too-happy kindergarten mascot: noodle arms, party hat, wide unblinking eyes
    for s in (-1, 1):
        m.tube("mascot", [(s * 0.35, 0, 1.0), (s * 0.4, -0.05, 0.25)], 0.2)
        m.squircle("mascot", (0.45, 0.6, 0.3), (s * 0.42, -0.1, 0.15), power=2.5)
        m.tube("mascot", [(s * 0.9, 0, 2.6), (s * 1.6, -0.3, 2.0), (s * 1.7, -0.4, 1.0), (s * 1.6, -0.4, 0.5)], 0.12)  # long arms
        m.blob("white", (0.32, 0.3, 0.32), (s * 1.6, -0.42, 0.42))
    m.squircle("mascot", (2.0, 1.6, 2.8), (0, 0, 2.3), power=2.1)  # body and head in one
    m.blob("white", (1.4, 0.5, 1.2), (0, -0.62, 1.6))  # belly
    for s in (-1, 1):
        m.blob("white", (0.6, 0.2, 0.7), (s * 0.38, -0.7, 3.0))
        m.blob("black", (0.22, 0.12, 0.22), (s * 0.38, -0.82, 3.0))
    m.blob("mouth", (1.1, 0.15, 0.25), (0, -0.72, 2.4))  # huge grin
    m.box("teeth", (0.9, 0.06, 0.1), (0, -0.8, 2.45), bevel=0.02)
    m.cyl("hotpink", 0.4, 0.9, (0.15, 0.0, 4.0), rot=(0, 10, 0), radius2=0.0, seg=20)  # party hat
    m.blob("yellow", (0.2, 0.2, 0.2), (0.23, 0.0, 4.45))
    m.text("red", "HAPPY!", (0, -0.75, 1.55), size=0.24, depth=0.03)
    return m


def cursed_cartoon_tape():
    m = Meme("CursedCartoonTape")
    # an old VHS tape standing up, its cartoon label smiling a little too wide, static leaking out
    z0 = -0.38  # the tape sits down in its stand
    m.squircle("vhs", (3.2, 0.8, 1.9), (0, 0, 1.45 + z0), power=7)
    for s in (-1, 1):
        m.cyl("darkgray", 0.42, 0.82, (s * 0.85, 0, 1.45 + z0), rot=(90, 0, 0), seg=24)  # reels
        m.cyl("white", 0.12, 0.84, (s * 0.85, 0, 1.45 + z0), rot=(90, 0, 0), seg=6)
    m.squircle("vhslabel", (2.4, 0.06, 0.6), (0, -0.42, 2.0 + z0), power=7)
    m.text("ink", "CARTOON", (-0.5, -0.46, 2.0 + z0), size=0.18, depth=0.02)
    m.blob("yellow", (0.5, 0.06, 0.5), (0.75, -0.46, 2.0 + z0))  # the face sticker
    for s in (-1, 1):
        m.blob("black", (0.08, 0.04, 0.12), (0.75 + s * 0.1, -0.5, 2.06 + z0))
    m.tube("black", [(0.55, -0.5, 1.92 + z0), (0.75, -0.51, 1.84 + z0), (0.95, -0.5, 1.92 + z0)], 0.02)
    m.squircle("red", (1.0, 0.05, 0.3), (0, -0.42, 0.8 + z0), power=7)
    m.text("white", "DO NOT ANSWER", (0, -0.46, 0.8 + z0), size=0.1, depth=0.02)
    for k in range(10):  # static pixels
        m.box(("white", "gray", "black")[k % 3], (0.15, 0.15, 0.15), (-1.4 + k * 0.3, -0.3, 2.65 + z0 + (k * 7 % 5) * 0.12), bevel=0)
    m.squircle("darkgray", (3.4, 1.0, 0.3), (0, 0, 0.15), power=4)  # stand
    return m


def laugh_cry_car_seat():
    m = Meme("LaughCryCarSeat")
    # a car seat with a laughing mask and a crying mask sitting side by side, buckled in
    m.squircle("carseat", (1.9, 1.6, 0.6), (0, 0, 0.9), power=3)  # seat
    m.squircle("carseat", (1.9, 0.5, 2.4), (0, 0.65, 2.2), rot=(-12, 0, 0), power=3)  # back
    m.squircle("carseat", (1.1, 0.45, 0.6), (0, 0.85, 3.65), rot=(-12, 0, 0), power=3)  # headrest
    for k in range(4):
        m.box("darkgray", (1.7, 0.05, 0.04), (0, 0.38, 1.4 + k * 0.45), rot=(-12, 0, 0), bevel=0)  # stitching
    m.cyl("gray", 0.06, 0.6, (0, 0.85, 3.1), seg=8)
    m.tube("seatbelt", [(-0.9, 0.5, 3.0), (-0.2, -0.3, 1.9), (0.8, -0.4, 1.15)], 0.06, seg=4)
    m.box("steel", (0.25, 0.08, 0.15), (0.85, -0.4, 1.12), bevel=0.02)
    m.squircle("darkgray", (2.2, 1.8, 0.6), (0, 0, 0.3), power=4)  # base
    for x, c, happy in ((-0.45, "maskgold", True), (0.5, "masksilver", False)):
        m.squircle(c, (0.75, 0.3, 0.95), (x, -0.2, 1.7), rot=(-10, 0, 0), power=2.2)
        for s in (-1, 1):
            if happy:
                m.tube("black", [(x + s * 0.18 - 0.1, -0.38, 1.85), (x + s * 0.18, -0.4, 1.92), (x + s * 0.18 + 0.1, -0.38, 1.85)], 0.025)
            else:
                m.tube("black", [(x + s * 0.18 - 0.1, -0.38, 1.92), (x + s * 0.18, -0.4, 1.85), (x + s * 0.18 + 0.1, -0.38, 1.92)], 0.025)
                m.blob("sky", (0.07, 0.04, 0.2), (x + s * 0.2, -0.4, 1.68))
        if happy:
            m.blob("mouth", (0.35, 0.08, 0.2), (x, -0.38, 1.45))
        else:
            m.tube("mouth", [(x - 0.15, -0.38, 1.4), (x, -0.4, 1.5), (x + 0.15, -0.38, 1.4)], 0.035)
    return m


def canon_event_web():
    m = Meme("CanonEventWeb")
    # a spider web strung in a hoop frame, one glowing red node where all threads meet: canon
    m.squircle("darkgray", (1.6, 0.8, 0.2), (0, 0.1, 0.1), power=4)
    m.cyl("darkgray", 0.06, 1.1, (0, 0.1, 0.7), seg=8)
    c = (0, 0, 2.7)
    m.torus("darkgray", 1.5, 0.07, c, rot=(90, 0, 0))
    for k in range(12):  # spokes
        a = k / 12 * math.tau
        m.tube("web", [c, (math.cos(a) * 1.48, 0, 2.7 + math.sin(a) * 1.48)], 0.018, seg=5)
    for r in (0.35, 0.65, 0.95, 1.25):  # spiral rings, sagging between spokes
        for k in range(12):
            a0, a1 = k / 12 * math.tau, (k + 1) / 12 * math.tau
            mid = (a0 + a1) / 2
            p0 = (math.cos(a0) * r, 0, 2.7 + math.sin(a0) * r)
            p1 = (math.cos(mid) * r * 0.93, 0, 2.7 + math.sin(mid) * r * 0.93)
            p2 = (math.cos(a1) * r, 0, 2.7 + math.sin(a1) * r)
            m.tube("web", [p0, p1, p2], 0.014, seg=5)
    m.blob("canonred", (0.35, 0.2, 0.35), c)
    m.torus("canonred", 0.32, 0.03, c, rot=(90, 0, 0))
    m.blob("black", (0.2, 0.15, 0.22), (0.6, -0.08, 3.4))  # a tiny spider
    for s in (-1, 1):
        for k in range(4):
            m.tube("black", [(0.6, -0.08, 3.4), (0.6 + s * 0.2, -0.1, 3.45 - k * 0.07), (0.6 + s * 0.28, -0.1, 3.3 - k * 0.07)], 0.012, seg=4)
    m.text("canonred", "CANON", (0, -0.15, 0.6), size=0.24, depth=0.03)
    return m


def boulder_eyebrow():
    m = Meme("BoulderEyebrow")
    # a big round boulder with a face, raising one eyebrow very, very slowly
    m.squircle("boulder", (3.0, 2.6, 3.3), (0, 0, 1.75), power=2.1)
    for k in range(7):  # cracks and lumps
        a = k * 0.9
        m.blob("rockgray", (0.6, 0.5, 0.4), (math.cos(a) * 1.35, math.sin(a) * 1.1, 0.9 + (k % 3) * 0.9))
    for s, raised in ((-1, False), (1, True)):
        m.eye((s * 0.5, -1.1, 2.3), (0.45, 0.2, 0.4), iris="black", lid="boulder", lid_drop=0.0 if raised else 0.45)
        if raised:
            m.box("darkgray", (0.6, 0.15, 0.15), (s * 0.5, -1.15, 2.85), rot=(0, -20, 0), bevel=0.06)
        else:
            m.box("darkgray", (0.6, 0.15, 0.15), (s * 0.5, -1.18, 2.58), rot=(0, 5, 0), bevel=0.06)
    m.blob("rockgray", (0.35, 0.3, 0.45), (0, -1.25, 1.9))
    m.tube("mouth", [(-0.35, -1.18, 1.45), (0.2, -1.2, 1.42), (0.35, -1.18, 1.5)], 0.04)
    m.squircle("green", (3.2, 2.6, 0.15), (0, 0, 0.07), power=3)
    return m


def pointing_suits():
    m = Meme("PointingSuits")
    # two heroes in identical bodysuits (one purple, one teal) pointing at each other
    m.squircle("darkgray", (4.2, 1.6, 0.15), (0, 0, 0.07), power=5)
    for x, suit, point in ((-1.0, "bodysuit1", 1), (1.0, "bodysuit2", -1)):
        p = mp.person(m, skin=suit, shirt=suit, pants=suit, shoes=suit, hair=None, hair_style="bald", x=x, sole=None,
                      build=0.85, head=0.9, expr="flat", face_kw={"brows": None, "nose": False, "iris": "white"},
                      arms={("r" if point > 0 else "l"): ((x + point * 0.75, -0.3, 3.0), (x + point * 1.3, -0.35, 3.2)),
                            ("l" if point > 0 else "r"): ((x - point * 0.65, -0.1, 2.35), (x - point * 0.45, -0.45, 2.05))})
        hc, hs = p["head"], p["head_size"]
        for s in (-1, 1):  # big white goggle eyes over the mask
            m.blob("white", (0.38, 0.12, 0.3), (hc.x + s * 0.24, hc.y - hs * 0.43, hc.z + 0.08), rot=(0, s * 15, 0))
        for k in range(4):  # suit seams
            m.torus("ink", 0.45, 0.012, (x, 0, 1.9 + k * 0.4), scale=(1, 0.66, 1))
    return m


def english_spanish_chair():
    m = Meme("EnglishSpanishChair")
    # a lone wooden chair under a hanging spotlight between two signs: choose wisely
    m.squircle("darkgray", (3.6, 2.2, 0.1), (0, 0, 0.05), power=4)
    m.squircle("wood", (1.1, 1.0, 0.12), (0, 0, 1.15), power=5)
    for sx in (-1, 1):
        for sy in (-1, 1):
            m.cyl("wood", 0.06, 1.1, (sx * 0.45, sy * 0.4, 0.6), seg=8)
        m.cyl("wood", 0.06, 1.3, (sx * 0.45, 0.45, 1.85), seg=8)
    for z in (1.85, 2.35):
        m.box("wood", (0.95, 0.08, 0.18), (0, 0.45, z), bevel=0.03)
    m.lathe("darkgray", [(0, 0.5), (0.5, 0.0), (0.55, -0.05), (0, -0.05)], (0, 0, 4.0))  # lamp shade
    m.cyl("darkgray", 0.02, 0.7, (0, 0, 4.85), seg=6)
    m.cyl("spotlight", 0.95, 0.03, (0, 0, 0.11), seg=40)  # pool of light on the floor
    for x, word, c in ((-1.45, "ENGLISH", "blue"), (1.45, "ESPANOL", "red")):
        m.cyl("darkgray", 0.04, 2.0, (x, 0.2, 1.0), seg=8)
        m.squircle("white", (1.1, 0.08, 0.5), (x, 0.15, 2.1), power=6)
        m.text(c, word, (x, 0.1, 2.1), size=0.2, depth=0.03)
    m.text("yellow", "?", (0, -0.2, 3.1), size=0.7, depth=0.08)
    return m


def a_hyuck_dog():
    m = Meme("AHyuckDog")
    # a lanky dog in a tall green hat and orange shirt, doubled over with a buck-toothed laugh
    p = mp.person(m, skin="dogtan", shirt="shirtorange", pants="navy", shoes="brown", hair=None, hair_style="bald",
                  build=0.85, height=1.05, expr="open", face_kw={"lids": 0.6, "nose": False, "brows": None},
                  arms={"l": ((-0.8, -0.35, 2.4), (-0.35, -0.6, 2.2)), "r": ((0.85, -0.3, 2.5), (0.4, -0.55, 2.45))})
    hc, hs = p["head"], p["head_size"]
    m.squircle("cream", (0.55, 0.7, 0.45), (hc.x, hc.y - hs * 0.5, hc.z - 0.15), power=2.3)  # long snout
    m.blob("black", (0.28, 0.2, 0.2), (hc.x, hc.y - hs * 0.85, hc.z - 0.05))
    m.box("teeth", (0.2, 0.06, 0.16), (hc.x, hc.y - hs * 0.75, hc.z - 0.38), bevel=0.02)  # buck teeth
    for s in (-1, 1):
        m.blob("black", (0.25, 0.2, 0.9), (hc.x + s * 0.55, hc.y + 0.1, hc.z - 0.2), rot=(0, s * 15, 0))  # floppy ears
    m.lathe("hatgreen", [(0.5, 0), (0.48, 0.25), (0.42, 0.7), (0.5, 0.75), (0, 0.78)], (hc.x, hc.y + 0.05, hc.z + hs * 0.38), rot=(-8, 0, 6))
    m.torus("hatgreen", 0.62, 0.06, (hc.x, hc.y + 0.05, hc.z + hs * 0.4), rot=(-8, 0, 6), scale=(1, 1, 0.5))
    m.text("orange", "A-HYUCK", (0, -0.6, 5.75), size=0.34, depth=0.05)
    return m


def no_scope_olympian():
    m = Meme("NoScopeOlympian")
    # a relaxed sharpshooter: one hand in his pocket, arm out finger-gun style, a bullseye target behind
    p = mp.person(m, skin="skin", shirt="white", pants="navy", shoes="black", hair="hairgray", hair_style="short",
                  turn=0, expr="flat", face_kw={"lids": 0.45},
                  arms={"r": ((1.05, -0.25, 3.15), (1.8, -0.35, 3.2)), "l": ((-0.65, 0.05, 2.35), (-0.45, -0.1, 1.9))})
    hc, hs = p["head"], p["head_size"]
    for s in (-1, 1):
        m.torus("black", 0.14, 0.03, (hc.x + s * 0.27, hc.y - hs * 0.43, hc.z + 0.06), rot=(90, 0, 0))  # glasses
    m.box("skin", (0.3, 0.07, 0.07), (2.0, -0.35, 3.22), bevel=0.03)  # finger gun
    m.box("skin", (0.07, 0.07, 0.15), (1.88, -0.35, 3.33), bevel=0.03)
    m.cyl("medal", 0.22, 0.05, (0, -0.4, 2.55), rot=(90, 0, 0), seg=24)  # silver medal
    m.tube("red", [(-0.2, -0.38, 3.1), (0, -0.4, 2.75)], 0.03, seg=4)
    m.tube("red", [(0.2, -0.38, 3.1), (0, -0.4, 2.75)], 0.03, seg=4)
    # target
    m.cyl("darkgray", 0.04, 2.4, (-1.5, 0.6, 1.2), seg=8)
    for r, c in ((0.75, "target"), (0.55, "black"), (0.35, "target"), (0.15, "red")):
        m.cyl(c, r, 0.06 + (0.75 - r) * 0.04, (-1.5, 0.5, 2.6), rot=(90, 0, 0), seg=32)
    m.blob("black", (0.06, 0.06, 0.06), (-1.5, 0.4, 2.6))
    return m


def pommel_horse_legend():
    m = Meme("PommelHorseLegend")
    # a gymnast in glasses mid-scissor on a pommel horse, legs flared wide
    m.squircle("mat", (4.0, 2.2, 0.15), (0, 0, 0.07), power=4)
    m.squircle("leather", (3.0, 0.75, 0.65), (0, 0, 1.8), power=3)  # the horse body
    for sx in (-1, 1):
        m.cyl("steel", 0.08, 1.5, (sx * 1.0, 0, 0.8), seg=10)
        m.cyl("darkgray", 0.3, 0.1, (sx * 1.0, 0, 0.12), seg=16)
        m.tube("cream", [(sx * 0.35, -0.2, 2.1), (sx * 0.35, -0.2, 2.4), (sx * 0.35, 0.2, 2.4), (sx * 0.35, 0.2, 2.1)], 0.06)  # pommels
    # gymnast supported on straight arms, body angled, legs split in a V
    m.tube("skin", [(-0.35, -0.2, 2.42), (-0.3, -0.1, 3.0)], 0.12)
    m.tube("skin", [(0.35, -0.2, 2.42), (0.3, -0.1, 3.0)], 0.12)
    m.squircle("red", (0.9, 0.55, 1.1), (0, -0.05, 3.15), rot=(0, 15, 0), power=2.6)  # leotard torso
    m.squircle("skin", (0.75, 0.7, 0.85), (-0.1, -0.1, 4.0), power=2.3)  # head
    m.squircle("hairbrown", (0.78, 0.72, 0.35), (-0.1, -0.05, 4.32), power=2.3)
    for s in (-1, 1):
        m.torus("black", 0.12, 0.025, (-0.1 + s * 0.17, -0.45, 4.05), rot=(90, 0, 0))
        m.blob("black", (0.06, 0.04, 0.06), (-0.1 + s * 0.17, -0.45, 4.05))
    m.tube("mouth", [(-0.22, -0.45, 3.8), (-0.1, -0.46, 3.77), (0.02, -0.45, 3.8)], 0.02)
    m.tube("white", [(0.2, 0, 2.7), (1.2, -0.3, 3.0), (2.0, -0.4, 3.2)], 0.13)  # leg out
    m.tube("white", [(-0.1, 0, 2.65), (-0.6, -0.2, 3.35), (-0.9, -0.3, 4.0)], 0.13)  # leg up
    for p in ((2.05, -0.4, 3.2), (-0.92, -0.3, 4.1)):
        m.blob("white", (0.22, 0.3, 0.22), p)
    return m


ALL = [peaches_turtle_king, kindergarten_mascot, cursed_cartoon_tape, laugh_cry_car_seat, canon_event_web, boulder_eyebrow,
       pointing_suits, english_spanish_chair, a_hyuck_dog, no_scope_olympian, pommel_horse_legend]
