"""Batch 4 of the meme sculptures (conventions: z is up, the model faces -y, about 4-5 studs tall)."""
import math

from memekit import Meme


def girl_dinner():
    m = Meme("GirlDinnerPlate")
    m.squircle("pink", (3.0, 2.4, 0.06), (0, 0, 0.03), power=6)  # checkered cloth (pink)
    m.cyl("white", 1.2, 0.12, (0, 0, 0.12), seg=48)  # the plate
    m.torus("lightgray", 1.1, 0.04, (0, 0, 0.18))
    m.squircle("lightwood", (0.9, 0.55, 0.22), (-0.45, 0.35, 0.3), rot=(0, 0, 20), power=3)  # bread slice
    m.squircle("tan", (0.95, 0.6, 0.12), (-0.45, 0.35, 0.22), rot=(0, 0, 20), power=3)  # crust
    m.cyl("cheese", 0.38, 0.32, (0.45, 0.35, 0.34), seg=3, rot=(0, 0, 30))  # cheese wedge
    for k in range(4):
        m.blob("white", (0.07, 0.07, 0.05), (0.38 + k * 0.06, 0.25 + (k % 2) * 0.12, 0.5))  # cheese holes
    for i in range(9):  # grape cluster
        m.blob("grape", (0.2, 0.2, 0.2), (0.35 + (i % 3) * 0.15, -0.45 + (i // 3) * 0.13, 0.28 + (i // 3) * 0.08))
    m.tube("pickle", [(0.05, 0.02, 0.4), (0.0, 0.01, 0.42)], 0.03)
    m.blob("pickle", (0.75, 0.24, 0.24), (-0.4, -0.45, 0.3), rot=(0, 0, -25))  # a pickle
    for k in range(3):  # crackers
        m.squircle("waffle", (0.35, 0.35, 0.05), (0.0, -0.1 + k * 0.05, 0.25 + k * 0.05), rot=(0, 0, k * 15), power=6)
    m.blob("black", (0.14, 0.14, 0.12), (0.0, 0.7, 0.26))  # an olive
    return m


def roman_empire_bust():
    m = Meme("RomanEmpireBust")
    m.cyl("marble", 0.6, 1.4, (0, 0, 0.7), seg=24)  # column
    for k in range(8):  # fluting
        a = k / 8 * math.tau
        m.cyl("lightgray", 0.06, 1.3, (math.cos(a) * 0.58, math.sin(a) * 0.58, 0.7), seg=8)
    m.squircle("marble", (1.5, 1.5, 0.2), (0, 0, 1.48), power=5)  # capital
    m.squircle("marble", (1.8, 1.0, 0.9), (0, 0, 2.05), power=2.6)  # shoulders with toga
    m.tube("lightgray", [(-0.85, -0.3, 2.3), (0, -0.48, 1.85), (0.75, -0.3, 2.4)], 0.07)  # toga fold
    m.cyl("marble", 0.28, 0.4, (0, 0, 2.55))  # neck
    m.blob("marble", (0.85, 0.95, 1.05), (0, 0, 3.05))  # head
    m.blob("marble", (0.16, 0.25, 0.3), (0, -0.48, 3.0))  # roman nose
    for s in (-1, 1):
        m.blob("lightgray", (0.16, 0.06, 0.08), (s * 0.18, -0.42, 3.15))  # blank marble eyes
        m.blob("marble", (0.12, 0.22, 0.28), (s * 0.43, 0, 3.05))
    m.blob("lightgray", (0.88, 0.95, 0.4), (0, 0.04, 3.4))  # curly hair cap
    for k in range(14):  # laurel wreath
        a = k / 14 * math.tau
        m.blob("laurel", (0.22, 0.1, 0.12), (math.cos(a) * 0.46, math.sin(a) * 0.5, 3.32), rot=(0, 0, math.degrees(a) + 60))
    # a thought bubble: he thinks about it every day
    for i, (x, z, r) in enumerate([(0.6, 3.75, 0.12), (0.85, 4.0, 0.18)]):
        m.blob("white", (r * 2, r * 2, r * 2), (x, -0.1, z))
    m.blob("white", (0.9, 0.5, 0.6), (1.25, -0.1, 4.45))
    m.cyl("marble", 0.12, 0.35, (1.25, -0.4, 4.45), rot=(90, 0, 0), seg=12)  # a tiny column inside the bubble
    return m


def orca_boat():
    m = Meme("OrcaRebellionBoat")
    m.squircle("water", (4.0, 2.4, 0.3), (0, 0, 0.15), power=4)  # sea
    for k in range(5):  # waves
        m.blob("sky", (0.6, 0.3, 0.12), (-1.5 + k * 0.75, -0.9 + (k % 2) * 1.6, 0.32))
    # the orca, leaping out of the water and ramming the boat
    m.blob("orca", (2.4, 0.9, 1.0), (-0.5, 0, 1.0), rot=(0, -25, 0))
    m.blob("white", (1.6, 0.8, 0.55), (-0.6, 0, 0.78), rot=(0, -25, 0))  # white belly
    for s in (-1, 1):
        m.blob("white", (0.35, 0.1, 0.18), (-1.25, s * 0.42, 1.48), rot=(0, -25, 0))  # eye patches
    m.cyl("orca", 0.3, 1.0, (-0.25, 0, 1.8), rot=(0, -10, 0), radius2=0.02, scale=(1, 0.3, 1))  # tall dorsal fin
    m.blob("orca", (0.8, 0.3, 0.12), (0.6, 0, 0.45), rot=(0, 30, 0))  # tail flukes
    for s in (-1, 1):
        m.blob("orca", (0.6, 0.12, 0.3), (-0.8, s * 0.5, 0.75), rot=(s * 30, 20, 0))  # flippers
    # the little sailboat, tipped over by the bump
    m.squircle("white", (1.6, 0.7, 0.45), (1.2, 0.1, 0.65), rot=(18, 0, 10), power=3)
    m.squircle("red", (1.62, 0.72, 0.1), (1.2, 0.1, 0.5), rot=(18, 0, 10), power=3)
    m.cyl("lightwood", 0.04, 1.8, (1.25, 0.35, 1.6), rot=(18, 10, 0))  # mast
    m.squircle("lace", (0.06, 0.9, 1.2), (1.28, 0.6, 1.75), rot=(18, 10, 0), power=8)  # sail
    return m


def john_pork_phone():
    m = Meme("JohnPorkPhone")
    m.squircle("darkgray", (1.6, 1.0, 0.25), (0, 0.2, 0.12), power=5)  # phone stand
    m.squircle("black", (1.8, 0.22, 3.6), (0, 0, 2.05), rot=(-8, 0, 0), power=6)  # the smartphone
    m.squircle("screen", (1.62, 0.05, 3.3), (0, -0.12, 2.05), rot=(-8, 0, 0), power=8)  # glowing screen
    # the caller, a pig in a suit, leaning out of the screen
    m.squircle("navy", (1.0, 0.5, 0.55), (0, -0.35, 2.2), rot=(-8, 0, 0), power=3)  # suit shoulders
    m.squircle("white", (0.3, 0.1, 0.35), (0, -0.58, 2.3))
    m.cyl("red", 0.06, 0.3, (0, -0.62, 2.25), rot=(180, 0, 0), radius2=0.02)  # tie
    m.blob("pig", (0.9, 0.75, 0.8), (0, -0.4, 2.9))  # pig head
    m.cyl("pig", 0.2, 0.2, (0, -0.85, 2.85), rot=(90, 0, 0))  # snout
    for s in (-1, 1):
        m.blob("hotpink", (0.06, 0.04, 0.09), (s * 0.08, -0.96, 2.85))  # nostrils
        m.blob("black", (0.1, 0.06, 0.1), (s * 0.2, -0.75, 3.05))
        m.cyl("pig", 0.16, 0.3, (s * 0.35, -0.3, 3.3), rot=(0, s * 30, 0), radius2=0.02)  # ears
    # answer and decline buttons
    m.cyl("callgreen", 0.22, 0.08, (-0.45, -0.15, 0.75), rot=(82, 0, 0))
    m.cyl("red", 0.22, 0.08, (0.45, -0.15, 0.75), rot=(82, 0, 0))
    for k in range(3):  # ringing waves
        m.torus("callgreen", 0.3 + k * 0.18, 0.025, (1.15, -0.1, 3.6), rot=(90, 0, 0), scale=(0.45, 1, 1))
    return m


def brat_slab():
    m = Meme("BratGreenSlab")
    m.squircle("darkgray", (2.6, 1.0, 0.3), (0, 0, 0.15), power=6)  # base
    m.squircle("brat", (2.4, 0.35, 2.4), (0, 0, 1.55), power=8)  # the lime green slab
    y = -0.2
    # the word "brat", lowercase, chunky and slightly blurry (puffy letter strokes)
    r = 0.1
    m.tube("black", [(-0.85, y, 1.9), (-0.85, y, 1.1)], r)  # b
    m.torus("black", 0.17, r, (-0.68, y, 1.3), rot=(90, 0, 0))
    m.tube("black", [(-0.35, y, 1.5), (-0.35, y, 1.1)], r)  # r
    m.tube("black", [(-0.35, y, 1.4), (-0.25, y, 1.5), (-0.12, y, 1.48)], r)
    m.torus("black", 0.17, r, (0.18, y, 1.3), rot=(90, 0, 0))  # a
    m.tube("black", [(0.36, y, 1.5), (0.36, y, 1.1)], r)
    m.tube("black", [(0.72, y, 1.75), (0.72, y, 1.15), (0.8, y, 1.1)], r)  # t
    m.tube("black", [(0.58, y, 1.5), (0.88, y, 1.5)], r)
    return m


def demure_teacup():
    m = Meme("VeryDemureTeacup")
    m.cyl("lace", 1.3, 0.04, (0, 0, 0.02), seg=48)  # lace doily
    for k in range(16):
        a = k / 16 * math.tau
        m.blob("lace", (0.32, 0.32, 0.04), (math.cos(a) * 1.3, math.sin(a) * 1.3, 0.02))
    m.cyl("white", 0.9, 0.1, (0, 0, 0.1), seg=48, radius2=1.0)  # saucer
    m.torus("gold", 0.95, 0.025, (0, 0, 0.15))
    m.cyl("white", 0.32, 0.9, (0, 0, 0.6), seg=40, radius2=0.62)  # dainty cup
    m.torus("gold", 0.62, 0.03, (0, 0, 1.05))
    m.torus("pink", 0.45, 0.04, (0, 0, 0.65), scale=(1, 1, 1))  # pink band
    m.cyl("coffee", 0.6, 0.04, (0, 0, 0.98), seg=40)  # tea
    m.torus("white", 0.2, 0.05, (0.7, 0, 0.65), rot=(90, 0, 0))  # handle
    m.tube("gold", [(0.3, -0.2, 0.18), (0.75, -0.6, 0.2)], 0.025)  # teaspoon
    m.blob("gold", (0.15, 0.1, 0.04), (0.8, -0.65, 0.2))
    m.squircle("white", (0.18, 0.18, 0.18), (-0.6, -0.55, 0.24), power=8)  # sugar cube
    # a tiny gloved hand holding the handle, pinky out, very demure
    m.blob("white", (0.25, 0.2, 0.3), (0.98, 0, 0.7))
    m.tube("white", [(1.05, 0, 0.6), (1.25, 0.0, 0.48)], 0.04)  # the pinky
    m.squircle("pink", (0.5, 0.3, 0.2), (-0.1, 0.2, 1.4), power=2.5)  # bow on top (floating, pure decoration)
    for s in (-1, 1):
        m.blob("pink", (0.35, 0.18, 0.25), (-0.1 + s * 0.3, 0.2, 1.4), rot=(0, s * 20, 0))
    return m


def rizz_mask():
    m = Meme("RizzFaceMask")
    m.cyl("ink", 0.55, 0.2, (0, 0, 0.1), seg=32)  # stand
    m.cyl("gold", 0.06, 1.4, (0, 0, 0.85))
    m.squircle("cream", (1.5, 0.45, 1.8), (0, 0, 2.4), power=2.4)  # the mask
    m.squircle("gold", (1.56, 0.4, 1.86), (0, 0.08, 2.4), power=2.4)  # gold rim
    # one eyebrow raised high, the other flat: the rizz face
    m.tube("darkbrown", [(-0.55, -0.25, 2.85), (-0.35, -0.27, 3.05), (-0.12, -0.25, 2.98)], 0.06)
    m.tube("darkbrown", [(0.12, -0.25, 2.78), (0.55, -0.25, 2.8)], 0.06)
    m.blob("black", (0.3, 0.08, 0.16), (-0.33, -0.23, 2.68))
    m.blob("black", (0.3, 0.08, 0.08), (0.33, -0.23, 2.66))  # one eye narrowed
    m.blob("cream", (0.18, 0.2, 0.35), (0, -0.28, 2.4))  # nose
    m.tube("darkred", [(-0.3, -0.24, 1.95), (0.05, -0.26, 1.92), (0.35, -0.25, 2.0)], 0.05)  # smirk, lips pressed
    return m


def mewing_hush():
    m = Meme("MewingHush")
    m.cyl("ink", 0.7, 0.45, (0, 0, 0.22), seg=40)  # pedestal
    m.cyl("skin", 0.5, 0.75, (0, 0, 0.9), seg=40, scale=(1.5, 0.8, 1), radius2=0.62)  # torso
    m.blob("skin", (2.0, 0.95, 0.55), (0, 0, 1.33))  # shoulders
    m.cyl("skin", 0.32, 0.6, (0, 0.05, 1.7))
    m.squircle("skin", (1.1, 1.1, 1.0), (0, 0, 2.6), power=2.4)  # skull
    m.squircle("skin", (1.05, 0.95, 0.4), (0, -0.05, 2.15), power=4)  # razor-sharp jawline
    m.squircle("skin", (0.5, 0.35, 0.3), (0, -0.42, 2.05), power=3.5)  # chin
    m.blob("darkbrown", (1.1, 1.1, 0.45), (0, 0.08, 3.05))  # hair
    for s in (-1, 1):
        m.blob("white", (0.18, 0.06, 0.1), (s * 0.22, -0.52, 2.65))
        m.blob("black", (0.08, 0.05, 0.08), (s * 0.22, -0.55, 2.65))
    m.tube("darkbrown", [(-0.38, -0.53, 2.8), (-0.12, -0.55, 2.84)], 0.03)
    m.tube("darkbrown", [(0.1, -0.55, 2.86), (0.26, -0.56, 2.95), (0.38, -0.53, 2.92)], 0.03)  # one raised eyebrow
    m.blob("skin", (0.14, 0.2, 0.25), (0, -0.58, 2.45))  # nose
    m.tube("darkred", [(-0.13, -0.5, 2.25), (0.13, -0.5, 2.25)], 0.025)  # lips pressed shut
    # finger to the lips: shhh
    m.tube("skin", [(0.45, -0.3, 1.5), (0.25, -0.6, 1.9), (0.05, -0.62, 2.15)], 0.1)
    m.tube("skin", [(0.05, -0.62, 2.15), (0.0, -0.6, 2.45)], 0.05)  # the finger
    return m


def gta_hourglass():
    m = Meme("BeforeGTA6Hourglass")
    for z in (0.12, 3.6):  # wooden top and bottom
        m.cyl("wood", 1.0, 0.25, (0, 0, z), seg=40)
        m.torus("gold", 1.0, 0.05, (0, 0, z))
    for k in range(3):  # posts
        a = k / 3 * math.tau
        m.cyl("darkbrown", 0.07, 3.3, (math.cos(a) * 0.85, math.sin(a) * 0.85, 1.86), seg=12)
    # upper bulb: nearly full of sand (that's the joke: it never runs out), a sliver of glass on top
    m.cyl("waffle", 0.75, 1.25, (0, 0, 2.68), seg=40, radius2=0.08, rot=(180, 0, 0))
    m.cyl("ice", 0.76, 0.25, (0, 0, 3.4), seg=40, radius2=0.7, rot=(180, 0, 0))
    m.cyl("waffle", 0.025, 0.4, (0, 0, 1.9), seg=8)  # the endless trickle
    # lower bulb: empty glass with only a tiny pile at the bottom
    m.cyl("ice", 0.5, 1.15, (0, 0, 1.47), seg=40, radius2=0.08)
    m.cyl("waffle", 0.75, 0.32, (0, 0, 0.4), seg=40, radius2=0.5)
    m.cyl("waffle", 0.5, 0.16, (0, 0, 0.62), seg=40, radius2=0.12)
    return m


def king_prawn():
    m = Meme("KingPrawnCrooner")
    m.cyl("ink", 0.9, 0.2, (0, 0, 0.1), seg=40)  # little stage
    m.torus("gold", 0.9, 0.04, (0, 0, 0.2))
    m.cyl("darkgray", 0.04, 1.9, (-0.7, -0.4, 1.15))  # mic stand
    m.blob("black", (0.18, 0.18, 0.26), (-0.65, -0.45, 2.15))  # mic
    # the prawn, standing upright, curled tail behind
    for k in range(5):
        m.blob("prawn", (0.5 - k * 0.05, 0.5, 0.35), (0.1, 0.2 + k * 0.12, 0.35 + k * 0.08), rot=(30, 0, 0))  # tail segments
    m.blob("prawn", (0.5, 0.35, 0.3), (0.1, 0.85, 0.35))  # tail fan
    m.squircle("navy", (0.85, 0.6, 1.2), (0, 0, 1.35), power=2.6)  # pinstripe suit
    for x in (-0.25, 0.0, 0.25):
        m.squircle("lightgray", (0.02, 0.62, 1.15), (x, 0, 1.35), power=8)  # pinstripes
    m.squircle("white", (0.25, 0.1, 0.5), (0, -0.3, 1.55))
    m.blob("red", (0.18, 0.08, 0.12), (0, -0.35, 1.78))  # bow tie
    m.blob("prawn", (0.6, 0.55, 0.65), (0, -0.05, 2.25))  # head
    m.cyl("prawn", 0.08, 0.5, (0, -0.4, 2.35), rot=(-70, 0, 0), radius2=0.02)  # rostrum spike
    for s in (-1, 1):
        m.cyl("prawn", 0.03, 0.25, (s * 0.15, -0.2, 2.6), rot=(0, s * 20, 0))  # eye stalks
        m.blob("black", (0.12, 0.12, 0.12), (s * 0.2, -0.2, 2.75))
        m.tube("prawn", [(s * 0.1, -0.3, 2.4), (s * 0.6, -0.6, 3.2), (s * 1.0, -0.5, 3.6)], 0.02)  # long antennae
        m.tube("navy", [(s * 0.4, 0, 1.75), (s * 0.55, -0.3, 1.5)], 0.08)  # arms
    m.tube("navy", [(-0.4, 0, 1.75), (-0.6, -0.4, 2.05)], 0.08)  # one arm out to the mic, crooning
    return m


def aura_boat():
    m = Meme("AuraBoatBow")
    m.squircle("water", (3.6, 1.6, 0.25), (0, 0, 0.12), power=4)  # river
    # the long racing boat's bow, pointed up
    m.squircle("red", (3.0, 0.7, 0.4), (0, 0, 0.45), rot=(0, -12, 0), power=3)
    m.cyl("red", 0.35, 1.0, (-1.7, 0, 0.82), rot=(0, -78, 0), radius2=0.02, scale=(1, 0.6, 1))  # pointed tip
    m.squircle("lightwood", (2.6, 0.5, 0.06), (0.1, 0, 0.66), rot=(0, -12, 0), power=6)  # deck
    for x in (-0.3, 0.4, 1.1):
        m.squircle("gold", (0.05, 0.72, 0.42), (x, 0, 0.5 + x * -0.2), rot=(0, -12, 0), power=6)  # gold stripes
    # sunglasses and a black cap resting on the tip, ultra cool
    m.blob("black", (0.5, 0.45, 0.25), (-1.4, 0, 1.2))  # cap
    m.squircle("black", (0.4, 0.3, 0.05), (-1.65, 0, 1.12), power=4)  # brim
    m.blob("black", (0.18, 0.08, 0.1), (-1.2, -0.3, 1.0))
    m.blob("black", (0.18, 0.08, 0.1), (-1.2, -0.05, 1.0))
    # the aura: glowing rings rising off it
    for k in range(3):
        m.torus("aura", 0.6 + k * 0.35, 0.05, (-0.2, 0, 1.5 + k * 0.55), scale=(1.3, 0.8, 1))
    for k in range(8):
        a = k / 8 * math.tau
        m.blob("aura", (0.14, 0.14, 0.2), (-0.2 + math.cos(a) * 1.3, math.sin(a) * 0.8, 1.2 + (k % 3) * 0.5))
    return m


ALL = [girl_dinner, roman_empire_bust, orca_boat, john_pork_phone, brat_slab, demure_teacup, rizz_mask, mewing_hush,
       gta_hourglass, king_prawn, aura_boat]
