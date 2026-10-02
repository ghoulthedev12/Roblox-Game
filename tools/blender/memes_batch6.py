"""Batch 6 of the meme sculptures: World 2.
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp

for _name, _c in [
    ("flask", (120, 200, 230)), ("flasklid", (240, 240, 240)), ("scrunchie", (255, 120, 170)), ("sticker1", (255, 200, 60)),
    ("sticker2", (120, 220, 140)), ("sticker3", (180, 120, 255)), ("cyber", (0, 230, 255)), ("chain", (150, 150, 160)),
    ("icecube", (200, 235, 255)), ("tank", (250, 250, 250)), ("lamppost", (60, 70, 80)), ("hedgehog", (40, 90, 220)),
    ("hedgebelly", (240, 200, 160)), ("sneakgreen", (60, 190, 90)), ("infant", (140, 190, 110)), ("robe", (160, 120, 80)),
    ("pod", (220, 225, 230)), ("steelpanel", (175, 180, 188)), ("crack", (40, 40, 50)), ("catwhite", (248, 248, 245)),
    ("salad", (110, 190, 70)), ("alien", (170, 180, 175)), ("eyeblack", (15, 15, 20)), ("feather", (252, 252, 255)),
    ("kombucha", (230, 160, 70)), ("label", (250, 240, 220)), ("pigpink", (250, 170, 190)), ("teal", (40, 170, 170)),
    ("sponge", (250, 225, 70)), ("spongehole", (200, 170, 40)), ("door", (150, 100, 60)), ("chair", (200, 60, 60)),
]:
    rgb(_name, *_c)


def frost_flask():
    m = Meme("FrostFlask")
    # a big insulated flask covered in stickers, scrunchies on the wrist strap, frosty breath
    prof = [(0, 0), (0.85, 0), (0.92, 0.1), (0.92, 2.9), (0.8, 3.2), (0.62, 3.35), (0.62, 3.5), (0, 3.5)]
    m.lathe("flask", prof, (0, 0, 0), seg=40)
    m.lathe("flasklid", [(0, 3.45), (0.66, 3.45), (0.68, 3.95), (0.55, 4.1), (0, 4.12)], (0, 0, 0), seg=40)
    m.torus("flasklid", 0.32, 0.08, (0, 0, 4.25), rot=(90, 0, 0))  # strap loop
    for k, c in enumerate(("scrunchie", "sticker3", "sticker2")):  # scrunchies stacked on the lid
        m.torus(c, 0.7, 0.13, (0, 0, 3.55 + k * 0.17), scale=(1, 1, 0.7))
    stickers = [("sticker1", -40, 2.4, "star"), ("sticker2", 10, 1.6, "circle"), ("sticker3", 45, 2.7, "heart"),
                ("scrunchie", -10, 0.9, "circle"), ("sky", 70, 1.3, "star"), ("orange", -70, 1.8, "circle")]
    for c, deg, z, kind in stickers:
        a = math.radians(deg - 90)
        x, y = math.cos(a) * 0.93, math.sin(a) * 0.93
        if kind == "star":
            pts = [(math.cos(math.pi / 2 + i * math.pi / 5) * (0.28 if i % 2 == 0 else 0.12),
                    math.sin(math.pi / 2 + i * math.pi / 5) * (0.28 if i % 2 == 0 else 0.12)) for i in range(10)]
        elif kind == "heart":
            pts = [(0.27 * math.sin(t) ** 3 * 1.0, 0.22 * math.cos(t) - 0.09 * math.cos(2 * t) - 0.04 * math.cos(3 * t))
                   for t in [i / 20 * math.tau for i in range(20)]]
        else:
            pts = [(math.cos(i / 16 * math.tau) * 0.22, math.sin(i / 16 * math.tau) * 0.22) for i in range(16)]
        m.relief(c, pts, 0.03, (x, y, z), rot=(0, 0, deg), bevel=0.0)
    m.text("white", "sksksk", (0, -0.94, 3.0), size=0.3, depth=0.03)
    for k in range(3):  # frosty puffs
        m.blob("ice", (0.35 + k * 0.1, 0.35, 0.3), (0.5 + k * 0.3, -0.3, 4.4 + k * 0.25))
    return m


def breathtaking_cyber_guy():
    m = Meme("BreathtakingCyberGuy")
    # a long-haired, bearded guy in a black suit pointing at the crowd, neon cyber lines on his arm
    p = mp.person(m, skin="skin", shirt="black", pants="black", shoes="black", hair="hairblack", hair_style="long",
                  expr="open", face_kw={"brow_tilt": -0.3, "teeth": True},
                  arms={"r": ((1.1, -0.6, 3.15), (1.45, -1.35, 3.3)), "l": ((-0.85, -0.1, 2.45), (-0.65, -0.45, 2.05))})
    hc, hs = p["head"], p["head_size"]
    m.blob("hairblack", (hs * 0.7, hs * 0.4, hs * 0.45), (hc.x, hc.y - hs * 0.3, hc.z - hs * 0.35))  # beard
    m.blob("mouth", (0.28, 0.08, 0.16), (hc.x, hc.y - hs * 0.48, hc.z - hs * 0.26))
    m.box("skin", (0.07, 0.3, 0.07), (1.5, -1.6, 3.32), rot=(0, 0, 0), bevel=0.03)  # pointing finger
    for k in range(4):  # glowing cyber lines along the pointing arm
        t = 0.2 + k * 0.2
        m.torus("cyber", 0.17, 0.02, (0.6 + t * 0.85, -0.2 - t * 1.1, 3.0 + t * 0.3), rot=(60, 0, 35))
    m.squircle("white", (0.3, 0.05, 0.55), (0, -0.37, 2.85), power=4)  # shirt under the suit
    # the crowd's spotlight on the stage
    m.cyl("ink", 1.4, 0.12, (0, 0.1, 0.06), seg=40)
    m.torus("cyber", 1.38, 0.04, (0, 0.1, 0.13))
    return m


def enslaved_moisture():
    m = Meme("EnslavedMoisture")
    # three sad ice cubes shackled together with heavy chains, a little puddle of tears
    m.squircle("water", (3.4, 2.0, 0.08), (0, 0, 0.04), power=2.6)
    cubes = [(-1.0, 0.1, 0.0, 10), (0.15, -0.2, 0.0, -8), (1.1, 0.25, 0.0, 15)]
    for x, y, z, r in cubes:
        m.box("icecube", (1.0, 1.0, 1.0), (x, y, 0.58), rot=(0, 0, r), bevel=0.14)
        m.box("white", (0.5, 0.05, 0.12), (x - 0.1, y - 0.52, 0.85), rot=(0, 0, r), bevel=0.03)  # shine
        for s in (-1, 1):
            m.blob("black", (0.1, 0.05, 0.14), (x + s * 0.18, y - 0.5, 0.65))
            m.blob("sky", (0.07, 0.05, 0.14), (x + s * 0.22, y - 0.51, 0.47))  # tears
        m.tube("black", [(x - 0.13, y - 0.51, 0.42), (x, y - 0.52, 0.47), (x + 0.13, y - 0.51, 0.42)], 0.02)  # frown
        m.torus("chain", 0.62, 0.06, (x, y, 0.35), rot=(0, 0, r), scale=(1, 1, 0.5))  # shackle
    for i in range(14):  # chain links between the cubes and up to a ball
        t = i / 13
        x = -1.0 + t * 2.1
        z = 0.35 + math.sin(t * math.pi) * -0.15 + 0.05
        m.torus("chain", 0.1, 0.03, (x, -0.55, z), rot=(0, 90 if i % 2 else 0, 0))
    m.blob("darkgray", (0.8, 0.8, 0.8), (1.6, -0.75, 0.4))  # ball and chain
    m.text("navy", "FREE THEM", (0, -0.3, 1.7), size=0.36, depth=0.05)
    return m


def ah_shucks():
    m = Meme("AhShucks")
    # a guy in a white tank top shrugging on a street corner: here we go again
    mp.person(m, skin="skin4", shirt="tank", pants="jeans", shoes="black", hair="hairblack", hair_style="fade",
              sleeves_short=True, expr="flat", face_kw={"brow_tilt": -0.5, "lids": 0.35},
              arms={"l": ((-0.95, -0.2, 2.15), (-1.25, -0.5, 2.5)), "r": ((0.95, -0.2, 2.15), (1.25, -0.5, 2.5))})
    m.cyl("lamppost", 0.09, 4.8, (1.6, 0.6, 2.4), seg=10)  # street lamp
    m.tube("lamppost", [(1.6, 0.6, 4.75), (1.3, 0.4, 5.0), (1.0, 0.2, 4.9)], 0.06)
    m.lathe("yellow", [(0, 0.0), (0.25, 0.05), (0.2, 0.25), (0, 0.3)], (1.0, 0.2, 4.6))
    m.squircle("gray", (3.8, 2.2, 0.15), (0, 0, 0.0), power=6)  # sidewalk
    m.relief("sticker2", [(0, 0), (0.7, 0), (0.7, 0.35), (0, 0.35)], 0.05, (-1.7, 0.8, 3.4))  # street sign
    m.cyl("lamppost", 0.04, 3.5, (-1.35, 0.8, 1.75), seg=8)
    return m


def uncanny_hedgehog():
    m = Meme("UncannyHedgehog")
    # the scary first-draft hedgehog: lanky legs, tiny wide-set eyes and a mouthful of human teeth
    for s in (-1, 1):
        m.tube("hedgehog", [(s * 0.3, 0, 2.0), (s * 0.35, -0.1, 1.1), (s * 0.35, 0, 0.35)], 0.13)  # long skinny legs
        m.squircle("sneakgreen", (0.45, 0.95, 0.4), (s * 0.38, -0.2, 0.2), power=2.6)
        m.squircle("white", (0.47, 0.3, 0.12), (s * 0.38, -0.35, 0.32), power=3)
        m.tube("hedgehog", [(s * 0.5, 0, 3.2), (s * 0.85, -0.2, 2.6), (s * 0.9, -0.35, 2.1)], 0.12)  # arms
        m.blob("hedgehog", (0.3, 0.28, 0.34), (s * 0.9, -0.38, 2.0))  # bare hands
    m.squircle("hedgehog", (1.1, 0.8, 1.3), (0, 0, 2.6), power=2.4)  # thin torso
    m.blob("hedgebelly", (0.7, 0.3, 0.9), (0, -0.35, 2.5))
    m.squircle("hedgehog", (1.5, 1.35, 1.35), (0, 0.05, 3.8), power=2.4)  # head
    for k in range(6):  # quills sweeping back
        a = math.radians(-50 + k * 20)
        m.cyl("hedgehog", 0.3, 1.5, (math.sin(a) * 0.45, 0.85, 3.9 + math.cos(a) * 0.35),
              rot=(-75 + abs(k - 2.5) * 6, 0, math.degrees(a) * -0.3), radius2=0.0, seg=12)
    m.blob("hedgebelly", (1.0, 0.5, 0.6), (0, -0.55, 3.45))  # muzzle
    m.blob("black", (0.18, 0.12, 0.14), (0, -0.82, 3.6))
    for s in (-1, 1):  # two tiny eyes, set far apart
        m.eye((s * 0.42, -0.58, 3.95), (0.26, 0.14, 0.3), iris="sneakgreen", look=(s * 0.3, 0))
        mp.ear(m, "hedgehog", (s * 0.4, 0.2, 4.35), (s * 0.55, 0.25, 4.85), width=0.25, inner="hedgebelly", thick=0.1)
    m.blob("mouth", (0.6, 0.12, 0.25), (0, -0.78, 3.28))
    for k in range(7):  # the human teeth
        m.box("teeth", (0.075, 0.05, 0.12), (-0.24 + k * 0.08, -0.84, 3.32), bevel=0.02)
    return m


def space_infant():
    m = Meme("SpaceInfant")
    # a tiny green infant with enormous ears, swaddled in a robe, peeking out of a hover pod
    m.lathe("pod", [(0, 0.9), (0.9, 1.0), (1.35, 1.4), (1.45, 1.85), (1.38, 1.9), (0.0, 1.9)], (0, 0, 0), seg=40)
    m.torus("darkgray", 1.42, 0.06, (0, 0, 1.88))
    m.cyl("cyber", 0.5, 0.08, (0, 0, 0.88), seg=24)  # hover glow
    m.cyl("darkgray", 0.25, 0.7, (0, 0, 0.45), seg=16, radius2=0.08)
    m.squircle("steelpanel", (1.3, 1.1, 1.3), (0, 0, 2.3), power=2.2)  # little silver space suit
    m.torus("cyber", 0.5, 0.12, (0, 0, 2.95), scale=(1, 0.9, 0.7))  # glowing collar ring
    m.blob("cyber", (0.3, 0.1, 0.3), (0, -0.55, 2.4))  # chest light
    m.blob("infant", (1.3, 1.15, 1.1), (0, -0.05, 3.5))  # head
    for s in (-1, 1):
        m.blob("infant", (1.5, 0.3, 0.55), (s * 1.15, 0.1, 3.6), rot=(0, s * -12, s * 10))  # huge ears
        m.blob("pink", (1.1, 0.12, 0.32), (s * 1.18, 0.0, 3.6), rot=(0, s * -12, s * 10))
        m.eye((s * 0.27, -0.52, 3.55), (0.36, 0.2, 0.36), iris="eyeblack", look=(0, 0.1))
        m.tube("steelpanel", [(s * 0.55, -0.1, 2.6), (s * 0.5, -0.5, 2.3), (s * 0.25, -0.6, 2.45)], 0.12)  # arms
        m.blob("infant", (0.18, 0.18, 0.18), (s * 0.22, -0.66, 2.48))
    m.blob("infant", (0.1, 0.08, 0.06), (0, -0.6, 3.38))  # tiny nose
    m.tube("mouth", [(-0.08, -0.56, 3.25), (0, -0.57, 3.23), (0.08, -0.56, 3.25)], 0.015)
    m.lathe("gray", [(0, 0), (0.12, 0), (0.16, 0.18), (0, 0.18)], (0, -0.7, 2.42))  # a tiny soup cup
    return m


def me_and_the_crew():
    m = Meme("MeAndTheCrew")
    # four friends striding toward adventure, side by side on a strip of road
    m.squircle("gray", (4.2, 1.6, 0.1), (0, 0, 0.05), power=6)
    for k in range(4):
        m.box("yellow", (0.35, 0.12, 0.02), (-1.6 + k * 1.05, 0.55, 0.11), bevel=0)
    crew = [("skin", "red", "jeans", "hairbrown", "short"), ("skin3", "sticker2", "black", "hairblack", "curly"),
            ("skin2", "sky", "khaki", "hairblond", "long"), ("skin4", "purple", "jeans", "hairblack", "cap")]
    for k, (skin, shirt, pants, hair, style) in enumerate(crew):
        x = -1.5 + k * 1.0
        mp.person(m, skin=skin, shirt=shirt, pants=pants, hair=hair, hair_style=style, height=0.62, build=0.62, head=0.62,
                  x=x, y=-0.05 * k, expr="smile",
                  legs={-1: ((-0.17, -0.25, 0.55), (-0.18, -0.4, 0.1)), 1: ((0.17, 0.12, 0.5), (0.18, 0.3, 0.1))},
                  arms={"l": ((-0.42, 0.18, 1.75), (-0.45, 0.3, 1.35)), "r": ((0.42, -0.2, 1.75), (0.45, -0.35, 1.35))})
    return m


def cyber_wedge_truck():
    m = Meme("CyberWedgeTruck")
    # an angular steel wedge of a truck, one window cracked from the "unbreakable" demo
    side = [(-2.0, 0.55), (-2.0, 1.15), (-0.2, 2.0), (2.0, 1.45), (2.0, 0.55)]
    m.relief("steelpanel", side, 1.9, (0, 0, 0), bevel=0.04)
    m.relief("ink", [(-1.5, 1.3), (-0.25, 1.87), (0.9, 1.6), (0.9, 1.25)], 1.92, (0, 0, 0), bevel=0)  # window band
    for x in (-1.3, 1.3):
        for s in (-1, 1):
            m.cyl("tire", 0.48, 0.4, (x, s * 0.85, 0.48), rot=(90, 0, 0), seg=28)
            m.cyl("darkgray", 0.3, 0.42, (x, s * 0.85, 0.48), rot=(90, 0, 0), seg=6)
    m.box("white", (0.05, 1.6, 0.06), (-2.02, 0, 1.12), bevel=0)  # light bar
    m.box("red", (0.05, 1.6, 0.06), (2.02, 0, 1.4), bevel=0)
    # cracks spidering across the side window
    c = (0.2, -0.97, 1.5)
    for k in range(7):
        a = k / 7 * math.tau
        m.tube("white", [c, (c[0] + math.cos(a) * 0.25, c[1], c[2] + math.sin(a) * 0.15),
                         (c[0] + math.cos(a + 0.2) * 0.45, c[1], c[2] + math.sin(a + 0.2) * 0.22)], 0.015, seg=6)
    m.blob("darkgray", (0.25, 0.25, 0.25), (0.45, -1.35, 0.13))  # the steel ball that did it
    return m


def yelled_at_cat():
    m = Meme("YelledAtCat")
    # a white cat at a dinner table behind a plate of salad, scrunched up and confused
    m.squircle("white", (3.2, 1.6, 0.1), (0, -0.2, 1.4), power=6)  # table
    for sx in (-1, 1):
        for sy in (-1, 1):
            m.cyl("wood", 0.06, 1.4, (sx * 1.4, -0.2 + sy * 0.6, 0.7), seg=8)
    m.cyl("white", 0.5, 0.06, (0, -0.55, 1.48), seg=32)  # plate
    for k in range(9):
        a = k / 9 * math.tau
        m.blob("salad", (0.3, 0.25, 0.12), (math.cos(a) * 0.25, -0.55 + math.sin(a) * 0.25, 1.58))
    m.blob("red", (0.12, 0.12, 0.12), (0.1, -0.6, 1.65))
    m.squircle("white", (1.0, 0.9, 1.6), (0, 0.4, 2.0), power=2.8)  # chair back
    # the cat
    m.squircle("catwhite", (1.3, 1.1, 1.0), (0, 0.15, 1.95), power=2.4)  # body behind the table
    m.squircle("catwhite", (1.55, 1.25, 1.2), (0, -0.05, 2.85), power=2.5)  # head
    for s in (-1, 1):
        mp.ear(m, "catwhite", (s * 0.45, 0.0, 3.25), (s * 0.6, 0.05, 3.85), width=0.3, inner="pink", thick=0.1)
        m.eye((s * 0.3, -0.62, 2.95), (0.3, 0.16, 0.24), iris="sticker2", pupil="black", lid="catwhite", lid_drop=0.4)
        m.box("gray", (0.28, 0.05, 0.06), (s * 0.3, -0.68, 3.15), rot=(0, s * 20, 0), bevel=0.02)  # scrunched brows
        for k in range(3):
            m.box("gray", (0.4, 0.02, 0.02), (s * 0.6, -0.6, 2.65 + k * 0.07), rot=(0, s * (k - 1) * 12, 0), bevel=0)  # whiskers
    m.blob("pink", (0.12, 0.08, 0.08), (0, -0.7, 2.75))
    m.tube("gray", [(-0.12, -0.68, 2.6), (0, -0.7, 2.65), (0.12, -0.68, 2.6)], 0.02)
    return m


def raid_alien():
    m = Meme("RaidAlien")
    # a gray alien mid-run, leaning hard forward, both arms straight back
    lean = 30
    for s, (knee, foot) in ((-1, ((-0.25, -0.6, 1.0), (-0.25, -0.75, 0.15))), (1, ((0.25, 0.45, 0.85), (0.25, 0.9, 0.35)))):
        m.tube("alien", [(s * 0.22, 0, 1.6), knee, foot], 0.12)
        m.squircle("alien", (0.25, 0.5, 0.15), foot, power=2.5)
    m.squircle("alien", (0.8, 0.6, 1.2), (0, -0.3, 2.2), rot=(lean, 0, 0), power=2.4)  # body tipped forward
    for s in (-1, 1):
        m.tube("alien", [(s * 0.42, -0.45, 2.65), (s * 0.5, 0.3, 2.4), (s * 0.5, 0.95, 2.35)], 0.09)  # arms back
        m.blob("alien", (0.16, 0.25, 0.1), (s * 0.5, 1.08, 2.35))
    m.cyl("alien", 0.12, 0.3, (0, -0.55, 2.9), rot=(lean, 0, 0), seg=10)
    m.blob("alien", (1.2, 1.1, 1.3), (0, -0.85, 3.45))  # big head
    for s in (-1, 1):
        m.blob("eyeblack", (0.4, 0.22, 0.24), (s * 0.27, -1.35, 3.45), rot=(0, s * -25, 0))  # almond eyes
        m.blob("white", (0.07, 0.05, 0.05), (s * 0.27 + 0.05, -1.45, 3.5))
    m.tube("mouth", [(-0.08, -1.39, 3.05), (0.08, -1.39, 3.05)], 0.015)
    for k in range(3):  # speed lines
        m.box("white", (0.05, 0.9, 0.05), (-0.9 + k * 0.1, 0.8, 2.0 + k * 0.5), bevel=0.02)
    m.squircle("khaki", (2.6, 2.4, 0.1), (0, 0, 0.05), power=3)  # desert
    m.cyl("pistachio", 0.12, 0.8, (1.2, 0.6, 0.45), seg=10)  # a little cactus
    m.tube("pistachio", [(1.2, 0.6, 0.55), (1.45, 0.6, 0.6), (1.45, 0.6, 0.85)], 0.07)
    return m


def angel_wing_dancer():
    m = Meme("AngelWingDancer")
    # a dancer frozen mid-move, one knee up, arms flung out, a pair of white wings behind
    p = mp.person(m, skin="skin2", shirt="white", pants="white", shoes="sneaker", hair="hairblack", hair_style="bun",
                  expr="smile", face_kw={"lids": 0.5},
                  legs={-1: ((-0.25, -0.05, 0.9), (-0.28, 0.0, 0.16)), 1: ((0.4, -0.7, 1.5), (0.35, -0.35, 0.95))},
                  arms={"l": ((-1.15, -0.1, 3.05), (-1.75, -0.2, 3.5)), "r": ((1.1, -0.1, 2.85), (1.6, -0.25, 2.4))})
    for s in (-1, 1):  # wings: rows of feathers fanning out
        for row in range(3):
            for k in range(6 - row):
                a = math.radians(15 + k * 14)
                L = 1.6 - row * 0.4 - k * 0.08
                x = s * (0.3 + math.cos(a) * L * 0.6)
                z = 3.0 + math.sin(a) * L * 0.8 - row * 0.15
                m.blob("feather", (0.9 - row * 0.15, 0.08, 0.28), (x, 0.55 + row * 0.03, z), rot=(0, -s * (math.degrees(a) - 10), 0))
    m.torus("gold", 0.38, 0.04, (p["head"].x, p["head"].y + 0.05, p["head"].z + 0.95), rot=(10, 0, 0))  # halo
    m.cyl("lilac", 1.1, 0.1, (0, 0, 0.05), seg=40)
    return m


def kombucha_disgust():
    m = Meme("KombuchaDisgust")
    # a kombucha bottle whose label face scrunches up in disgust after one sip
    prof = [(0, 0), (0.8, 0), (0.85, 0.1), (0.85, 2.3), (0.6, 2.9), (0.3, 3.3), (0.3, 3.7), (0, 3.7)]
    m.lathe("kombucha", prof, (0, 0, 0), seg=40)
    m.lathe("black", [(0, 3.65), (0.33, 3.65), (0.33, 3.95), (0, 3.98)], (0, 0, 0))
    m.cyl("label", 0.87, 1.4, (0, 0, 1.25), seg=40)
    for k in range(5):  # floaty bits
        m.blob("cream", (0.12, 0.12, 0.08), (math.cos(k) * 0.5, math.sin(k) * 0.5, 0.25 + k * 0.08))
    # the disgusted face on the label
    y = -0.88
    for s in (-1, 1):
        m.tube("black", [(s * 0.45, y, 1.55), (s * 0.25, y - 0.02, 1.45), (s * 0.05, y, 1.6)], 0.035)  # squeezed shut eyes
        m.box("black", (0.32, 0.04, 0.06), (s * 0.28, y, 1.78), rot=(0, -s * 25, 0), bevel=0.02)
        for k in range(2):
            m.box("darkred", (0.12, 0.03, 0.03), (s * (0.55 + k * 0.06), y + 0.02, 1.3 + k * 0.07), rot=(0, s * 30, 0), bevel=0)
    m.blob("darkred", (0.22, 0.04, 0.12), (0, y, 1.38))  # scrunched nose
    m.tube("mouth", [(-0.3, y, 0.95), (-0.15, y - 0.02, 1.05), (0, y, 0.95), (0.15, y - 0.02, 1.05), (0.3, y, 0.95)], 0.035)
    m.blob("tongue", (0.18, 0.08, 0.16), (0.05, y - 0.03, 0.88))
    m.text("darkbrown", "KOMBUCHA", (0, y, 0.68), size=0.17, depth=0.02)
    return m


def double_take_blink():
    m = Meme("DoubleTakeBlink")
    # a marble-white-and-color bust: a bearded guy mid-blink, eyebrows up, glancing to the side
    m.lathe("marble", [(0, 0), (0.95, 0), (0.95, 0.35), (0.75, 0.45), (0.7, 0.8), (0, 0.8)], (0, 0, 0), seg=40)  # plinth
    m.squircle("shirtwhite", (2.2, 1.2, 1.4), (0, 0, 1.45), power=2.4)  # shoulders
    m.squircle("sweater", (2.25, 1.25, 0.9), (0, 0, 1.25), power=2.6)
    m.cyl("skin", 0.3, 0.45, (0, 0, 2.2), seg=16)
    hc = (0, -0.05, 3.05)
    m.squircle("skin", (1.25, 1.2, 1.45), hc, power=2.4)
    m.squircle("hairblond", (1.3, 1.25, 0.6), (0, 0.0, 3.6), power=2.4)
    m.blob("hairblond", (1.0, 0.7, 0.55), (0, -0.25, 2.6))  # beard
    for s in (-1, 1):
        m.blob("skin", (0.14, 0.22, 0.3), (s * 0.62, 0.0, 3.05))
        # eyes caught mid-blink: half shut, looking to the side
        m.eye((s * 0.28, -0.55, 3.15), (0.32, 0.16, 0.32), iris="sky", pupil="black", look=(-0.6, 0), lid="skin", lid_drop=0.5)
        m.box("hairblond", (0.32, 0.06, 0.07), (s * 0.28, -0.6, 3.48), rot=(0, -s * 12, 0), bevel=0.02)  # raised brows
    m.blob("skin", (0.18, 0.18, 0.22), (0, -0.66, 2.95))
    m.tube("mouth", [(-0.2, -0.6, 2.72), (0.15, -0.61, 2.7), (0.22, -0.6, 2.74)], 0.025)
    return m


def tall_pink_piglet():
    m = Meme("TallPinkPiglet")
    # a pink piglet stretched absurdly tall: a teal striped jumper on a neck that never ends
    for s in (-1, 1):
        m.tube("pigpink", [(s * 0.22, 0, 0.9), (s * 0.24, -0.05, 0.25)], 0.12)
        m.squircle("pigpink", (0.3, 0.42, 0.22), (s * 0.24, -0.08, 0.11), power=2.5)
    m.squircle("teal", (0.95, 0.75, 1.4), (0, 0, 1.55), power=2.4)  # jumper
    for k in range(4):
        m.torus("sticker2", 0.43, 0.04, (0, 0, 1.0 + k * 0.33), scale=(1, 0.78, 1))
    for s in (-1, 1):
        m.tube("pigpink", [(s * 0.45, 0, 2.05), (s * 0.6, -0.1, 1.6), (s * 0.55, -0.2, 1.25)], 0.09)
    m.tube("pigpink", [(0, 0, 2.2), (0, 0, 3.0), (0.05, 0, 3.6)], 0.17, seg=16)  # the long neck
    m.squircle("pigpink", (0.85, 0.75, 0.8), (0.05, -0.05, 4.0), power=2.3)  # head
    m.squircle("pigpink", (0.38, 0.25, 0.28), (0.05, -0.48, 3.9), power=2.5)  # snout
    for s in (-1, 1):
        m.blob("darkred", (0.06, 0.04, 0.08), (0.05 + s * 0.08, -0.6, 3.9))
        m.eye((0.05 + s * 0.2, -0.38, 4.12), (0.16, 0.1, 0.2), iris="black")
        mp.ear(m, "pigpink", (0.05 + s * 0.28, 0, 4.3), (0.05 + s * 0.45, -0.05, 4.65), width=0.17, inner="hippopink", thick=0.06)
    m.tube("mouth", [(-0.07, -0.42, 3.73), (0.05, -0.44, 3.7), (0.17, -0.42, 3.73)], 0.015)
    # a measuring stick beside her
    m.box("yellow", (0.2, 0.06, 4.6), (0.85, 0.1, 2.3), bevel=0.01)
    for k in range(10):
        m.box("black", (0.1 if k % 2 else 0.18, 0.07, 0.02), (0.8 if k % 2 else 0.78, 0.07, 0.3 + k * 0.42), bevel=0)
    return m


def sponge_leaving():
    m = Meme("SpongeLeaving")
    # a square, holey yellow sponge getting up out of a chair: aight, heading out
    m.squircle("chair", (1.6, 1.3, 0.4), (0.2, 0.4, 0.9), power=3)  # armchair seat
    m.squircle("chair", (1.6, 0.4, 1.6), (0.2, 1.0, 1.6), power=3)
    for s in (-1, 1):
        m.squircle("chair", (0.35, 1.3, 0.75), (0.2 + s * 0.85, 0.4, 1.2), power=3)
    for sx in (-1, 1):
        for sy in (-1, 1):
            m.cyl("darkbrown", 0.06, 0.7, (0.2 + sx * 0.7, 0.4 + sy * 0.5, 0.35), seg=8)
    # the sponge, half up, leaning toward the exit
    m.squircle("sponge", (1.25, 0.6, 1.45), (-0.55, -0.35, 2.15), rot=(0, -10, 0), power=5)
    for k, (dx, dz, r) in enumerate([(-0.35, 0.4, 0.1), (0.3, 0.5, 0.08), (0.25, -0.2, 0.12), (-0.3, -0.45, 0.09), (0.0, 0.05, 0.06)]):
        m.blob("spongehole", (r * 2, 0.06, r * 2), (-0.55 + dx, -0.66, 2.15 + dz))
    for s in (-1, 1):
        m.eye((-0.55 + s * 0.22, -0.68, 2.4), (0.34, 0.12, 0.36), iris="sky", pupil="black", look=(-0.5, 0), lid="sponge", lid_drop=0.35)
    m.tube("mouth", [(-0.85, -0.66, 1.95), (-0.55, -0.68, 1.88), (-0.3, -0.66, 1.98)], 0.03)
    m.squircle("navy", (1.27, 0.62, 0.35), (-0.6, -0.35, 1.3), rot=(0, -10, 0), power=5)  # plain shorts
    for s in (-1, 1):
        m.tube("sponge", [(-0.6 + s * 0.3, -0.35, 1.15), (-0.75 + s * 0.3, -0.55, 0.65), (-0.8 + s * 0.3, -0.45, 0.2)], 0.07)
        m.squircle("black", (0.25, 0.42, 0.18), (-0.8 + s * 0.3, -0.55, 0.1), power=2.5)
        m.tube("sponge", [(-0.55 + s * 0.6, -0.35, 2.3), (-0.6 + s * 0.85, -0.5, 1.8), (-0.4 + s * 0.6, -0.3, 1.55)], 0.06)  # arms push off
    # the open door he's heading for
    m.squircle("door", (1.0, 0.12, 2.6), (-2.0, 0.2, 1.3), rot=(0, 0, -35), power=6)
    m.blob("gold", (0.1, 0.1, 0.1), (-1.7, -0.05, 1.3))
    return m


ALL = [frost_flask, breathtaking_cyber_guy, enslaved_moisture, ah_shucks, uncanny_hedgehog, space_infant, me_and_the_crew,
       cyber_wedge_truck, yelled_at_cat, raid_alien, angel_wing_dancer, kombucha_disgust, double_take_blink,
       tall_pink_piglet, sponge_leaving]
