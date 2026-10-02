"""Batch 3 of the meme sculptures (remodeled in the full meme remodel, same ids).
Conventions: z is up, the model faces -y, about 4-5 studs tall. Original parody designs."""
import math

from memekit import Meme
import memeparts as mp


def coffin_dance():
    m = Meme("FrozenCoffinDance")
    # four pallbearers in suits and shades carrying a coffin on their shoulders, gliding on ice
    m.squircle("ice", (4.0, 2.2, 0.15), (0, 0, 0.07), power=3)
    for k in range(5):
        m.box("white", (0.8, 0.02, 0.02), (-1.5 + k * 0.75, -0.6 + (k % 2) * 1.0, 0.15), rot=(0, 0, 20), bevel=0)  # skate marks
    for k, (x, y) in enumerate(((-1.25, -0.45), (1.25, -0.45), (-1.25, 0.45), (1.25, 0.45))):
        side = 1 if x > 0 else -1
        mp.person(m, skin="skin4", shirt="suit", pants="suit", shoes="black", hair="hairblack", hair_style="fade",
                  height=0.7, build=0.68, head=0.62, x=x, y=y, expr="smile", sole=None,
                  face_kw={"brows": None},
                  # (arm and leg points are relative to each dancer)
                  arms={("l" if side > 0 else "r"): ((-side * 0.45, 0.0, 2.5), (-side * 0.35, 0.0, 3.15)),  # inner hand up on the coffin
                        ("r" if side > 0 else "l"): ((side * 0.5, -0.1, 1.55), (side * 0.55, -0.25, 1.15))},
                  legs={-1: ((-0.2, -0.15, 0.6), (-0.22, -0.1, 0.12)), 1: ((0.2, 0.1, 0.62), (0.22, 0.12, 0.12))})
    for k, (x, y) in enumerate(((-1.25, -0.45), (1.25, -0.45))):
        m.squircle("black", (0.55, 0.1, 0.12), (x, y - 0.33, 2.63), power=4)  # shades on the front two
    m.squircle("coffin", (3.4, 1.4, 0.55), (0, 0, 3.45), power=5)  # the coffin
    m.squircle("darkbrown", (3.45, 1.45, 0.12), (0, 0, 3.75), power=5)  # lid
    for s in (-1, 1):
        m.box("gold", (0.5, 0.06, 0.1), (s * 1.0, -0.72, 3.45), bevel=0.02)  # handles
    m.relief("gold", [(-0.06, -0.25), (0.06, -0.25), (0.06, 0.05), (0.2, 0.05), (0.2, 0.15), (0.06, 0.15), (0.06, 0.25), (-0.06, 0.25),
                      (-0.06, 0.15), (-0.2, 0.15), (-0.2, 0.05), (-0.06, 0.05)], 0.03, (0, 0, 3.82), rot=(90, 0, 0), bevel=0)
    return m


def big_mittens_chair():
    m = Meme("BigMittensChair")
    # a folding chair with a pair of huge cozy knitted mittens resting on it, legs crossed
    for sx in (-1, 1):  # folding chair frame
        m.cyl("darkgray", 0.04, 2.0, (sx * 0.55, 0.0, 0.95), rot=(18, 0, 0), seg=8)
        m.cyl("darkgray", 0.04, 2.6, (sx * 0.55, 0.05, 1.3), rot=(-18, 0, 0), seg=8)
    m.squircle("wood", (1.25, 1.0, 0.1), (0, 0.0, 1.0), power=6)
    m.squircle("wood", (1.25, 0.12, 0.6), (0, 0.45, 2.15), rot=(-12, 0, 0), power=6)
    m.squircle("jeans", (1.2, 0.9, 0.35), (0, -0.05, 1.25), power=3)  # folded coat on the seat
    for s in (-1, 1):
        x = s * 0.4
        m.squircle("mitten", (0.7, 0.55, 0.95), (x, -0.3, 1.85), rot=(0, s * 12, 0), power=2.3)  # mittens
        m.squircle("mitten", (0.25, 0.3, 0.4), (x + s * 0.38, -0.4, 2.05), rot=(0, s * 35, 0), power=2.3)  # thumbs
        m.squircle("cream", (0.75, 0.6, 0.3), (x, -0.25, 1.35), power=3)  # cuffs
        for k in range(3):
            m.torus("envelope", 0.32, 0.02, (x, -0.3, 1.6 + k * 0.22), rot=(0, s * 12, 0), scale=(1, 0.8, 1))  # knit rows
        for k in range(4):
            m.blob("red", (0.08, 0.05, 0.08), (x - 0.15 + k * 0.1, -0.58, 1.95 + (k % 2) * 0.12))  # knit dots
    for s in (-1, 1):  # crossed legs in winter boots
        m.tube("jeans", [(s * 0.3, -0.4, 1.15), (s * -0.05 - 0.1, -0.95, 1.0), (s * -0.2, -1.1, 0.4)], 0.17)
        m.squircle("brown", (0.35, 0.55, 0.3), (s * -0.2, -1.2, 0.2), power=2.5)
    return m


def sea_shanty_mug():
    m = Meme("SeaShantyMug")
    # a foaming wooden tankard with a little whaling ship sailing on its head of foam
    m.lathe("wood", [(0, 0), (0.95, 0), (1.0, 0.15), (0.95, 2.1), (1.0, 2.25), (0, 2.25)], (0, 0, 0), seg=40)
    for k in range(12):  # staves
        a = k / 12 * math.tau
        m.box("darkbrown", (0.04, 0.04, 2.1), (math.cos(a) * 0.98, math.sin(a) * 0.98, 1.1), rot=(0, 0, math.degrees(a)), bevel=0)
    for z in (0.35, 1.9):
        m.torus("darkgray", 1.0, 0.07, (0, 0, z))
    m.tube("wood", [(0.95, 0, 1.75), (1.55, 0, 1.6), (1.6, 0, 0.75), (0.95, 0, 0.6)], 0.13)  # handle
    for k in range(9):  # spilling foam
        a = k / 9 * math.tau
        m.blob("foam", (0.75, 0.75, 0.55), (math.cos(a) * 0.55, math.sin(a) * 0.55, 2.35))
    m.blob("foam", (0.4, 0.3, 0.7), (-0.9, -0.4, 1.9))  # drip
    # the little whaling ship riding the foam
    m.squircle("darkbrown", (1.1, 0.45, 0.35), (0, 0, 2.85), power=2.5)
    m.cyl("wood", 0.03, 1.1, (0, 0, 3.45), seg=6)
    m.relief("white", [(0, 0), (0.55, 0), (0.45, 0.7), (0, 0.8)], 0.03, (0.02, 0, 3.05))
    m.relief("red", [(0, 0), (0.25, 0.08), (0, 0.16)], 0.02, (0, 0, 3.98))
    for k in range(3):
        m.blob("black", (0.18, 0.08, 0.14), (-1.3 + k * 0.4, -0.3, 3.0 + k * 0.25), rot=(0, -20, 0))
        m.cyl("black", 0.02, 0.4, (-1.22 + k * 0.4, -0.3, 3.2 + k * 0.25), seg=6)
    return m


def bing_chilling_cone():
    m = Meme("BingChillingCone")
    # a waffle cone with three scoops (mint, vanilla, chocolate), cold mist, on a little stand
    m.lathe("darkgray", [(0, 0), (0.7, 0), (0.7, 0.12), (0.25, 0.22), (0.2, 0.7), (0.4, 0.8), (0, 0.8)], (0, 0, 0), seg=32)
    m.lathe("waffle", [(0, 0.7), (0.15, 0.75), (0.85, 3.0), (0.9, 3.05), (0, 3.05)], (0, 0, 0), seg=32)  # cone
    for k in range(7):  # waffle grid
        m.tube("tan", [(math.cos(k) * 0.3, math.sin(k) * 0.3, 1.2), (math.cos(k + 1.2) * 0.8, math.sin(k + 1.2) * 0.8, 2.8)], 0.02, seg=4)
        m.tube("tan", [(math.cos(k) * 0.3, math.sin(k) * 0.3, 1.2), (math.cos(k - 1.2) * 0.8, math.sin(k - 1.2) * 0.8, 2.8)], 0.02, seg=4)
    for k, (c, z, r) in enumerate((("mint", 3.3, 0.95), ("cream", 3.95, 0.82), ("chocolate", 4.5, 0.7))):
        m.blob(c, (r * 2, r * 2, r * 1.6), (0, 0, z))
        for j in range(8):
            a = j / 8 * math.tau
            m.blob(c, (0.3, 0.3, 0.25), (math.cos(a) * r * 0.95, math.sin(a) * r * 0.95, z - r * 0.55))  # drippy rim
    for k in range(10):
        a = k * 2.4
        m.blob("chocolate", (0.1, 0.06, 0.06), (math.cos(a) * 0.85, math.sin(a) * 0.85, 3.3 + (k % 3) * 0.12))  # chips
    for k in range(4):  # cold mist
        m.blob("ice", (0.3, 0.3, 0.3), (1.0 + (k % 2) * 0.2, -0.2, 4.0 + k * 0.3))
    return m


def its_corn_cob():
    m = Meme("ItsCornCob")
    # a big juicy corn cob standing up in its husk, kernels in neat rows, glistening with butter
    m.squircle("darkgray", (1.6, 1.6, 0.25), (0, 0, 0.12), power=4)
    m.lathe("corn", [(0, 0.3), (0.45, 0.35), (0.62, 1.0), (0.66, 2.5), (0.55, 3.6), (0.3, 4.1), (0, 4.2)], (0, 0, 0), seg=24)
    for row in range(14):  # kernel rows
        a = row / 14 * math.tau
        for k in range(14):
            z = 0.55 + k * 0.25
            r = 0.62 if 1.0 < z < 3.0 else 0.55
            m.blob("yellow", (0.16, 0.14, 0.18), (math.cos(a) * r, math.sin(a) * r, z))
    for k in range(5):  # husk leaves peeling down
        a = k / 5 * math.tau + 0.3
        m.relief("husk", [(-0.25, 0), (0.25, 0), (0.15, 1.6), (0, 2.1), (-0.15, 1.5)], 0.06, (math.cos(a) * 0.65, math.sin(a) * 0.65, 0.3),
                 rot=(0, 0, math.degrees(a) + 90), bevel=0.02)
    for k in range(4):  # butter drips
        m.blob("cheese", (0.15, 0.1, 0.35), (math.cos(k * 1.7) * 0.66, math.sin(k * 1.7) * 0.66, 3.4 - k * 0.3))
    m.blob("cheese", (0.6, 0.45, 0.15), (0, 0, 4.15))  # butter pat on top
    return m


def mauling_time_cape():
    m = Meme("MaulingTimeVampire")
    # a pale vampire flinging open a huge bat-wing cape, fangs out: it's mauling time
    p = mp.person(m, skin="marble", shirt="black", pants="black", shoes="black", hair="hairblack", hair_style="slick",
                  expr="open", face_kw={"brow_tilt": 0.6, "iris": "red", "teeth": True},
                  arms={"l": ((-1.0, -0.1, 3.0), (-1.65, -0.2, 3.5)), "r": ((1.0, -0.1, 3.0), (1.65, -0.2, 3.5))})
    hc, hs = p["head"], p["head_size"]
    for s in (-1, 1):
        m.cyl("teeth", 0.04, 0.16, (hc.x + s * 0.08, hc.y - hs * 0.45, hc.z - 0.35), rot=(180, 0, 0), radius2=0.0, seg=6)  # fangs
        # the cape: a scalloped bat wing from the shoulders to the raised hands
        pts = [(0.4, 1.0), (1.65, 3.5), (1.55, 2.6), (1.25, 2.9), (1.05, 2.0), (0.8, 2.3), (0.6, 1.4)]
        m.relief("darkred", [(s * x, z) for x, z in pts], 0.08, (0, 0.3, 0), bevel=0.02)
        m.relief("black", [(s * (x + 0.03), z + 0.02) for x, z in pts], 0.06, (0, 0.38, 0), bevel=0.02)
    m.squircle("darkred", (1.4, 0.3, 0.7), (0, 0.2, p["shoulder_z"] + 0.35), power=3)  # high collar
    m.blob("red", (0.18, 0.06, 0.18), (0, -0.37, p["shoulder_z"] - 0.1))  # gem brooch
    for k in range(3):  # bats
        m.relief("black", [(-0.3, 0), (-0.1, 0.05), (0, -0.05), (0.1, 0.05), (0.3, 0), (0.15, -0.1), (0, -0.15), (-0.15, -0.1)],
                 0.03, (-1.2 + k * 1.2, -0.3, 5.0 + (k % 2) * 0.3))
    return m


def shailushai_cat():
    m = Meme("ShailushaiCat")
    # a lanky blue cat in a white beanie, walking through the catacombs past a mushroom
    m.squircle("green", (2.8, 2.0, 0.15), (0, 0, 0.07), power=3)
    for x, y in ((-1.0, -0.5), (1.1, -0.3)):
        m.cyl("cream", 0.07, 0.3, (x, y, 0.3), seg=8)
        m.blob("red", (0.35, 0.35, 0.2), (x, y, 0.48))
        m.blob("white", (0.07, 0.04, 0.05), (x + 0.08, y - 0.15, 0.53))
    for s, (knee, foot) in ((-1, ((-0.2, -0.3, 0.9), (-0.25, -0.45, 0.15))), (1, ((0.25, 0.25, 0.85), (0.25, 0.4, 0.2)))):  # walking
        m.tube("smurf", [(s * 0.2, 0, 1.5), knee, foot], 0.12)
        m.squircle("white", (0.3, 0.5, 0.2), (foot[0], foot[1] - 0.1, foot[2]), power=2.5)
    m.squircle("smurf", (0.9, 0.7, 1.3), (0, 0, 2.1), power=2.3)
    m.squircle("white", (0.92, 0.72, 0.4), (0, 0, 1.55), power=2.5)  # white shorts
    for s in (-1, 1):
        m.tube("smurf", [(s * 0.45, 0, 2.5), (s * 0.6, -0.1 * s, 2.0), (s * 0.55, -0.2 * s, 1.6)], 0.1)
        m.blob("white", (0.2, 0.2, 0.2), (s * 0.55, -0.2 * s, 1.55))
    m.squircle("smurf", (1.1, 0.95, 1.0), (0, -0.05, 3.15), power=2.3)
    for s in (-1, 1):
        mp.ear(m, "smurf", (s * 0.38, 0, 3.55), (s * 0.5, 0, 3.95), width=0.2, inner="pink", thick=0.07)
        m.eye((s * 0.2, -0.5, 3.25), (0.2, 0.1, 0.24), iris="black", lid="smurf", lid_drop=0.3)
        for k in range(2):
            m.box("darkgray", (0.35, 0.02, 0.02), (s * 0.48, -0.47, 3.0 + k * 0.08), rot=(0, s * (k - 0.5) * 20, 0), bevel=0)
    m.blob("black", (0.1, 0.06, 0.07), (0, -0.55, 3.08))
    m.tube("black", [(-0.08, -0.52, 2.95), (0, -0.54, 2.92), (0.08, -0.52, 2.95)], 0.015)
    m.lathe("white", [(0.55, 0), (0.58, 0.15), (0.45, 0.45), (0.0, 0.55)], (0, 0.0, 3.5))  # beanie
    m.torus("white", 0.55, 0.07, (0, 0, 3.55))
    m.blob("white", (0.22, 0.22, 0.22), (0, 0.05, 4.05))  # pom-pom
    m.tube("smurf", [(0, 0.35, 1.7), (0.1, 0.8, 1.9), (0.3, 0.9, 2.4)], lambda t: 0.08 - 0.04 * t)  # tail
    return m


def goth_dance():
    m = Meme("GothDanceHands")
    # a goth girl in a black dress doing the jerky dance: arms bent at sharp angles, one knee up
    p = mp.person(m, skin="marble", shirt="black", pants="black", shoes="black", hair="hairblack", hair_style="long",
                  expr="flat", face_kw={"lids": 0.45, "brows": "hairblack"},
                  legs={-1: ((-0.3, -0.05, 0.9), (-0.3, 0.0, 0.16)), 1: ((0.35, -0.5, 1.2), (0.3, -0.15, 0.7))},
                  arms={"l": ((-0.95, -0.1, 3.1), (-0.85, -0.3, 3.75)), "r": ((0.95, -0.1, 2.45), (1.4, -0.3, 2.85))})
    hc, hs = p["head"], p["head_size"]
    m.lathe("black", [(0.5, 1.0), (0.95, 1.05), (0.7, 1.9), (0.55, 2.2), (0, 2.2)], (0, 0, 0), seg=32)  # dress skirt
    m.squircle("white", (0.75, 0.08, 0.3), (0, -0.36, p["shoulder_z"]), power=3)  # white collar
    m.squircle("hairblack", (hs * 0.95, hs * 0.2, hs * 0.3), (hc.x, hc.y - hs * 0.38, hc.z + hs * 0.32), power=3)  # blunt fringe
    for s in (-1, 1):
        m.tube("hairblack", [(hc.x + s * hs * 0.4, hc.y + 0.1, hc.z - hs * 0.2), (hc.x + s * hs * 0.45, hc.y + 0.15, hc.z - hs * 0.9)], 0.13)  # braids
    m.cyl("lilac", 1.0, 0.1, (0, 0, 0.05), seg=40)
    return m


def awkward_smile_guy():
    m = Meme("AwkwardSmileGuy")
    # a guy in a hallway, stiff as a board, flashing the most awkward tight-lipped smile ever
    p = mp.person(m, skin="skin", shirt="navy", pants="khaki", shoes="brown", hair="hairbrown", hair_style="short",
                  expr="flat", face_kw={"brow_tilt": -0.6, "look": (0.6, 0), "mouth_w": 0.6, "blush": True},
                  arms={"l": ((-0.66, 0.05, 2.4), (-0.6, -0.1, 1.85)), "r": ((0.66, 0.05, 2.4), (0.6, -0.1, 1.85))})
    hc, hs = p["head"], p["head_size"]
    m.tube("mouth", [(hc.x - 0.3, hc.y - hs * 0.42, hc.z - 0.32), (hc.x, hc.y - hs * 0.44, hc.z - 0.35), (hc.x + 0.3, hc.y - hs * 0.42, hc.z - 0.3)], 0.03)
    for k in range(5):  # cardigan buttons
        m.blob("white", (0.08, 0.05, 0.08), (0, -0.33, 1.9 + k * 0.22))
    m.blob("sky", (0.1, 0.05, 0.2), (hc.x + hs * 0.42, hc.y - hs * 0.3, hc.z + 0.3))  # a bead of nervous sweat
    m.squircle("tile", (2.0, 1.4, 0.1), (0, 0, 0.05), power=5)
    return m


def barbenheimer():
    m = Meme("PinkbombFeature")
    # a double feature: a pink dream house on one side, a mushroom cloud on the other, one ticket stub
    m.squircle("ink", (4.0, 2.0, 0.15), (0, 0, 0.07), power=4)
    m.box("dreampink", (0.08, 2.0, 0.16), (0, 0, 0.08), bevel=0)
    # the dream house
    m.squircle("dreampink", (1.5, 1.2, 1.3), (-1.0, 0, 0.8), power=5)
    m.relief("hotpink", [(-0.9, 0), (0.9, 0), (0, 0.8)], 1.3, (-1.0, 0, 1.45), bevel=0.04)
    m.squircle("white", (0.35, 0.06, 0.6), (-1.0, -0.6, 0.45), power=5)
    for s in (-1, 1):
        m.squircle("sky", (0.3, 0.06, 0.3), (-1.0 + s * 0.45, -0.6, 1.0), power=5)
    m.blob("white", (0.4, 0.3, 0.25), (-0.4, -0.5, 0.3))  # a little hedge? (a cloud of tulle)
    m.blob("hotpink", (0.15, 0.15, 0.15), (-0.4, -0.65, 0.42))
    # the mushroom cloud
    m.lathe("smoke", [(0, 0.15), (0.6, 0.15), (0.25, 0.5), (0.22, 1.8), (0, 1.9)], (1.0, 0, 0), seg=24)
    m.lathe("fire", [(0.7, 0.15), (0.95, 0.15), (0.6, 0.35), (0, 0.35)], (1.0, 0, 0), seg=24)
    for k in range(9):
        a = k / 9 * math.tau
        m.blob("smoke", (0.7, 0.7, 0.55), (1.0 + math.cos(a) * 0.55, math.sin(a) * 0.45, 2.3 + (k % 2) * 0.15))
    m.blob("darkgray", (1.0, 0.9, 0.7), (1.0, 0, 2.6))
    m.blob("orange", (0.4, 0.2, 0.3), (1.0, -0.5, 2.05))
    # a ticket stub between them
    m.relief("cream", [(-0.45, 0), (0.45, 0), (0.45, 0.6), (-0.45, 0.6)], 0.03, (0, -0.85, 0.16), rot=(-70, 0, 0))
    m.text("hotpink", "2 FILMS", (0, -0.86, 0.32), size=0.13, depth=0.02, rot=(-70, 0, 0))
    return m


ALL = [coffin_dance, big_mittens_chair, sea_shanty_mug, bing_chilling_cone, its_corn_cob, mauling_time_cape, shailushai_cat,
       goth_dance, awkward_smile_guy, barbenheimer]
