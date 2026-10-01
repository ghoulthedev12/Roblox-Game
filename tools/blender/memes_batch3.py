"""Batch 3 of the meme sculptures (conventions: z is up, the model faces -y, about 4-5 studs tall)."""
import math

from memekit import Meme


def coffin_dance():
    m = Meme("FrozenCoffinDance")
    m.squircle("ice", (4.2, 2.0, 0.3), (0, 0, 0.15), power=5)  # frozen base

    def bearer(x, y, step):
        for s in (-1, 1):  # legs mid dance step
            lift = 0.25 if (s > 0) == step else 0
            m.tube("ink", [(x + s * 0.13, y, 1.25), (x + s * 0.15, y - lift * 0.6, 0.75 + lift), (x + s * 0.15, y - lift, 0.4 + lift)], 0.09)
            m.squircle("black", (0.2, 0.36, 0.14), (x + s * 0.15, y - 0.06 - lift, 0.36 + lift))
        m.squircle("ink", (0.55, 0.36, 0.75), (x, y, 1.6), power=3)  # suit jacket
        m.squircle("white", (0.14, 0.05, 0.4), (x, y - 0.18, 1.72))  # shirt
        m.squircle("black", (0.06, 0.05, 0.3), (x, y - 0.2, 1.7))  # tie
        m.blob("skin2", (0.36, 0.36, 0.42), (x, y, 2.18))  # head
        m.squircle("black", (0.36, 0.08, 0.1), (x, y - 0.18, 2.22))  # sunglasses
        m.tube("ink", [(x + 0.25, y, 1.9), (x + 0.3, y, 2.35), (x + 0.25, y, 2.55)], 0.07)  # arm up holding the coffin
        m.tube("ink", [(x - 0.25, y, 1.9), (x - 0.4, y - 0.2, 1.55)], 0.07)
    for i, (x, y) in enumerate([(-1.2, -0.45), (1.2, -0.45), (-1.2, 0.45), (1.2, 0.45)]):
        bearer(x, y, i % 2 == 0)
    m.squircle("darkbrown", (3.4, 1.1, 0.5), (0, 0, 2.82), power=6)  # the coffin
    m.squircle("brown", (3.3, 1.0, 0.18), (0, 0, 3.12), power=6)  # lid
    for x in (-1.3, 1.3):
        m.squircle("gold", (0.1, 1.12, 0.12), (x, 0, 2.82))  # gold handles
    m.squircle("gold", (0.6, 0.06, 0.08), (0, -0.52, 2.9))
    return m


def big_mittens_chair():
    m = Meme("BigMittensChair")
    for x in (-0.6, 0.6):  # folding chair legs, crossed
        m.tube("darkgray", [(x, -0.55, 0.0), (x, 0.45, 1.3)], 0.05)
        m.tube("darkgray", [(x, 0.45, 0.0), (x, -0.4, 1.3)], 0.05)
        m.tube("darkgray", [(x, 0.45, 1.3), (x, 0.5, 2.6)], 0.05)
    m.squircle("brown", (1.4, 1.1, 0.12), (0, 0, 1.32), power=5)  # seat
    m.squircle("brown", (1.4, 0.12, 0.7), (0, 0.5, 2.25), power=5)  # backrest
    # a puffy brown parka hung over the chair back
    m.squircle("mitten", (1.5, 0.45, 1.1), (0, 0.55, 2.2), power=2.6)
    m.blob("khaki", (1.2, 0.5, 0.35), (0, 0.5, 2.82))  # fur-trimmed hood edge
    m.squircle("envelope", (0.75, 0.5, 0.05), (0.25, -0.15, 1.4), rot=(0, 0, 15), power=8)  # manila envelope

    def mitten(x, side):
        # a big knitted mitten standing up on the seat, leaning back, thumb out to the side
        m.squircle("mitten", (0.66, 0.3, 0.28), (x, -0.05, 1.5), rot=(-12, 0, 0), power=3)  # cuff
        m.squircle("cream", (0.62, 0.3, 0.86), (x, 0.0, 2.02), rot=(-12, 0, 0), power=2.3)  # hand
        m.blob("cream", (0.26, 0.26, 0.42), (x + side * 0.36, -0.05, 1.86), rot=(-12, side * -35, 0))  # thumb
        for i in range(3):  # knit pattern: little red and brown diamonds on the back
            for j in range(2):
                m.blob("red" if (i + j) % 2 == 0 else "mitten", (0.12, 0.06, 0.12),
                       (x - 0.13 + j * 0.26, -0.17 + i * 0.03, 1.82 + i * 0.2), rot=(-12, 0, 45))
    mitten(-0.36, -1)
    mitten(0.36, 1)
    return m


def sea_shanty_mug():
    m = Meme("SeaShantyMug")
    m.cyl("lightwood", 0.8, 1.8, (0, 0, 0.9), seg=36)  # tankard
    for z in (0.25, 1.55):
        m.torus("darkgray", 0.8, 0.05, (0, 0, z))  # iron bands
    for k in range(10):  # wooden staves
        a = k / 10 * math.tau
        m.squircle("wood", (0.06, 0.06, 1.75), (math.cos(a) * 0.79, math.sin(a) * 0.79, 0.9))
    m.torus("wood", 0.45, 0.12, (0.95, 0, 0.95), rot=(90, 0, 0), scale=(1, 1, 1.3))  # handle
    m.blob("foam", (1.75, 1.75, 0.55), (0, 0, 1.85))  # foam top
    for k in range(8):
        a = k / 8 * math.tau
        m.blob("foam", (0.4, 0.4, 0.35), (math.cos(a) * 0.75, math.sin(a) * 0.75, 1.75))  # foam spilling over
    # a tiny whaling ship sailing on the foam, and a whale tail splashing
    m.squircle("brown", (0.9, 0.35, 0.25), (-0.15, -0.1, 2.15), power=3)
    m.cyl("darkbrown", 0.03, 0.9, (-0.15, -0.1, 2.65))
    m.squircle("white", (0.55, 0.04, 0.5), (-0.1, -0.1, 2.75), power=6)  # sail
    m.blob("navy", (0.25, 0.15, 0.25), (0.45, 0.25, 2.2), rot=(0, 30, 0))  # whale tail
    m.blob("navy", (0.35, 0.12, 0.15), (0.55, 0.25, 2.4), rot=(0, -20, 0))
    return m


def bing_chilling_cone():
    m = Meme("BingChillingCone")
    m.cyl("darkgray", 0.55, 0.25, (0, 0, 0.12), seg=32)  # cone stand
    m.cyl("lightgray", 0.3, 0.6, (0, 0, 0.5), seg=24, radius2=0.45)
    m.cyl("waffle", 0.08, 2.4, (0, 0, 1.75), seg=32, radius2=0.62, rot=(0, 0, 0))  # waffle cone (point down)
    for k in range(5):  # waffle grid
        m.torus("lightwood", 0.15 + k * 0.1, 0.025, (0, 0, 1.0 + k * 0.42))
    m.torus("lightwood", 0.62, 0.06, (0, 0, 2.95))
    m.blob("mint", (1.3, 1.3, 1.05), (0, 0, 3.3))  # mint scoop
    m.blob("chocolate", (1.15, 1.15, 0.95), (0, 0, 4.05))  # chocolate scoop
    for k in range(7):  # choc chips
        a = k / 7 * math.tau
        m.blob("chocolate", (0.12, 0.12, 0.1), (math.cos(a) * 0.6, math.sin(a) * 0.6, 3.3 + (k % 2) * 0.2))
    m.blob("chocolate", (0.4, 0.4, 0.5), (0, 0, 4.55))  # swirl tip
    for k in range(6):  # frosty sparkles
        a = k / 6 * math.tau
        m.blob("ice", (0.12, 0.12, 0.12), (math.cos(a) * 1.0, math.sin(a) * 1.0, 3.8 + math.sin(a * 2) * 0.4))
    return m


def its_corn_cob():
    m = Meme("ItsCornCob")
    m.squircle("gold", (1.6, 1.1, 0.35), (0, 0, 0.18), power=5)  # gold stand
    m.squircle("ink", (1.0, 0.06, 0.25), (0, -0.56, 0.2), power=8)  # plaque
    # the cob, standing tall, kernel by kernel
    m.cyl("corn", 0.48, 3.0, (0, 0, 2.0), seg=24)
    for row in range(12):
        z = 0.7 + row * 0.23
        r = 0.5 - abs(row - 5.5) * 0.012
        for k in range(14):
            a = (k + (row % 2) * 0.5) / 14 * math.tau
            m.blob("corn", (0.2, 0.2, 0.2), (math.cos(a) * r, math.sin(a) * r, z), seg=8)
    m.blob("corn", (0.85, 0.85, 0.5), (0, 0, 3.5))  # rounded top
    for k, a in enumerate((0, 120, 240)):  # husk leaves peeled down
        r = math.radians(a)
        m.blob("husk", (0.5, 0.18, 1.6), (math.cos(r) * 0.6, math.sin(r) * 0.6, 1.0), rot=(0, 0, a + 90))
        m.blob("husk", (0.4, 0.14, 1.0), (math.cos(r) * 0.85, math.sin(r) * 0.85, 0.7), rot=(25 * math.cos(r), -25 * math.sin(r), a + 90))
    return m


def mauling_time_cape():
    m = Meme("MaulingTimeVampire")
    m.squircle("ink", (2.6, 1.4, 0.3), (0, 0, 0.15), power=5)  # dark stone base
    for s in (-1, 1):  # legs
        m.tube("ink", [(s * 0.2, 0, 1.6), (s * 0.24, 0, 0.35)], 0.12)
        m.squircle("black", (0.25, 0.5, 0.2), (s * 0.24, -0.1, 0.38))
    m.squircle("ink", (0.8, 0.5, 1.2), (0, 0, 2.2), power=3)  # body
    m.squircle("white", (0.3, 0.06, 0.6), (0, -0.25, 2.4))  # shirt
    m.blob("red", (0.14, 0.06, 0.1), (0, -0.28, 2.65))  # red gem at the collar
    # the cape held wide like bat wings: arms up and out, the cape stretched between
    for s in (-1, 1):
        m.tube("ink", [(s * 0.4, 0, 2.7), (s * 1.1, -0.05, 3.15), (s * 1.7, -0.1, 3.4)], 0.09)  # arms
        m.blob("lightgray", (0.16, 0.16, 0.2), (s * 1.75, -0.1, 3.45))  # pale hands
        for k in range(5):  # the wing panels, scalloped at the bottom
            x = s * (0.4 + k * 0.32)
            top = 3.0 + k * 0.08
            m.squircle("black", (0.36, 0.08, top - 0.9 + k * 0.1), (x, 0.12, (top + 0.9 + k * 0.1) / 2), power=2.4)
            m.squircle("darkred", (0.3, 0.05, top - 1.1 + k * 0.1), (x, 0.06, (top + 1.1 + k * 0.1) / 2), power=2.4)
    m.squircle("black", (1.1, 0.1, 0.8), (0, 0.15, 3.15), power=3)  # tall stand-up collar
    m.squircle("darkred", (0.95, 0.06, 0.7), (0, 0.09, 3.12), power=3)
    m.cyl("lightgray", 0.12, 0.25, (0, 0, 2.95))  # neck
    m.blob("lightgray", (0.5, 0.48, 0.62), (0, 0, 3.35))  # pale head
    m.blob("black", (0.54, 0.52, 0.3), (0, 0.04, 3.58))  # slicked hair
    m.blob("black", (0.16, 0.1, 0.18), (0, -0.2, 3.55))  # widow's peak
    for s in (-1, 1):
        m.blob("red", (0.08, 0.05, 0.06), (s * 0.11, -0.22, 3.38))  # glowing eyes
        m.cyl("white", 0.025, 0.08, (s * 0.06, -0.23, 3.17), rot=(180, 0, 0), radius2=0.0)  # fangs
    m.blob("black", (0.5, 0.25, 0.15), (1.2, -0.7, 4.2))  # a bat flying past
    for s in (-1, 1):
        m.blob("black", (0.35, 0.05, 0.16), (1.2 + s * 0.3, -0.7, 4.25), rot=(0, s * 25, 0))
    return m


def shailushai_cat():
    m = Meme("ShailushaiCat")
    m.blob("husk", (2.4, 1.8, 0.2), (0, 0.1, 0.08))  # mossy forest floor
    for x, y in ((-0.8, 0.4), (0.9, -0.2), (0.6, 0.6)):  # tiny mushrooms
        m.cyl("cream", 0.06, 0.25, (x, y, 0.28))
        m.blob("red", (0.3, 0.3, 0.16), (x, y, 0.42))
    for s in (-1, 1):  # walking legs in white pants
        m.tube("white", [(s * 0.2, 0, 1.1), (s * 0.22, -0.15 * s, 0.5), (s * 0.22, -0.2 * s, 0.25)], 0.15)
        m.blob("smurf", (0.26, 0.4, 0.18), (s * 0.22, -0.28 * s, 0.18))
    m.blob("white", (0.75, 0.6, 0.5), (0, 0, 1.15))  # pants
    m.blob("smurf", (0.8, 0.65, 1.0), (0, 0, 1.65))  # body
    for s in (-1, 1):
        m.tube("smurf", [(s * 0.38, 0, 1.9), (s * 0.55, -0.1 * s, 1.45)], 0.09)
    m.tube("smurf", [(0, 0.3, 1.3), (0.2, 0.7, 1.5), (0.1, 0.9, 1.9)], 0.08)  # tail
    m.blob("smurf", (0.95, 0.85, 0.85), (0, -0.05, 2.5))  # head
    m.blob("lightgray", (0.5, 0.3, 0.3), (0, -0.4, 2.38))  # muzzle
    for s in (-1, 1):
        m.blob("white", (0.24, 0.08, 0.3), (s * 0.18, -0.42, 2.6))  # big eyes
        m.blob("black", (0.12, 0.06, 0.16), (s * 0.18, -0.46, 2.58))
        m.cyl("smurf", 0.14, 0.3, (s * 0.3, 0.05, 2.95), rot=(0, s * 20, 0), radius2=0.02)  # ears
    m.blob("black", (0.1, 0.06, 0.07), (0, -0.56, 2.42))
    # the white floppy mushroom hat, flopping forward
    m.blob("white", (1.0, 0.95, 0.5), (0, 0.0, 3.0))
    m.blob("white", (0.6, 0.55, 0.6), (0, 0.05, 3.35), rot=(-25, 0, 0))
    m.blob("white", (0.35, 0.35, 0.35), (0, -0.25, 3.55))
    return m


def goth_dance():
    m = Meme("GothDanceHands")
    m.cyl("purple", 0.9, 0.15, (0, 0, 0.08), seg=40)  # dance floor
    for s in (-1, 1):  # black boots, white socks
        m.tube("ink", [(s * 0.15, 0, 1.2), (s * 0.2, 0, 0.45)], 0.08)
        m.cyl("white", 0.09, 0.1, (s * 0.2, 0, 0.45))
        m.squircle("black", (0.22, 0.42, 0.3), (s * 0.2, -0.08, 0.25))
    m.cyl("ink", 0.2, 1.1, (0, 0, 1.55), radius2=0.5, rot=(180, 0, 0))  # black dress, flaring out
    m.squircle("ink", (0.6, 0.35, 0.65), (0, 0, 2.3), power=3)  # bodice
    m.blob("white", (0.55, 0.32, 0.12), (0, -0.12, 2.6))  # white collar
    m.blob("skin", (0.48, 0.45, 0.58), (0, 0, 3.0))  # head
    m.blob("black", (0.52, 0.5, 0.35), (0, 0.04, 3.2))  # dark hair
    for s in (-1, 1):
        m.tube("black", [(s * 0.22, 0.05, 3.05), (s * 0.3, 0.05, 2.6), (s * 0.3, 0.0, 2.3)], 0.06)  # two braids
        m.blob("black", (0.06, 0.04, 0.05), (s * 0.1, -0.22, 3.0))  # deadpan eyes
    # the jerky dance pose: one arm bent up at a sharp angle, the other flung out stiff
    m.tube("ink", [(-0.3, 0, 2.5), (-0.65, -0.1, 2.3), (-0.6, -0.15, 2.9)], 0.07)
    m.blob("skin", (0.12, 0.12, 0.16), (-0.6, -0.15, 3.0))
    m.tube("ink", [(0.3, 0, 2.5), (0.85, -0.1, 2.75), (1.2, -0.2, 2.6)], 0.07)
    m.blob("skin", (0.12, 0.12, 0.16), (1.25, -0.2, 2.58))
    return m


def awkward_smile_guy():
    m = Meme("AwkwardSmileGuy")
    for s in (-1, 1):
        m.squircle("darkbrown", (0.4, 0.62, 0.25), (s * 0.3, -0.08, 0.12))  # shoes
        m.squircle("khaki", (0.46, 0.5, 1.3), (s * 0.27, 0, 0.85), power=3)  # trousers
    m.squircle("navy", (1.35, 0.85, 1.4), (0, 0, 2.15), power=3)  # stocky shirt
    m.squircle("navy", (1.6, 0.86, 0.5), (0, 0, 2.85), power=3)  # shoulders shrugged up
    for s in (-1, 1):  # arms down, hands tucked in pockets
        m.tube("navy", [(s * 0.75, 0, 2.8), (s * 0.78, -0.05, 2.0), (s * 0.55, -0.25, 1.45)], 0.18)
        m.squircle("khaki", (0.25, 0.06, 0.32), (s * 0.45, -0.32, 1.45))  # pocket
    for k in range(3):
        m.blob("white", (0.06, 0.04, 0.06), (0, -0.44, 2.6 - k * 0.3))  # buttons
    m.cyl("skin", 0.25, 0.25, (0, 0, 3.15))
    m.squircle("skin", (0.8, 0.78, 0.92), (0, 0, 3.6), power=2.6)  # broad face
    m.blob("darkbrown", (0.84, 0.82, 0.4), (0, 0.06, 4.0))  # short hair
    m.blob("skin", (0.16, 0.18, 0.2), (0, -0.4, 3.58))  # nose
    for s in (-1, 1):
        m.blob("white", (0.16, 0.05, 0.1), (s * 0.18, -0.37, 3.75))
        m.blob("darkbrown", (0.08, 0.05, 0.09), (s * 0.18 + 0.05, -0.39, 3.75))  # eyes glancing sideways
        m.squircle("darkbrown", (0.2, 0.05, 0.05), (s * 0.18, -0.38, 3.88))
        m.blob("pink", (0.12, 0.04, 0.07), (s * 0.27, -0.36, 3.45))  # flushed cheeks
    m.tube("darkred", [(-0.18, -0.39, 3.36), (0, -0.41, 3.34), (0.18, -0.39, 3.36)], 0.03)  # tight closed-mouth smile
    return m


def barbenheimer():
    m = Meme("PinkbombFeature")
    m.squircle("dreampink", (1.9, 1.8, 0.3), (-0.95, 0, 0.15), power=6)  # pink half of the base
    m.squircle("ink", (1.9, 1.8, 0.3), (0.95, 0, 0.15), power=6)  # dark half
    # left: a pink dream house
    m.squircle("dreampink", (1.4, 1.1, 1.3), (-0.95, 0, 0.95), power=6)
    m.cyl("hotpink", 0.95, 0.7, (-0.95, 0, 1.95), seg=4, radius2=0.0, rot=(0, 0, 45), scale=(1.05, 0.8, 1))  # roof
    m.squircle("white", (0.35, 0.05, 0.55), (-0.95, -0.56, 0.6), power=5)  # door
    for x in (-1.35, -0.55):
        m.squircle("sky", (0.3, 0.05, 0.3), (x, -0.56, 1.15), power=5)
    m.blob("hotpink", (0.25, 0.08, 0.22), (-0.95, -0.58, 1.6))  # heart window
    m.cyl("hotpink", 0.25, 1.4, (-1.75, -0.4, 1.0), seg=16, radius2=0.25)  # pink palm trunk
    # right: a mushroom cloud
    m.cyl("smoke", 0.32, 1.6, (0.95, 0, 1.1), seg=24, radius2=0.22)
    m.blob("fire", (1.6, 1.4, 0.55), (0.95, 0, 0.4))  # fiery base ring
    m.blob("smoke", (1.8, 1.6, 0.9), (0.95, 0, 2.2))  # the cap
    for k in range(6):
        a = k / 6 * math.tau
        m.blob("smoke", (0.7, 0.7, 0.6), (0.95 + math.cos(a) * 0.7, math.sin(a) * 0.6, 2.25 + (k % 2) * 0.15))
    m.blob("fire", (1.4, 1.2, 0.4), (0.95, 0, 1.85))  # glowing underside
    return m


ALL = [coffin_dance, big_mittens_chair, sea_shanty_mug, bing_chilling_cone, its_corn_cob, mauling_time_cape,
       shailushai_cat, goth_dance, awkward_smile_guy, barbenheimer]
