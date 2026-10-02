"""Batch 7 of the meme sculptures: World 3.
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp

for _name, _c in [
    ("swan", (250, 250, 248)), ("canal", (70, 150, 160)), ("gondola", (30, 30, 40)), ("lectern", (120, 80, 50)),
    ("mittenbrown", (140, 100, 70)), ("sourdough", (205, 140, 70)), ("crust", (150, 90, 40)), ("flour", (250, 248, 240)),
    ("starter", (240, 230, 200)), ("coingold", (240, 195, 70)), ("coindark", (190, 140, 40)), ("coffin", (90, 55, 35)),
    ("bean1", (255, 150, 200)), ("bean2", (120, 220, 255)), ("goggle", (255, 255, 255)), ("shiba", (225, 160, 80)),
    ("shibacream", (250, 235, 210)), ("armchair", (120, 140, 90)), ("partyhat", (255, 90, 160)), ("wall", (235, 225, 205)),
    ("capred", (220, 40, 50)), ("hairgreen", (60, 200, 150)), ("arrowL", (200, 80, 255)), ("arrowD", (60, 220, 255)),
    ("arrowU", (60, 230, 90)), ("arrowR", (255, 70, 70)), ("parchment", (240, 225, 180)), ("scrollwood", (130, 85, 45)),
    ("heroviolet", (110, 70, 200)), ("cape", (200, 40, 60)), ("sunset", (255, 120, 60)), ("rockgray", (110, 105, 100)),
    ("heart", (230, 50, 80)), ("bandage", (245, 220, 180)),
]:
    rgb(_name, *_c)


def nature_healing_swan():
    m = Meme("NatureHealingSwan")
    # a swan gliding down a clear canal past a striped mooring pole: nature is healing
    m.squircle("canal", (4.0, 2.6, 0.25), (0, 0, 0.12), power=4)
    for k in range(6):
        m.blob("sky", (0.5, 0.2, 0.06), (-1.6 + k * 0.65, -0.9 + (k % 3) * 0.8, 0.26))
    m.blob("swan", (2.0, 1.2, 1.0), (-0.2, 0, 0.75))  # body
    m.blob("swan", (1.0, 1.1, 0.7), (0.65, 0, 1.05), rot=(0, -30, 0))  # raised tail feathers
    for s in (-1, 1):
        m.blob("swan", (1.5, 0.35, 0.75), (0.0, s * 0.45, 1.05), rot=(s * 15, -15, 0))  # folded wings
    m.tube("swan", [(-0.85, 0, 1.0), (-1.15, 0, 1.7), (-1.05, 0, 2.4), (-1.3, 0, 2.75)], lambda t: 0.22 - 0.08 * t, seg=14)
    m.blob("swan", (0.45, 0.38, 0.36), (-1.35, 0, 2.8))  # head
    m.cyl("orange", 0.1, 0.4, (-1.65, 0, 2.72), rot=(0, -100, 0), radius2=0.04, seg=10)  # beak
    m.blob("black", (0.16, 0.42, 0.18), (-1.48, 0, 2.78))  # face mask
    for s in (-1, 1):
        m.blob("black", (0.08, 0.04, 0.08), (-1.4, s * 0.19, 2.86))
    # the striped gondola pole and a tiny heart of "healing"
    m.cyl("white", 0.1, 3.8, (1.5, 0.7, 1.9), seg=12)
    for k in range(5):
        m.cyl("navy", 0.11, 0.3, (1.5, 0.7, 0.6 + k * 0.7), seg=12)
    m.blob("gold", (0.25, 0.25, 0.25), (1.5, 0.7, 3.85))
    m.relief("heart", [(0.27 * math.sin(t) ** 3, 0.22 * math.cos(t) - 0.09 * math.cos(2 * t) - 0.04 * math.cos(3 * t))
                       for t in [i / 24 * math.tau for i in range(24)]], 0.08, (-0.3, -0.2, 3.3))
    return m


def once_again_lectern():
    m = Meme("OnceAgainLectern")
    # a campaign lectern with a pair of cozy mittens resting on it and its famous request
    m.squircle("lectern", (1.9, 1.3, 2.8), (0, 0, 1.4), power=5)
    m.squircle("lectern", (2.3, 1.6, 0.18), (0, -0.1, 2.9), rot=(-15, 0, 0), power=5)  # slanted top
    m.squircle("navy", (1.5, 0.08, 1.8), (0, -0.67, 1.5), power=6)  # front panel
    m.text("white", "ONCE", (0, -0.73, 2.0), size=0.3, depth=0.03)
    m.text("white", "AGAIN", (0, -0.73, 1.6), size=0.3, depth=0.03)
    m.text("sticker1", "ASKING", (0, -0.73, 1.2), size=0.26, depth=0.03)
    for s in (-1, 1):  # the mittens, thumbs up
        m.squircle("mittenbrown", (0.55, 0.75, 0.32), (s * 0.5, -0.2, 3.15), rot=(-15, 0, s * 10), power=2.4)
        m.squircle("mittenbrown", (0.2, 0.3, 0.3), (s * 0.82, -0.32, 3.3), rot=(-15, 0, s * 30), power=2.4)
        for k in range(3):
            m.box("cream", (0.04, 0.6, 0.05), (s * 0.5 + (k - 1) * 0.12, -0.2, 3.32), rot=(-15, 0, s * 10), bevel=0.01)
        m.squircle("white", (0.57, 0.2, 0.34), (s * 0.5, 0.15, 3.05), rot=(-15, 0, s * 10), power=3)  # cuff
    m.cyl("black", 0.03, 0.9, (0, -0.4, 3.4), rot=(30, 0, 0), seg=8)  # mic
    m.squircle("black", (0.14, 0.18, 0.22), (0, -0.65, 3.8), power=2.4)
    return m


def lockdown_sourdough():
    m = Meme("LockdownSourdough")
    # a proud lockdown sourdough on a cutting board, with its bubbly starter jar
    m.squircle("lightwood", (3.4, 2.2, 0.22), (0, 0, 0.11), power=6)
    m.blob("lightwood", (0.4, 0.15, 0.2), (1.85, 0, 0.12))  # handle
    m.squircle("sourdough", (2.4, 1.8, 1.5), (-0.3, 0, 0.95), power=2.1)  # the loaf
    m.squircle("crust", (2.42, 1.82, 0.6), (-0.3, 0, 0.5), power=2.2)
    for k in range(3):  # score marks with flour dusting
        m.tube("flour", [(-1.0 + k * 0.6, -0.55, 1.55), (-0.7 + k * 0.6, 0.0, 1.72), (-0.4 + k * 0.6, 0.55, 1.55)], 0.06)
    for k in range(10):
        m.blob("flour", (0.1, 0.1, 0.03), (-1.0 + (k * 0.37) % 1.6, -0.6 + (k * 0.53) % 1.2, 1.62))
    # starter jar with bubbles and a rubber band marking the rise
    m.lathe("glass", [(0, 0), (0.45, 0), (0.48, 0.1), (0.48, 1.6), (0.4, 1.7), (0, 1.7)], (1.3, 0.3, 0.22), seg=32)
    m.lathe("starter", [(0, 0), (0.43, 0), (0.44, 1.1), (0.3, 1.18), (0, 1.15)], (1.3, 0.3, 0.25), seg=32)
    m.torus("red", 0.48, 0.03, (1.3, 0.3, 1.0))
    for k in range(6):
        m.blob("white", (0.08, 0.08, 0.08), (1.3 + math.cos(k * 1.3) * 0.35, 0.3 + math.sin(k * 1.3) * 0.35, 0.6 + k * 0.1))
    m.lathe("gray", [(0, 1.7), (0.5, 1.7), (0.5, 1.85), (0, 1.88)], (1.3, 0.3, 0.22))
    m.text("darkbrown", "DAY 47", (1.3, -0.18, 1.3), size=0.14, depth=0.02)
    return m


def pallbearer_coin():
    m = Meme("PallbearerCoin")
    # a big gold coin on a stand, stamped with four dancing pallbearers carrying a coffin
    m.squircle("darkgray", (1.8, 1.0, 0.25), (0, 0.1, 0.12), power=4)
    for s in (-1, 1):
        m.box("darkgray", (0.2, 0.3, 0.9), (s * 0.85, 0.1, 0.65), bevel=0.04)
    m.cyl("coingold", 1.7, 0.3, (0, 0, 2.1), rot=(90, 0, 0), seg=64)
    m.torus("coindark", 1.55, 0.07, (0, -0.15, 2.1), rot=(90, 0, 0))
    for k in range(48):  # milled edge
        a = k / 48 * math.tau
        m.box("coindark", (0.05, 0.3, 0.06), (math.cos(a) * 1.7, 0, 2.1 + math.sin(a) * 1.7), rot=(0, -math.degrees(a), 0), bevel=0)
    y = -0.2
    m.box("coindark", (1.6, 0.08, 0.35), (0, y, 2.55), bevel=0.04)  # the coffin
    for k in range(4):  # four little dancers under it
        x = -0.6 + k * 0.4
        m.blob("coindark", (0.2, 0.08, 0.22), (x, y, 2.2))
        m.box("coindark", (0.18, 0.08, 0.35), (x, y, 1.9), bevel=0.04)
        m.tube("coindark", [(x - 0.05, y, 1.72), (x - 0.12, y, 1.4)], 0.04)
        m.tube("coindark", [(x + 0.05, y, 1.72), (x + 0.14 * (1 if k % 2 else -1), y, 1.45)], 0.04)
        m.tube("coindark", [(x + 0.1, y, 2.0), (x + 0.12, y, 2.42)], 0.035)
    m.text("coindark", "DANCE ON", (0, y, 1.0), size=0.28, depth=0.04)
    for k in range(5):
        a = math.radians(30 + k * 30)
        m.blob("coindark", (0.1, 0.06, 0.1), (math.cos(a) * 1.3, y, 2.1 + math.sin(a) * 1.3))  # stars round the rim
    return m


def tumble_jelly_bean():
    m = Meme("TumbleJellyBean")
    # a jelly bean contestant mid-tumble off an obstacle, arms flailing, still grinning
    m.squircle("bean2", (3.0, 1.6, 0.4), (0.3, 0.2, 0.2), power=3)  # obstacle platform
    for k in range(4):
        m.box("yellow" if k % 2 else "white", (0.7, 1.62, 0.06), (-0.75 + k * 0.7, 0.2, 0.42), bevel=0)
    tilt = 35
    m.squircle("bean1", (1.4, 1.2, 2.4), (-0.3, -0.1, 2.0), rot=(0, tilt, 0), power=2.0)  # bean body tipping over
    m.squircle("goggle", (1.0, 0.4, 0.75), (-0.55, -0.62, 2.4), rot=(0, tilt, 0), power=2.4)  # face visor
    for s in (-1, 1):
        m.blob("black", (0.18, 0.06, 0.22), (-0.55 + s * 0.2 * math.cos(math.radians(tilt)), -0.82, 2.45 - s * 0.12))
    m.tube("mouth", [(-0.85, -0.82, 2.35), (-0.6, -0.84, 2.15), (-0.35, -0.82, 2.2)], 0.03)
    for s, pts in ((-1, [(-0.9, 0, 2.6), (-1.5, -0.2, 3.3), (-1.6, -0.3, 3.9)]), (1, [(0.2, 0, 2.6), (0.9, -0.2, 3.2), (1.3, -0.3, 3.6)])):
        m.tube("bean1", pts, 0.13)
        m.blob("bean1", (0.26, 0.26, 0.26), pts[-1])
    m.tube("bean1", [(0.0, 0, 1.2), (0.5, -0.1, 0.9), (0.8, -0.1, 0.55)], 0.14)  # legs kicking
    m.tube("bean1", [(-0.5, 0, 1.0), (-0.6, -0.1, 0.6)], 0.14)
    for k in range(4):  # little stars of dizziness
        a = k / 4 * math.tau
        m.relief("sticker1", [(math.cos(math.pi / 2 + i * math.pi / 5) * (0.15 if i % 2 == 0 else 0.06),
                               math.sin(math.pi / 2 + i * math.pi / 5) * (0.15 if i % 2 == 0 else 0.06)) for i in range(10)],
                 0.04, (-0.9 + math.cos(a) * 0.6, -0.3, 3.7 + math.sin(a) * 0.2))
    return m


def shiba(m, x, y, scale, buff=False, sad=False, sitting=False):
    """A shiba dog standing on its hind legs (buff) or sitting (small and sad)."""
    s_ = scale
    if buff:
        for s in (-1, 1):
            m.tube("shiba", [(x + s * 0.35 * s_, y, 1.6 * s_), (x + s * 0.4 * s_, y - 0.1, 0.9 * s_), (x + s * 0.4 * s_, y, 0.2 * s_)], 0.22 * s_)
            m.squircle("shibacream", (0.4 * s_, 0.55 * s_, 0.25 * s_), (x + s * 0.4 * s_, y - 0.1, 0.12 * s_), power=2.5)
        m.squircle("shiba", (1.9 * s_, 1.1 * s_, 1.8 * s_), (x, y, 2.5 * s_), power=2.3)  # huge chest
        m.blob("shibacream", (1.2 * s_, 0.5 * s_, 1.2 * s_), (x, y - 0.4 * s_, 2.45 * s_))
        for s in (-1, 1):
            m.blob("shibacream", (0.5 * s_, 0.2 * s_, 0.4 * s_), (x + s * 0.3 * s_, y - 0.62 * s_, 2.9 * s_))  # pecs
            m.blob("shiba", (0.9 * s_, 0.9 * s_, 0.8 * s_), (x + s * 1.05 * s_, y, 3.05 * s_))  # shoulders
            m.tube("shiba", [(x + s * 1.2 * s_, y, 2.9 * s_), (x + s * 1.55 * s_, y - 0.2 * s_, 3.5 * s_), (x + s * 1.15 * s_, y - 0.3 * s_, 4.1 * s_)],
                   lambda t: (0.36 - 0.1 * t) * s_)  # flexing arms
            m.blob("shiba", (0.65 * s_, 0.6 * s_, 0.6 * s_), (x + s * 1.5 * s_, y - 0.2 * s_, 3.6 * s_))  # biceps
        hz = 3.85 * s_
    else:
        m.squircle("shiba", (1.1 * s_, 1.3 * s_, 1.1 * s_), (x, y + 0.15 * s_, 0.6 * s_), power=2.2)
        m.blob("shibacream", (0.7 * s_, 0.4 * s_, 0.8 * s_), (x, y - 0.4 * s_, 0.6 * s_))
        for s in (-1, 1):
            m.squircle("shibacream", (0.28 * s_, 0.5 * s_, 0.2 * s_), (x + s * 0.25 * s_, y - 0.45 * s_, 0.1 * s_), power=2.5)
        m.tube("shiba", [(x + 0.4 * s_, y + 0.6 * s_, 0.6 * s_), (x + 0.7 * s_, y + 0.7 * s_, 1.0 * s_), (x + 0.5 * s_, y + 0.6 * s_, 1.2 * s_)], 0.12 * s_)
        hz = 1.45 * s_
    m.squircle("shiba", (1.1 * s_, 1.0 * s_, 0.95 * s_), (x, y - 0.1 * s_, hz), power=2.3)  # head
    m.blob("shibacream", (0.75 * s_, 0.6 * s_, 0.45 * s_), (x, y - 0.5 * s_, hz - 0.2 * s_))  # muzzle
    m.blob("black", (0.18 * s_, 0.12 * s_, 0.12 * s_), (x, y - 0.82 * s_, hz - 0.08 * s_))
    for s in (-1, 1):
        mp.ear(m, "shiba", (x + s * 0.32 * s_, y, hz + 0.35 * s_), (x + s * 0.45 * s_, y, hz + 0.8 * s_), width=0.22 * s_, inner="shibacream", thick=0.08 * s_)
        m.blob("shibacream", (0.18 * s_, 0.08 * s_, 0.1 * s_), (x + s * 0.24 * s_, y - 0.48 * s_, hz + 0.25 * s_))  # brows
        m.eye((x + s * 0.24 * s_, y - 0.5 * s_, hz + 0.08 * s_), (0.18 * s_, 0.1 * s_, 0.2 * s_), iris="black", lid="shiba" if buff else None, lid_drop=0.4)
        if sad:
            m.blob("sky", (0.08 * s_, 0.05 * s_, 0.25 * s_), (x + s * 0.28 * s_, y - 0.56 * s_, hz - 0.1 * s_))  # tears
    if sad:
        m.tube("mouth", [(x - 0.15 * s_, y - 0.78 * s_, hz - 0.35 * s_), (x, y - 0.8 * s_, hz - 0.3 * s_), (x + 0.15 * s_, y - 0.78 * s_, hz - 0.35 * s_)], 0.025 * s_)
    else:
        m.tube("mouth", [(x - 0.18 * s_, y - 0.78 * s_, hz - 0.3 * s_), (x, y - 0.8 * s_, hz - 0.36 * s_), (x + 0.18 * s_, y - 0.78 * s_, hz - 0.28 * s_)], 0.025 * s_)


def swole_vs_smol():
    m = Meme("SwoleVsSmol")
    # a towering, flexing shiba next to a tiny teary one
    m.squircle("green", (4.2, 2.0, 0.12), (0, 0, 0.06), power=4)
    shiba(m, -0.75, 0.0, 1.0, buff=True)
    shiba(m, 1.45, -0.2, 0.75, sad=True)
    return m


def pointing_laugh_chair():
    m = Meme("PointingLaughChair")
    # someone sunk deep into an armchair, pointing at the TV and laughing their head off
    m.squircle("armchair", (2.6, 1.9, 1.1), (0, 0.15, 0.75), power=3)
    m.squircle("armchair", (2.6, 0.6, 2.6), (0, 0.95, 1.6), power=3)
    for s in (-1, 1):
        m.squircle("armchair", (0.55, 1.9, 1.5), (s * 1.3, 0.15, 1.15), power=3)
    p = mp.person(m, skin="skin", shirt="red", pants="jeans", hair="hairgray", hair_style="short", sitting=True, y=0.0,
                  expr="open", face_kw={"lids": 0.55, "brow_tilt": -0.4},
                  arms={"r": ((0.8, -0.6, 2.6), (0.9, -1.4, 2.85)), "l": ((-0.85, -0.2, 2.2), (-0.55, -0.45, 1.95))})
    m.box("skin", (0.07, 0.3, 0.07), (0.92, -1.65, 2.87), bevel=0.03)  # pointing finger
    for k in range(3):
        m.text("orange", "HA", (-1.2 + k * 0.5, -0.4, 4.4 + k * 0.25), size=0.32, depth=0.05)
    m.blob("sky", (0.12, 0.05, 0.25), (p["head"].x - 0.42, p["head"].y - 0.55, p["head"].z))  # tears of laughter
    return m


def party_corner_guy():
    m = Meme("PartyCornerGuy")
    # a framed party scene: everyone dances in the middle, one guy in a party hat stands in the
    # corner with a drink, smugly knowing something they don't
    m.squircle("gold", (3.4, 0.22, 2.8), (0, 0, 2.55), power=8)
    m.squircle("purple", (3.0, 0.2, 2.4), (0, -0.04, 2.55), power=10)
    m.squircle("navy", (3.0, 0.21, 0.5), (0, -0.05, 1.6), power=10)  # dance floor
    for sx in (-1, 1):
        m.cyl("wood", 0.07, 4.2, (sx * 1.0, 0.35, 2.0), rot=(-8, sx * 12, 0), seg=8)
    m.cyl("wood", 0.07, 4.0, (0, 0.9, 1.9), rot=(25, 0, 0), seg=8)
    m.box("wood", (2.8, 0.3, 0.12), (0, -0.1, 1.2), bevel=0.03)
    y = -0.2
    for k, c in enumerate(("red", "sky", "lime", "orange", "pink")):  # crowd silhouettes dancing
        x = -0.3 + k * 0.32
        m.blob(c, (0.22, 0.1, 0.24), (x, y, 2.55 + (k % 2) * 0.08))
        m.squircle(c, (0.26, 0.1, 0.5), (x, y, 2.15 + (k % 2) * 0.05), power=2.4)
        m.tube(c, [(x, y, 2.3), (x + 0.15 * (1 if k % 2 else -1), y, 2.7)], 0.03)
    # the guy in the corner
    m.squircle("ink", (0.36, 0.1, 0.65), (-1.15, y, 2.15), power=2.4)
    m.blob("skin", (0.3, 0.1, 0.32), (-1.15, y, 2.65))
    m.cyl("partyhat", 0.13, 0.35, (-1.15, y, 2.95), radius2=0.0, seg=12)
    m.cyl("red", 0.06, 0.15, (-0.95, y - 0.04, 2.3), seg=10)  # cup
    for k, (dx, dz, r) in enumerate([(0.25, 0.35, 0.05), (0.4, 0.5, 0.07)]):
        m.blob("white", (r * 2, 0.05, r * 2), (-1.15 + dx, y - 0.02, 2.65 + dz))
    m.blob("white", (0.85, 0.06, 0.4), (-0.6, y - 0.02, 3.35))  # thought bubble
    m.text("ink", "they don't know", (-0.6, y - 0.06, 3.35), size=0.11, depth=0.02)
    for k in range(6):  # disco lights
        m.blob(("sticker1", "sticker2", "sticker3")[k % 3], (0.1, 0.05, 0.1), (-1.2 + k * 0.48, y, 3.55))
    return m


def beep_bop_mic_kid():
    m = Meme("BeepBopMicKid")
    # a rhythm-game kid with a backwards cap and a mic, the four arrows floating over him
    p = mp.person(m, skin="skin", shirt="white", pants="sky", shoes="capred", hair="hairgreen", hair_style="spiky",
                  height=0.85, head=1.15, expr="grin",
                  arms={"r": ((0.85, -0.3, 2.3), (0.55, -0.6, 2.75)), "l": ((-0.85, 0.0, 2.2), (-1.05, -0.2, 1.7))})
    hc, hs = p["head"], p["head_size"]
    m.squircle("capred", (hs * 0.92, hs * 0.9, hs * 0.4), (hc.x, hc.y + 0.05, hc.z + hs * 0.35), power=2.2)  # cap
    m.squircle("capred", (hs * 0.55, hs * 0.5, 0.06), (hc.x, hc.y + hs * 0.6, hc.z + hs * 0.3), power=4)  # backwards brim
    m.cyl("black", 0.06, 0.4, (0.55, -0.7, 2.95), rot=(20, 0, 0), seg=10)  # mic
    m.blob("darkgray", (0.22, 0.22, 0.22), (0.55, -0.78, 3.17))
    arrows = [("arrowL", 90), ("arrowD", 180), ("arrowU", 0), ("arrowR", -90)]
    for k, (c, rot) in enumerate(arrows):
        pts = [(0, 0.32), (0.3, 0.02), (0.12, 0.02), (0.12, -0.3), (-0.12, -0.3), (-0.12, 0.02), (-0.3, 0.02)]
        a = math.radians(rot)
        pts = [(x * math.cos(a) - z * math.sin(a), x * math.sin(a) + z * math.cos(a)) for x, z in pts]
        m.relief(c, pts, 0.15, (-1.2 + k * 0.8, 0.0, 4.6), bevel=0.04)
    return m


def trade_offer_scroll():
    m = Meme("TradeOfferScroll")
    # an unrolled parchment scroll on a little stand: the famous lopsided trade offer
    m.squircle("darkgray", (2.4, 0.9, 0.2), (0, 0.2, 0.1), power=4)
    for s in (-1, 1):
        m.cyl("scrollwood", 0.05, 1.0, (s * 1.0, 0.2, 0.6), seg=8)
    m.squircle("parchment", (2.6, 0.05, 2.8), (0, 0, 2.5), rot=(-6, 0, 0), power=8)
    for z in (1.1, 3.9):  # rolled ends
        m.cyl("parchment", 0.2, 2.9, (0, 0.05 if z > 2 else -0.08, z), rot=(0, 90, 0), seg=20)
        for s in (-1, 1):
            m.cyl("scrollwood", 0.1, 0.3, (s * 1.55, 0.05 if z > 2 else -0.08, z), rot=(0, 90, 0), seg=12)
            m.blob("gold", (0.18, 0.18, 0.18), (s * 1.72, 0.05 if z > 2 else -0.08, z))
    y = -0.12
    m.text("darkred", "TRADE OFFER", (0, y, 3.35), size=0.34, depth=0.03)
    m.box("darkbrown", (2.0, 0.02, 0.03), (0, y, 3.12), bevel=0)
    m.text("ink", "i receive:", (-0.55, y, 2.8), size=0.18, depth=0.02)
    m.text("ink", "your meme", (-0.55, y, 2.55), size=0.18, depth=0.02)
    m.text("ink", "you receive:", (0.55, y + 0.02, 2.0), size=0.18, depth=0.02)
    m.text("ink", "nothing", (0.55, y + 0.02, 1.75), size=0.18, depth=0.02)
    m.cyl("red", 0.22, 0.05, (0.9, y - 0.02, 2.7), rot=(90, 0, 0), seg=20)  # wax seal
    m.text("gold", "$", (0.9, y - 0.05, 2.7), size=0.22, depth=0.02)
    return m


def think_son_think():
    m = Meme("ThinkSonThink")
    # a mustached superhero dad in a violet suit and red cape, fist raised, shouting a lesson
    p = mp.person(m, skin="skin", shirt="heroviolet", pants="heroviolet", shoes="lightgray", hair="hairblack", hair_style="slick",
                  build=1.2, belly=1.0, expr="scream", sole=None, face_kw={"brow_tilt": 0.7},
                  arms={"r": ((1.1, -0.4, 3.0), (0.95, -0.9, 3.5)), "l": ((-1.0, -0.3, 2.4), (-0.75, -0.75, 2.1))})
    hc, hs = p["head"], p["head_size"]
    m.blob("hairblack", (0.65, 0.12, 0.14), (hc.x, hc.y - hs * 0.45, hc.z - hs * 0.12))  # big mustache
    m.squircle("lightgray", (1.25, 0.7, 0.3), (0, -0.05, p["shoulder_z"] + 0.05), power=3)  # silver collar
    m.relief("lightgray", [(-0.3, 0), (0.3, 0), (0.0, -0.35)], 0.05, (0, -0.38, 2.75))  # chest emblem
    m.squircle("cape", (1.6, 0.15, 2.8), (0, 0.45, 2.2), rot=(8, 0, 0), power=3)  # cape
    m.text("red", "THINK!", (0, -0.4, 4.85), size=0.45, depth=0.06)
    return m


def sigma_grindset():
    m = Meme("SigmaGrindset")
    # a lone man in a long coat on a rock, arms crossed, staring into a huge sunset
    m.cyl("sunset", 1.9, 0.1, (0, 1.0, 2.6), rot=(90, 0, 0), seg=48)  # the huge sun behind him
    m.cyl("yellow", 1.3, 0.12, (0, 0.95, 2.6), rot=(90, 0, 0), seg=48)
    for k in range(3):
        m.box("sunset", (4.2 - k * 0.6, 0.08, 0.1), (0, 1.0, 0.95 + k * 0.25), bevel=0)  # horizon stripes
    m.squircle("rockgray", (2.6, 2.0, 1.0), (0, 0, 0.45), power=2.2)
    m.blob("darkgray", (1.2, 1.0, 0.6), (0.7, -0.2, 0.75))
    mp.person(m, skin="skin", shirt="ink", pants="ink", shoes="black", hair="hairblack", hair_style="slick",
              y=0.0, expr="flat", sole=None, face_kw={"lids": 0.4, "brow_tilt": 0.4},
              legs={-1: ((-0.3, 0.0, 1.5), (-0.32, 0.0, 0.95)), 1: ((0.3, 0.0, 1.5), (0.32, 0.0, 0.95))},
              arms={"l": ((-0.65, -0.35, 2.7), (0.2, -0.45, 2.75)), "r": ((0.65, -0.35, 2.65), (-0.2, -0.45, 2.7))})
    m.squircle("ink", (1.15, 0.75, 1.6), (0, 0, 2.2), power=2.6)  # long coat
    return m


def emotional_damage():
    m = Meme("EmotionalDamage")
    # a big red heart cracked down the middle, a bandage holding it together, on a little stand
    m.lathe("darkgray", [(0, 0), (0.9, 0), (0.9, 0.15), (0.4, 0.3), (0.3, 0.9), (0, 0.9)], (0, 0, 0))
    heart = [(1.3 * math.sin(t) ** 3, 1.05 * math.cos(t) - 0.42 * math.cos(2 * t) - 0.18 * math.cos(3 * t) - 0.08 * math.cos(4 * t))
             for t in [i / 48 * math.tau for i in range(48)]]
    left = [(x, z) for x, z in heart if x <= 0.02] + [(0.1, -0.2), (-0.1, 0.3), (0.05, 0.75)]
    right = [(x, z) for x, z in heart if x >= -0.02] + [(0.15, 0.75), (-0.0, 0.3), (0.2, -0.2)]
    m.relief("heart", left, 0.7, (-0.12, 0, 2.6), rot=(0, 0, 0), bevel=0.15, smooth=True)
    m.relief("heart", right, 0.7, (0.12, 0, 2.55), rot=(0, -8, 0), bevel=0.15, smooth=True)
    m.squircle("bandage", (1.2, 0.8, 0.35), (0, 0, 2.6), rot=(0, 30, 0), power=4)
    for k in range(4):
        m.blob("crust", (0.05, 0.05, 0.05), (-0.25 + k * 0.17, -0.42, 2.6 - 0.1 + k * 0.1 * 0.58))
    m.text("ink", "EMOTIONAL", (0, -0.6, 4.55), size=0.3, depth=0.05)
    m.text("red", "DAMAGE!", (0, -0.6, 4.1), size=0.38, depth=0.05)
    return m


ALL = [nature_healing_swan, once_again_lectern, lockdown_sourdough, pallbearer_coin, tumble_jelly_bean, swole_vs_smol,
       pointing_laugh_chair, party_corner_guy, beep_bop_mic_kid, trade_offer_scroll, think_son_think, sigma_grindset,
       emotional_damage]
