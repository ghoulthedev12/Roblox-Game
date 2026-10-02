"""Batch 4 of the meme sculptures (remodeled in the full meme remodel, same ids).
Conventions: z is up, the model faces -y, about 4-5 studs tall. Original parody designs."""
import math

from memekit import Meme
import memeparts as mp


def girl_dinner():
    m = Meme("GirlDinnerPlate")
    # a plate of girl dinner on a little bistro table: bread, cheese, grapes, a pickle, crackers
    m.cyl("darkgray", 0.9, 0.08, (0, 0, 0.04), seg=32)
    m.cyl("darkgray", 0.08, 1.6, (0, 0, 0.85), seg=10)
    m.cyl("pink", 1.5, 0.1, (0, 0, 1.68), seg=48)  # tabletop
    m.torus("white", 1.5, 0.04, (0, 0, 1.72))
    m.lathe("white", [(0, 0), (1.15, 0), (1.25, 0.1), (1.2, 0.14), (0, 0.06)], (0, 0, 1.73), seg=48)  # the plate
    m.torus("lightgray", 1.1, 0.03, (0, 0, 1.86))
    m.squircle("lightwood", (0.85, 0.6, 0.3), (-0.45, 0.3, 2.0), rot=(15, 0, 20), power=3)  # bread
    m.squircle("tan", (0.9, 0.65, 0.12), (-0.45, 0.3, 1.88), rot=(15, 0, 20), power=3)
    m.relief("cheese", [(-0.35, 0), (0.35, 0), (0.0, 0.45)], 0.3, (0.45, 0.35, 1.9), rot=(0, 0, -15), bevel=0.03)  # cheese wedge
    for k in range(3):
        m.blob("cream", (0.08, 0.05, 0.08), (0.4 + k * 0.08, 0.18, 2.0 + (k % 2) * 0.1))
    for i in range(10):  # grape bunch
        m.blob("grape", (0.22, 0.22, 0.22), (0.4 + (i % 3) * 0.17 - (i // 3) * 0.04, -0.4 + (i // 3) * 0.12, 1.98 + (i // 3) * 0.1))
    m.cyl("darkgreen", 0.025, 0.25, (0.5, -0.1, 2.35), rot=(30, 0, 0), seg=6)
    m.squircle("pickle", (0.8, 0.28, 0.28), (-0.4, -0.45, 1.98), rot=(0, 0, -25), power=2.0)
    for k in range(4):
        m.blob("darkgreen", (0.06, 0.04, 0.05), (-0.65 + k * 0.17, -0.55 + k * 0.07, 2.05))
    for k in range(3):  # crackers
        m.squircle("waffle", (0.38, 0.38, 0.05), (0.0, -0.05 + k * 0.04, 1.92 + k * 0.05), rot=(0, 0, k * 15), power=6)
    m.text("hotpink", "girl dinner", (0, -1.0, 2.6), size=0.3, depth=0.04)
    return m


def roman_empire_bust():
    m = Meme("RomanEmpireBust")
    # a marble emperor bust on a fluted column, laurel wreath, thinking about the empire (again)
    m.lathe("marble", [(0, 0), (0.8, 0), (0.8, 0.15), (0.62, 0.25), (0.58, 1.3), (0.75, 1.42), (0.75, 1.55), (0, 1.55)], (0, 0, 0), seg=32)
    for k in range(12):
        a = k / 12 * math.tau
        m.cyl("lightgray", 0.045, 1.0, (math.cos(a) * 0.6, math.sin(a) * 0.6, 0.78), seg=8)  # fluting
    m.squircle("marble", (1.9, 1.05, 0.95), (0, 0, 2.0), power=2.4)  # shoulders with toga
    for k in range(4):
        m.tube("lightgray", [(-0.85 + k * 0.1, -0.35, 2.4 - k * 0.12), (0.1 + k * 0.05, -0.5, 1.75 + k * 0.05), (0.8, -0.3, 2.35 - k * 0.1)], 0.04)  # folds
    m.cyl("marble", 0.27, 0.45, (0, 0, 2.6), seg=16)
    m.squircle("marble", (0.85, 0.95, 1.1), (0, 0, 3.15), power=2.4)  # head
    m.blob("marble", (0.16, 0.28, 0.32), (0, -0.5, 3.1))  # roman nose
    for s in (-1, 1):
        m.blob("lightgray", (0.18, 0.06, 0.08), (s * 0.19, -0.44, 3.27))  # blank marble eyes
        m.box("lightgray", (0.24, 0.06, 0.05), (s * 0.19, -0.46, 3.4), rot=(0, s * -8, 0), bevel=0.02)
        m.blob("marble", (0.14, 0.24, 0.3), (s * 0.44, 0, 3.12))
    m.tube("lightgray", [(-0.12, -0.46, 2.88), (0.12, -0.46, 2.88)], 0.02)
    for k in range(16):  # curly hair cap
        a = k / 16 * math.tau
        m.blob("lightgray", (0.25, 0.25, 0.22), (math.cos(a) * 0.36, math.sin(a) * 0.4 + 0.05, 3.55))
    for k in range(16):  # laurel wreath
        a = k / 16 * math.tau
        m.blob("laurel", (0.24, 0.1, 0.12), (math.cos(a) * 0.47, math.sin(a) * 0.5, 3.42), rot=(0, 0, math.degrees(a) + 60))
    for x, z, r in [(0.6, 3.9, 0.1), (0.85, 4.15, 0.15)]:  # thought bubble
        m.blob("white", (r * 2,) * 3, (x, -0.1, z))
    m.blob("white", (1.1, 0.5, 0.75), (1.35, -0.1, 4.6))
    m.relief("marble", [(-0.3, 0), (0.3, 0), (0.3, 0.06), (0.22, 0.06), (0.22, 0.4), (0.3, 0.4), (0.3, 0.46), (-0.3, 0.46), (-0.3, 0.4),
                        (-0.22, 0.4), (-0.22, 0.06), (-0.3, 0.06)], 0.06, (1.35, -0.38, 4.37), bevel=0)  # a tiny column in it
    return m


def orca_boat():
    m = Meme("OrcaRebellionBoat")
    # an orca bursting out of the sea and ramming a little yacht, which tips over: rebellion
    m.squircle("water", (4.2, 2.6, 0.3), (0, 0, 0.15), power=4)
    for k in range(7):
        m.blob("sky", (0.55, 0.3, 0.12), (-1.6 + k * 0.55, -0.9 + (k % 3) * 0.8, 0.32))
    m.lathe("orca", [(0, -1.4), (0.3, -1.2), (0.55, -0.5), (0.6, 0.2), (0.45, 0.9), (0.15, 1.3), (0, 1.4)], (-0.5, 0, 1.1),
            rot=(0, 90 + 30, 0), seg=28)  # the orca, leaping at an angle
    m.blob("white", (1.6, 0.8, 0.5), (-0.6, -0.05, 0.85), rot=(0, -30, 0))  # white belly
    for s in (-1, 1):
        m.blob("white", (0.4, 0.1, 0.2), (-1.4, s * 0.43, 1.75), rot=(0, -30, 0))  # eye patches
        m.blob("orca", (0.6, 0.12, 0.3), (-0.9, s * 0.55, 0.8), rot=(s * 30, 20, 0))  # flippers
    m.relief("orca", [(0, 0), (0.45, 0), (0.05, 1.0)], 0.12, (-0.35, 0, 1.6), rot=(0, -25, 0), bevel=0.03)  # tall dorsal fin
    m.relief("orca", [(0, 0), (0.6, 0.35), (0.45, 0), (0.6, -0.35)], 0.1, (0.55, 0, 0.45), rot=(0, 30, 90), bevel=0.03)  # flukes
    m.blob("mouth", (0.4, 0.4, 0.12), (-1.8, 0, 1.85), rot=(0, -30, 0))
    # the little yacht, tipped over
    m.squircle("white", (1.6, 0.7, 0.45), (1.3, 0.1, 0.65), rot=(22, 0, 12), power=3)
    m.squircle("navy", (1.62, 0.72, 0.1), (1.3, 0.1, 0.48), rot=(22, 0, 12), power=3)
    m.cyl("wood", 0.03, 1.4, (1.25, -0.2, 1.3), rot=(22, 0, 12), seg=6)
    m.relief("white", [(0, 0), (0.6, 0), (0, 1.0)], 0.03, (1.27, -0.25, 1.1), rot=(22, 0, 12))
    for k in range(5):  # splash
        a = k / 5 * math.pi
        m.blob("sky", (0.2, 0.2, 0.25), (0.6 + math.cos(a) * 0.4, -0.2, 0.6 + math.sin(a) * 0.5))
    return m


def john_pork_phone():
    m = Meme("JohnPorkPhone")
    # a pig in a sharp suit holding a phone to his ear, ringing: do not pick up
    p = mp.person(m, skin="pig", shirt="suit", pants="suit", shoes="black", hair=None, hair_style="bald", expr="smile",
                  face_kw={"nose": False, "brows": None},
                  arms={"r": ((0.95, -0.2, 2.75), (0.6, -0.3, 3.55)), "l": ((-0.75, 0.0, 2.4), (-0.5, -0.35, 2.05))})
    hc, hs = p["head"], p["head_size"]
    m.squircle("pig", (0.55, 0.35, 0.4), (hc.x, hc.y - hs * 0.45, hc.z - 0.1), power=2.4)  # snout
    for s in (-1, 1):
        m.blob("darkred", (0.1, 0.06, 0.12), (hc.x + s * 0.1, hc.y - hs * 0.6, hc.z - 0.1))
        mp.ear(m, "pig", (hc.x + s * 0.4, hc.y, hc.z + 0.45), (hc.x + s * 0.6, hc.y - 0.1, hc.z + 0.75), width=0.22, inner="cowpink", thick=0.08)
    m.squircle("white", (0.35, 0.05, 0.6), (0, -0.37, p["shoulder_z"] - 0.25), power=4)
    m.box("tie", (0.15, 0.05, 0.55), (0, -0.4, p["shoulder_z"] - 0.3), bevel=0.02)
    m.squircle("screen", (0.2, 0.12, 0.5), (0.62, -0.38, 3.65), power=4)  # the phone at his ear
    for k in range(3):  # ringing arcs
        m.torus("callgreen", 0.25 + k * 0.15, 0.025, (1.0, -0.4, 3.8), rot=(90, 0, 0), scale=(1, 1, 1))
    m.squircle("callgreen", (1.6, 0.1, 0.45), (-1.05, -0.2, 4.25), power=4)
    m.text("white", "JOHN PORK", (-1.05, -0.26, 4.25), size=0.2, depth=0.02)
    return m


def brat_slab():
    m = Meme("BratGreenSlab")
    # a lime-green stone slab with one word in blurry lowercase, on a black plinth
    m.squircle("black", (2.8, 1.2, 0.4), (0, 0, 0.2), power=5)
    m.squircle("brat", (2.6, 0.5, 2.6), (0, 0, 1.75), power=6)
    m.text("black", "brat", (0, -0.27, 1.75), size=0.95, depth=0.06)
    for k in range(6):  # chipped edges
        m.blob("brat", (0.2, 0.2, 0.15), (-1.25 + (k % 3) * 1.25, 0, 0.5 + (k // 3) * 2.5))
    return m


def demure_teacup():
    m = Meme("VeryDemureTeacup")
    # a dainty teacup on a lace doily, pinky out: a tiny porcelain hand holding the handle
    for k in range(18):  # lace doily
        a = k / 18 * math.tau
        m.blob("lace", (0.5, 0.5, 0.06), (math.cos(a) * 1.4, math.sin(a) * 1.4, 0.04))
    m.cyl("lace", 1.4, 0.05, (0, 0, 0.03), seg=36)
    m.lathe("white", [(0, 0.06), (1.1, 0.08), (1.2, 0.2), (1.1, 0.25), (0.4, 0.2), (0, 0.18)], (0, 0, 0), seg=40)  # saucer
    m.torus("gold", 1.15, 0.025, (0, 0, 0.22))
    m.lathe("white", [(0, 0.2), (0.45, 0.22), (0.5, 0.35), (0.9, 1.1), (1.0, 1.6), (0.95, 1.65), (0.85, 1.2), (0, 0.6)], (0, 0, 0), seg=40)  # cup
    m.torus("gold", 0.98, 0.025, (0, 0, 1.6))
    m.cyl("coffee", 0.9, 0.04, (0, 0, 1.5), seg=36)
    for k in range(5):  # little painted flowers
        a = k / 5 * math.tau
        m.blob("pink", (0.15, 0.06, 0.15), (math.cos(a) * 0.95, math.sin(a) * 0.95, 1.2))
    m.torus("white", 0.3, 0.07, (1.15, 0, 1.15), rot=(90, 0, 0))  # handle
    # the dainty hand, pinky out
    m.squircle("skin", (0.35, 0.3, 0.3), (1.45, -0.05, 1.45), power=2.4)
    m.tube("skin", [(1.6, 0.05, 1.5), (1.9, 0.1, 1.9)], 0.09)
    m.squircle("skin", (0.25, 0.08, 0.08), (1.35, -0.2, 1.25), rot=(0, 20, 0), power=2.4)  # pinky out
    m.blob("pink", (0.35, 0.2, 0.15), (0.0, 0.0, 1.95))  # a bow on top of the steam
    for k in range(3):  # steam
        m.tube("white", [(-0.3 + k * 0.3, 0, 1.6), (-0.2 + k * 0.3, 0, 1.9), (-0.35 + k * 0.3, 0, 2.2)], 0.035, seg=6)
    return m


def rizz_mask():
    m = Meme("RizzFaceMask")
    # a theatre mask on a stand: one eyebrow cranked up, lips pressed, the rizz face
    m.cyl("ink", 0.7, 0.12, (0, 0, 0.06), seg=32)
    m.cyl("gold", 0.05, 1.8, (0, 0.1, 1.0), seg=8)
    m.squircle("cream", (1.5, 0.35, 1.9), (0, 0, 2.8), power=2.2)
    m.squircle("tan", (1.55, 0.3, 0.3), (0, 0.06, 3.55), power=3)  # hairline band
    m.eye((-0.32, -0.17, 3.0), (0.32, 0.1, 0.18), iris="black", lid="cream", lid_drop=0.5)
    m.eye((0.32, -0.17, 3.05), (0.32, 0.1, 0.24), iris="black")
    m.box("black", (0.4, 0.08, 0.09), (-0.32, -0.2, 3.2), rot=(0, 5, 0), bevel=0.03)  # flat brow
    m.tube("black", [(0.12, -0.2, 3.3), (0.32, -0.21, 3.45), (0.52, -0.2, 3.35)], 0.04)  # the raised brow
    m.blob("cream", (0.2, 0.15, 0.3), (0, -0.2, 2.75))  # nose
    m.tube("lips", [(-0.25, -0.18, 2.35), (0.0, -0.2, 2.33), (0.25, -0.18, 2.38)], 0.05)  # pressed lips
    m.relief("gold", [(math.cos(a) * 0.12, math.sin(a) * 0.12) for a in [k / 12 * math.tau for k in range(12)]], 0.03, (0.75, -0.1, 3.75))
    m.text("hotpink", "rizz", (0, -0.2, 1.5), size=0.4, depth=0.05)
    return m


def mewing_hush():
    m = Meme("MewingHush")
    # a bust holding one finger to its lips, jaw clenched sharp: don't speak, you'll ruin the jaw
    m.lathe("ink", [(0, 0), (0.75, 0), (0.75, 0.3), (0.55, 0.4), (0.5, 0.55), (0, 0.55)], (0, 0, 0), seg=40)
    m.squircle("skin2", (2.0, 1.1, 1.0), (0, 0, 1.2), power=2.4)
    m.cyl("skin2", 0.33, 0.5, (0, 0, 1.85), seg=16)
    m.squircle("skin2", (1.0, 1.05, 1.25), (0, -0.05, 2.65), power=2.6)
    m.squircle("skin2", (1.1, 0.85, 0.55), (0, -0.2, 2.2), power=4.5)  # sharp jaw
    m.squircle("hairblack", (1.05, 1.08, 0.45), (0, 0.05, 3.2), power=2.4)
    m.blob("hairblack", (0.8, 0.5, 0.25), (0.1, -0.3, 3.35))
    for s in (-1, 1):
        m.eye((s * 0.22, -0.55, 2.75), (0.22, 0.1, 0.18), iris="black", lid="skin2", lid_drop=0.4, look=(0.5, 0))
        m.box("hairblack", (0.28, 0.06, 0.07), (s * 0.22, -0.58, 2.92), rot=(0, s * -12, 0), bevel=0.02)
    m.blob("skin2", (0.16, 0.25, 0.28), (0, -0.62, 2.6))
    m.tube("darkred", [(-0.13, -0.6, 2.32), (0.13, -0.6, 2.33)], 0.03)
    m.tube("skin2", [(0.6, -0.1, 1.5), (0.35, -0.6, 1.8), (0.1, -0.7, 2.1)], 0.15)  # arm up
    m.squircle("skin2", (0.3, 0.25, 0.3), (0.05, -0.72, 2.12), power=2.4)  # fist
    m.squircle("skin2", (0.1, 0.1, 0.45), (0.0, -0.75, 2.4), power=2.5)  # the finger on the lips
    m.text("darkred", "shh", (0.9, -0.5, 3.4), size=0.36, depth=0.04)
    return m


def gta_hourglass():
    m = Meme("BeforeGTA6Hourglass")
    # a grand hourglass whose sand never runs out: everything happens before the next big game
    for z in (0.15, 4.05):
        m.lathe("wood", [(0, 0), (1.05, 0), (1.1, 0.1), (1.05, 0.3), (0, 0.3)], (0, 0, z - 0.15), seg=40)
    for k in range(4):
        a = k / 4 * math.tau + 0.4
        m.lathe("darkbrown", [(0.08, 0), (0.1, 0.2), (0.07, 1.9), (0.1, 3.6), (0.08, 3.8)], (math.cos(a) * 0.9, math.sin(a) * 0.9, 0.15), seg=12)
    for z, r in ((0.4, 0.76), (1.3, 0.62), (2.15, 0.16), (3.0, 0.62), (3.9, 0.76)):  # the glass, drawn as clear rims
        m.torus("glass", r, 0.03, (0, 0, z))
    for k in range(6):
        a = k / 6 * math.tau
        m.tube("glass", [(math.cos(a) * 0.75, math.sin(a) * 0.75, 0.4), (math.cos(a) * 0.62, math.sin(a) * 0.62, 1.3),
                         (math.cos(a) * 0.16, math.sin(a) * 0.16, 2.15), (math.cos(a) * 0.62, math.sin(a) * 0.62, 3.0),
                         (math.cos(a) * 0.75, math.sin(a) * 0.75, 3.9)], 0.015, seg=4)
    m.lathe("tan", [(0, 0.2), (0.7, 0.22), (0.5, 0.85), (0, 1.05)], (0, 0, 0.15), seg=32)  # sand pile below
    m.lathe("tan", [(0, 2.15), (0.08, 2.15), (0.55, 2.9), (0.68, 3.25), (0, 3.25)], (0, 0, 0.15), seg=32)  # sand still above
    m.cyl("tan", 0.03, 1.2, (0, 0, 1.75), seg=6)  # the falling stream
    m.text("hotpink", "VI", (0, -1.1, 4.4), size=0.5, depth=0.06)
    m.text("ink", "not yet", (0, -1.1, 0.5), size=0.24, depth=0.03)
    return m


def king_prawn():
    m = Meme("KingPrawnCrooner")
    # a prawn in a pinstripe suit and fedora, crooning into an old-school microphone
    m.cyl("ink", 1.0, 0.1, (0, 0, 0.05), seg=40)
    for s in (-1, 1):  # little legs
        for k in range(2):
            m.tube("prawn", [(s * (0.15 + k * 0.15), 0, 1.2), (s * (0.25 + k * 0.2), -0.1, 0.6), (s * (0.25 + k * 0.2), 0, 0.12)], 0.06)
    m.squircle("pinstripe", (1.0, 0.75, 1.5), (0, 0, 1.85), power=2.4)  # suit body
    for k in range(4):
        m.box("lightgray", (0.02, 0.02, 1.3), (-0.3 + k * 0.2, -0.38, 1.85), bevel=0)
    m.squircle("white", (0.3, 0.05, 0.5), (0, -0.39, 2.25), power=4)
    m.box("red", (0.12, 0.05, 0.4), (0, -0.41, 2.2), bevel=0.02)
    for k in range(6):  # curled segmented tail behind
        a = k / 5 * 2.2
        m.blob("prawn", (0.45 - k * 0.05, 0.35, 0.3), (0, 0.4 + math.sin(a) * 0.5, 1.2 + math.cos(a) * 0.45))
    m.relief("prawn", [(-0.3, 0), (0.3, 0), (0.0, 0.4)], 0.08, (0, 0.95, 1.4), rot=(0, 0, 0), bevel=0.02)
    m.squircle("prawn", (0.75, 0.8, 0.8), (0, -0.1, 2.95), power=2.3)  # head
    m.cyl("prawn", 0.12, 0.6, (0, -0.65, 3.0), rot=(80, 0, 0), radius2=0.03, seg=10)  # rostrum
    for s in (-1, 1):
        m.eye((s * 0.2, -0.38, 3.2), (0.2, 0.12, 0.2), iris="black", lid="prawn", lid_drop=0.5)  # eyes closed, feeling it
        m.tube("red", [(s * 0.15, -0.3, 3.3), (s * 0.5, -0.5, 4.2), (s * 1.0, -0.4, 4.6)], 0.02, seg=5)  # long antennae
        m.tube("prawn", [(s * 0.45, 0, 2.4), (s * 0.6, -0.4, 2.2), (s * 0.3, -0.65, 2.45) if s > 0 else (s * 0.8, -0.3, 2.9)], 0.08)
    m.lathe("ink", [(0.6, 0), (0.6, 0.04), (0.33, 0.06), (0.32, 0.35), (0, 0.33)], (0, -0.05, 3.25))  # fedora
    m.torus("red", 0.33, 0.04, (0, -0.05, 3.38))
    m.cyl("darkgray", 0.03, 2.4, (0.45, -0.75, 1.2), seg=8)  # mic stand
    m.lathe("steel", [(0, 0), (0.12, 0.02), (0.14, 0.2), (0.1, 0.3), (0, 0.32)], (0.35, -0.75, 2.45))
    m.blob("mouth", (0.25, 0.1, 0.2), (0, -0.48, 2.8))
    for k in range(3):
        m.blob("black", (0.16, 0.08, 0.12), (-1.2 + k * 0.35, -0.3, 3.3 + k * 0.25), rot=(0, -20, 0))
        m.cyl("black", 0.02, 0.35, (-1.13 + k * 0.35, -0.3, 3.47 + k * 0.25), seg=6)
    return m


def aura_boat():
    m = Meme("AuraBoatBow")
    # the bow of a racing boat slicing through waves, a kid striking a pose on it, glowing aura rings
    m.squircle("water", (4.2, 2.4, 0.25), (0, 0, 0.12), power=4)
    for k in range(6):
        m.blob("white", (0.5, 0.3, 0.12), (-1.0 + k * 0.4, -0.95 + (k % 2) * 0.3, 0.28))  # wake
    m.lathe("red", [(0, -1.8), (0.35, -1.3), (0.6, -0.3), (0.65, 0.6), (0.62, 1.4), (0, 1.5)], (0.0, 0, 0.55), rot=(0, 90 + 8, 0),
            seg=24, scale=(0.55, 1.0, 1.0))  # long narrow racing hull, nose up
    m.squircle("white", (2.8, 0.8, 0.1), (0.0, 0, 0.85), rot=(0, -8, 0), power=3)  # deck
    m.lathe("navy", [(0, 0.85), (0.08, 0.85), (0, 1.0)], (0, 0, 0), seg=8)
    # the kid on the bow, one arm out, dancing
    mp.person(m, skin="skin2", shirt="black", pants="black", shoes="white", hair="hairblack", hair_style="short",
              height=0.5, build=0.55, head=0.55, expr="flat", z=0.95, x=-0.9, sole=None, face_kw={"lids": 0.3},
              arms={"l": ((-0.42, -0.1, 1.2), (-0.65, -0.15, 1.45)), "r": ((0.42, -0.1, 1.05), (0.55, -0.25, 0.85))})
    m.squircle("black", (0.35, 0.1, 0.1), (-0.9, -0.3, 2.3), power=4)  # shades
    for k in range(3):  # the aura: glowing rings rising off him
        m.torus("aura", 0.45 + k * 0.3, 0.04, (-0.9, 0, 1.8 + k * 0.6), scale=(1, 0.7, 1))
    for k in range(8):
        a = k / 8 * math.tau
        m.blob("aura", (0.1, 0.1, 0.1), (-0.9 + math.cos(a) * 0.9, math.sin(a) * 0.6, 3.5 + (k % 2) * 0.3))
    m.text("aura", "+1000 AURA", (0.6, -0.6, 4.2), size=0.3, depth=0.04)
    return m


ALL = [girl_dinner, roman_empire_bust, orca_boat, john_pork_phone, brat_slab, demure_teacup, rizz_mask, mewing_hush,
       gta_hourglass, king_prawn, aura_boat]
