"""Batch 12 of the meme sculptures: World 8 (the cyber/cosmic world).
Many are themed upgrades of earlier memes: the base meme is built, recolored and given extras.
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp
from memes_batch1 import birthday_shake, chill_dude
from memes_batch2 import jawline_chad, polka_cow, stonks_head, sus_bean
from memes_batch5 import shocked_rodent
from memes_batch6 import space_infant
from memes_batch11 import wow_shiba

for _name, _c in [
    ("circuit", (0, 255, 170)), ("chrome", (210, 215, 225)), ("chromedark", (130, 135, 150)), ("led", (255, 40, 60)),
    ("voidpurple", (45, 20, 70)), ("voidglow", (190, 90, 255)), ("starwhite", (255, 255, 240)), ("holo", (120, 230, 255)),
    ("holodark", (40, 140, 200)), ("neonpink", (255, 50, 190)), ("nebula2", (90, 60, 200)), ("planet2", (90, 170, 120)),
    ("portal1", (90, 255, 120)), ("portal2", (30, 160, 80)), ("ogre", (130, 170, 60)), ("ogredark", (90, 120, 40)),
    ("gnomered", (220, 40, 50)), ("beard", (245, 245, 245)), ("gnomeblue", (60, 90, 200)), ("goldbright", (255, 215, 80)),
    ("golddeep", (200, 150, 40)), ("toorng", (25, 20, 35)), ("dice", (250, 250, 250)), ("pip", (20, 20, 25)),
    ("felt", (30, 120, 70)), ("overlord", (60, 20, 90)), ("cloak", (35, 15, 55)), ("crowngold", (255, 200, 50)),
    ("bulletgold", (220, 170, 60)), ("trail", (200, 230, 255)), ("froggold", (240, 190, 60)), ("planetring", (255, 210, 140)), ("snow", (250, 252, 255)),
]:
    rgb(_name, *_c)


def stars(m, n, box, color="starwhite", size=0.12, seed=1):
    (x0, x1), (y0, y1), (z0, z1) = box
    for k in range(n):
        u = (math.sin(k * 12.9898 + seed) * 43758.5453) % 1
        v = (math.sin(k * 78.233 + seed) * 12345.678) % 1
        w = (math.sin(k * 39.425 + seed) * 9876.543) % 1
        p = (x0 + (x1 - x0) * u, y0 + (y1 - y0) * v, z0 + (z1 - z0) * w)
        m.relief(color, [(0, size), (size * 0.25, size * 0.25), (size, 0), (size * 0.25, -size * 0.25), (0, -size),
                         (-size * 0.25, -size * 0.25), (-size, 0), (-size * 0.25, size * 0.25)], 0.03, p, bevel=0)


def swamp_frog(m, color="frog", light="froglight", x=0.0, y=0.0, z=0.0, scale=1.0, cheeks="blush"):
    """An original round frog sitting up: bulgy eyes on top, wide smile, a pale belly."""
    k = scale
    m.squircle(color, (2.0 * k, 1.6 * k, 1.7 * k), (x, y, z + 1.0 * k), power=2.1)  # body
    m.blob(light, (1.3 * k, 0.6 * k, 1.1 * k), (x, y - 0.55 * k, z + 0.9 * k))  # belly
    m.squircle(color, (2.1 * k, 1.6 * k, 1.2 * k), (x, y - 0.1 * k, z + 2.15 * k), power=2.3)  # head
    for s in (-1, 1):
        m.blob(color, (0.75 * k, 0.7 * k, 0.7 * k), (x + s * 0.55 * k, y - 0.25 * k, z + 2.7 * k))  # eye bumps
        m.eye((x + s * 0.55 * k, y - 0.52 * k, z + 2.75 * k), (0.5 * k, 0.3 * k, 0.5 * k), iris="black")
        if cheeks:
            m.blob(cheeks, (0.3 * k, 0.06 * k, 0.15 * k), (x + s * 0.7 * k, y - 0.82 * k, z + 2.0 * k))
        m.squircle(color, (0.6 * k, 0.9 * k, 0.3 * k), (x + s * 0.75 * k, y - 0.55 * k, z + 0.15 * k), power=2.5)  # feet
        for f in range(3):
            m.blob(light, (0.16 * k, 0.16 * k, 0.12 * k), (x + s * 0.75 * k + (f - 1) * 0.2 * k, y - 1.0 * k, z + 0.17 * k))
        m.tube(color, [(x + s * 0.85 * k, y - 0.3 * k, z + 1.5 * k), (x + s * 0.7 * k, y - 0.75 * k, z + 1.0 * k)], 0.15 * k)
    m.tube("mouth", [(x - 0.55 * k, y - 0.82 * k, z + 2.05 * k), (x, y - 0.88 * k, z + 1.92 * k), (x + 0.55 * k, y - 0.82 * k, z + 2.05 * k)], 0.035 * k)
    return m


def throne(m, body="chrome", trim="chromedark", eyes="led", x=0.0, scale=1.0):
    """A singing toilet throne: bowl, tank, lid raised with LED eyes and a speaker-grille mouth."""
    k = scale
    m.lathe(body, [(0, 0), (0.55 * k, 0), (0.6 * k, 0.5 * k), (0.95 * k, 1.2 * k), (1.0 * k, 1.45 * k), (0, 1.45 * k)], (x, 0, 0), seg=40)
    m.torus(trim, 0.88 * k, 0.1 * k, (x, -0.05 * k, 1.5 * k), scale=(1, 1.15, 1))  # seat
    m.squircle(body, (1.6 * k, 0.6 * k, 1.4 * k), (x, 0.85 * k, 2.1 * k), power=5)  # tank
    m.squircle(body, (1.8 * k, 0.12 * k, 2.0 * k), (x, 0.55 * k, 2.55 * k), rot=(-8, 0, 0), power=3)  # raised lid = face
    for s in (-1, 1):
        m.blob(eyes, (0.4 * k, 0.1 * k, 0.28 * k), (x + s * 0.4 * k, 0.45 * k, 3.0 * k))
        m.blob("white", (0.12 * k, 0.05 * k, 0.1 * k), (x + s * 0.4 * k + 0.08 * k, 0.4 * k, 3.05 * k))
    m.squircle("black", (0.9 * k, 0.1 * k, 0.4 * k), (x, 0.47 * k, 2.35 * k), power=4)  # speaker mouth
    for j in range(4):
        m.box(trim, (0.8 * k, 0.12 * k, 0.03 * k), (x, 0.45 * k, 2.22 * k + j * 0.08 * k), bevel=0)
    m.box(trim, (0.3 * k, 0.15 * k, 0.08 * k), (x - 0.6 * k, 0.55 * k, 2.6 * k), bevel=0.02)  # flush lever
    return m


# ------------------------------------------------------------------------------------------
# memes
# ------------------------------------------------------------------------------------------
def cyber_wow_shiba():
    m = wow_shiba("CyberWowShiba", ("wow", "such circuits", "very upgrade", "much chrome"))
    m.recolor({"shiba": "chromedark", "shibacream": "chrome", "comicpink": "circuit", "comiccyan": "holo", "comicgreen": "circuit"})
    m.squircle("led", (0.75, 0.12, 0.16), (-0.05, -0.72, 2.08), power=4)  # LED visor
    for k in range(4):  # circuit traces on the body
        m.box("circuit", (0.04, 0.03, 0.5), (-0.4 + k * 0.25, -0.5, 1.0 + (k % 2) * 0.2), bevel=0)
    m.cyl("chromedark", 0.03, 0.6, (0.4, -0.1, 2.8), seg=6)  # antenna
    m.blob("led", (0.12, 0.12, 0.12), (0.4, -0.1, 3.1))
    return m


def glitch_swamp_frog():
    m = Meme("GlitchSwampFrog")
    # a swamp frog split into two glitching copies, offset in magenta and cyan
    m.squircle("ink", (3.0, 2.0, 0.15), (0, 0, 0.07), power=4)
    swamp_frog(m, "glitch1", "glitch1", x=-0.25, y=0.15, z=0.15, scale=0.95, cheeks=None)
    swamp_frog(m, "glitch2", "glitch2", x=0.25, y=0.1, z=0.15, scale=0.95, cheeks=None)
    swamp_frog(m, x=0.0, y=-0.05, z=0.15, scale=0.95)
    for k in range(8):  # torn pixel strips
        m.box(("glitch1", "glitch2", "white")[k % 3], (0.6 + (k % 3) * 0.3, 0.05, 0.1), (-0.8 + (k * 0.37) % 1.6, -1.0, 0.8 + k * 0.38), bevel=0)
    return m


def quantum_shocked_rodent():
    m = shocked_rodent()
    m.name = "QuantumShockedRodent"
    m.recolor({"hamster": "goldbright", "hamsterdark": "golddeep"})
    ghost = shocked_rodent().recolor({"hamster": "holo", "hamsterdark": "holodark", "cream": "holo", "pink": "holo", "black": "holodark",
                                      "mouth": "holodark", "teeth": "holo", "tongue": "holo", "white": "holo"})
    ghost.transform((0.9, 0.7, 0.4), 0.85, 25)  # its copy in the other universe
    m.absorb(ghost)
    for k, (r, tilt) in enumerate(((2.2, 70), (2.4, -60))):
        m.torus("voidglow", r, 0.04, (0.3, 0.2, 2.5), rot=(tilt, 20 * k, 0))  # orbit rings
    m.blob("voidglow", (0.25,) * 3, (2.4, 0.1, 3.2))
    return m


def void_stonks():
    m = stonks_head()
    m.name = "VoidStonks"
    m.recolor({"navy": "voidpurple", "mememan": "toorng", "white": "voidglow", "red": "voidglow", "orange": "voidglow"})
    stars(m, 14, ((-1.6, 1.6), (0.3, 0.8), (0.3, 4.5)), "starwhite", 0.12)
    # an arrow going up and one going down at the same time
    m.relief("circuit", [(-0.1, 0), (0.1, 0), (0.1, 1.2), (0.3, 1.2), (0, 1.6), (-0.3, 1.2), (-0.1, 1.2)], 0.12, (1.5, -0.3, 2.4))
    m.relief("led", [(-0.1, 1.6), (0.1, 1.6), (0.1, 0.4), (0.3, 0.4), (0, 0), (-0.3, 0.4), (-0.1, 0.4)], 0.12, (-1.5, -0.3, 2.0))
    return m


def multiverse_space_infant():
    m = Meme("MultiverseSpaceInfant")
    # three space infants from three universes, side by side in their hover pods
    for k, (dx, tint) in enumerate(((-1.35, None), (0.0, {"infant": "holo", "steelpanel": "voidpurple"}),
                                    (1.35, {"infant": "glitch1", "steelpanel": "chromedark", "cyber": "led"}))):
        baby = space_infant()
        if tint:
            baby.recolor(tint)
        baby.transform((dx, 0.3 * abs(k - 1), 0), 0.55)
        m.absorb(baby)
    m.squircle("ink", (4.4, 1.8, 0.1), (0, 0.2, 0.05), power=4)
    return m


def bullet_dodge_guy():
    m = Meme("BulletDodgeGuy")
    # a guy in a long black coat and shades bending impossibly far backward while bullets streak past
    m.squircle("ink", (2.6, 2.0, 0.12), (0, 0, 0.06), power=4)
    for s in (-1, 1):
        m.tube("black", [(s * 0.3, -0.4, 1.7), (s * 0.35, -0.9, 0.9), (s * 0.4, -0.7, 0.2)], 0.17)  # legs braced
        m.squircle("black", (0.36, 0.65, 0.25), (s * 0.4, -0.85, 0.12), power=2.6)
    m.squircle("black", (0.9, 0.6, 0.5), (0, -0.3, 1.8), power=3)  # hips
    lean = -55  # torso bent way back
    m.squircle("black", (1.0, 0.65, 1.3), (0, 0.2, 2.35), rot=(lean, 0, 0), power=2.8)
    m.squircle("black", (1.1, 0.25, 1.9), (0, 0.6, 1.55), rot=(lean * 0.4, 0, 0), power=3)  # coat tail swinging
    m.cyl("skin", 0.15, 0.3, (0, 0.6, 2.9), rot=(lean, 0, 0), seg=12)
    m.squircle("skin", (0.75, 0.75, 0.85), (0, 0.95, 3.2), rot=(lean, 0, 0), power=2.4)  # head tipped back
    m.squircle("hairblack", (0.8, 0.8, 0.4), (0, 1.15, 3.35), rot=(lean, 0, 0), power=2.4)
    m.squircle("black", (0.7, 0.12, 0.18), (0, 0.7, 3.45), rot=(lean, 0, 0), power=4)  # shades
    for s in (-1, 1):  # arms flung out for balance
        m.tube("black", [(s * 0.45, 0.3, 2.6), (s * 1.0, 0.1, 2.5), (s * 1.5, -0.1, 2.3)], 0.12)
        m.blob("skin", (0.22, 0.2, 0.25), (s * 1.55, -0.12, 2.28))
    for k, (x, z) in enumerate(((-1.6, 3.1), (-0.6, 3.6), (0.6, 3.3))):  # bullets with ripple trails
        m.cyl("bulletgold", 0.08, 0.3, (x, -0.2, z), rot=(0, 90, 0), seg=12)
        m.cyl("bulletgold", 0.08, 0.12, (x + 0.2, -0.2, z), rot=(0, 90, 0), radius2=0.0, seg=12)
        for j in range(3):
            m.torus("trail", 0.12 + j * 0.06, 0.012, (x - 0.25 - j * 0.25, -0.2, z), rot=(0, 90, 0))
    return m


def neon_sus_bean():
    m = sus_bean()
    m.name = "NeonSusBean"
    m.recolor({"red": "neonpink", "darkred": "voidpurple", "visor": "holo"})
    m.torus("neonpink", 1.1, 0.05, (0, 0, 0.1))  # glow ring
    m.torus("holo", 1.3, 0.03, (0, 0, 0.1))
    m.text("neonpink", "SUS", (0, -0.6, 3.3), size=0.5, depth=0.06)
    return m


def holo_jawline_chad():
    m = jawline_chad()
    m.name = "HoloJawlineChad"
    m.recolor({"ink": "holodark", "darkgray": "holo", "lightgray": "holo"})
    m.cyl("chromedark", 0.9, 0.25, (0, 0, -0.05), seg=40)  # projector base
    m.torus("holo", 0.85, 0.04, (0, 0, 0.1))
    for k in range(10):  # scan lines
        m.torus("holodark", 0.75, 0.012, (0, 0, 0.6 + k * 0.38), scale=(1, 0.8, 1))
    return m


def cosmic_shake():
    m = birthday_shake()
    m.name = "CosmicShake"
    m.recolor({"purple": "nebula2", "lilac": "voidglow", "pink": "neonpink"})
    stars(m, 16, ((-1.4, 1.4), (-0.6, 0.6), (0.4, 4.2)), "starwhite", 0.1)
    m.torus("planetring", 1.2, 0.05, (0, 0, 1.8), rot=(70, 10, 0))
    m.blob("planet2", (0.4, 0.4, 0.4), (1.2, -0.2, 3.3))
    return m


def space_polka_cow():
    m = polka_cow()
    m.name = "SpacePolkaCow"
    m.transform((0, 0, 1.75), 0.6)  # the cow and its floor on top of a tiny planet
    m.blob("planet2", (2.6, 2.6, 2.0), (0, 0, 1.0))
    m.blob("darkgreen", (0.6, 0.5, 0.2), (0.6, -0.9, 1.4))
    m.blob("darkgreen", (0.5, 0.4, 0.2), (-0.8, -0.8, 0.9))
    m.torus("planetring", 1.8, 0.08, (0, 0, 1.0), rot=(75, 0, 15))
    stars(m, 10, ((-2.0, 2.0), (0.4, 0.8), (0.3, 4.4)), "starwhite", 0.1)
    return m


def interdimensional_chill_dude():
    m = chill_dude()
    m.name = "InterdimensionalChillDude"
    m.transform((0, -0.4, 0), 1.0)
    m.torus("portal1", 1.7, 0.18, (0, 0.6, 2.4), rot=(90, 0, 0), scale=(1, 1, 1.25))  # the portal behind him
    m.cyl("portal2", 1.55, 0.06, (0, 0.65, 2.4), rot=(90, 0, 0), seg=40, scale=(1, 1.25, 1))
    for k in range(10):
        a = k / 10 * math.tau
        m.blob("portal1", (0.18, 0.08, 0.18), (math.cos(a) * 1.0, 0.6, 2.4 + math.sin(a) * 1.25))
    for k in range(4):  # swirl
        a0 = k * math.pi / 2
        m.tube("portal1", [(math.cos(a0 + t) * (0.3 + t * 0.35), 0.58, 2.4 + math.sin(a0 + t) * (0.3 + t * 0.35) * 1.25) for t in (0, 0.6, 1.2, 1.8)],
               0.04, seg=6)
    return m


def cyber_singing_throne():
    m = Meme("CyberSingingThrone")
    # a chrome toilet throne with glowing LED eyes and a speaker grille mouth, singing
    throne(m)
    m.cyl("ink", 1.4, 0.1, (0, 0.2, 0.05), seg=40)
    m.torus("circuit", 1.4, 0.04, (0, 0.2, 0.12))
    for k in range(3):
        m.blob("black", (0.18, 0.08, 0.14), (-1.3 + k * 0.4, -0.2, 3.6 + k * 0.25), rot=(0, -20, 0))
        m.cyl("black", 0.02, 0.4, (-1.22 + k * 0.4, -0.2, 3.8 + k * 0.25), seg=6)
    return m


def universal_sanic():
    m = Meme("UniversalSanic")
    # a hedgehog made of the night sky, frozen mid-sprint across a ring of stars
    for s, (knee, foot) in ((-1, ((-0.3, -0.5, 0.8), (-0.4, -0.7, 0.15))), (1, ((0.3, 0.4, 0.9), (0.35, 0.7, 0.45)))):
        m.tube("nebula2", [(s * 0.25, 0, 1.4), knee, foot], 0.13)
        m.squircle("starwhite", (0.42, 0.85, 0.35), (foot[0], foot[1] - 0.15, foot[2]), power=2.4)
    m.squircle("navy", (1.3, 1.0, 1.4), (0, 0, 2.0), power=2.2)
    m.squircle("navy", (1.7, 1.5, 1.5), (0, 0.05, 3.3), power=2.4)
    for k in range(5):
        a = math.radians(-50 + k * 25)
        m.cyl("nebula2", 0.32, 1.6, (math.sin(a) * 0.4, 0.9, 3.4 + math.cos(a) * 0.3), rot=(-80, 0, math.degrees(a) * -0.3), radius2=0.0, seg=10)
    m.blob("starwhite", (1.0, 0.3, 0.7), (0, -0.62, 3.45))
    for s in (-1, 1):
        m.blob("voidglow", (0.2, 0.1, 0.3), (s * 0.2, -0.78, 3.45))
        m.tube("navy", [(s * 0.6, 0, 2.4), (s * 1.1, -0.5, 2.3), (s * 1.3, -0.9, 2.5)], 0.11)
        m.blob("starwhite", (0.28, 0.28, 0.28), (s * 1.3, -0.95, 2.5))
    m.tube("mouth", [(-0.3, -0.85, 2.95), (0.1, -0.88, 2.88), (0.35, -0.83, 3.0)], 0.04)
    stars(m, 18, ((-0.7, 0.7), (-0.55, -0.5), (1.2, 4.0)), "starwhite", 0.08, seed=3)
    m.torus("voidglow", 1.9, 0.04, (0, 0.2, 2.4), rot=(90, 0, 0))
    return m


def exponential_ogre():
    m = Meme("ExponentialOgre")
    # an ogre roaring with a smaller ogre in its mouth, roaring with a smaller one in ITS mouth...
    def ogre_head(c, k):
        x, y, z = c
        m.squircle("ogre", (1.8 * k, 1.5 * k, 1.6 * k), (x, y, z), power=2.3)
        for s in (-1, 1):
            m.cyl("ogre", 0.18 * k, 0.6 * k, (x + s * 1.0 * k, y + 0.1 * k, z + 0.35 * k), rot=(0, s * 70, 0), radius2=0.05 * k, seg=10)  # pointy ears
            m.eye((x + s * 0.35 * k, y - 0.7 * k, z + 0.35 * k), (0.32 * k, 0.16 * k, 0.3 * k), iris="hairbrown", pupil="black")
            m.box("ogredark", (0.4 * k, 0.08 * k, 0.1 * k), (x + s * 0.35 * k, y - 0.75 * k, z + 0.6 * k), rot=(0, s * 15, 0), bevel=0.02)
        m.blob("ogredark", (0.4 * k, 0.3 * k, 0.3 * k), (x, y - 0.78 * k, z + 0.1 * k))  # nose
        m.blob("mouth", (1.2 * k, 0.4 * k, 0.8 * k), (x, y - 0.6 * k, z - 0.45 * k))  # roaring mouth
        for j in range(4):
            m.box("teeth", (0.12 * k, 0.08 * k, 0.15 * k), (x - 0.3 * k + j * 0.2 * k, y - 0.78 * k, z - 0.1 * k), bevel=0.02)
    m.squircle("ogre", (2.4, 1.6, 1.6), (0, 0.2, 1.0), power=2.2)  # shoulders
    m.squircle("hairbrown", (2.45, 1.62, 0.8), (0, 0.2, 0.8), power=2.4)  # vest
    ogre_head((0, 0.0, 2.6), 1.0)
    ogre_head((0, -1.1, 2.12), 0.45)  # poking out of the big one's mouth
    ogre_head((0, -1.52, 1.98), 0.2)  # ...and out of that one's
    m.text("ogredark", "...", (0, -1.0, 1.4), size=0.4, depth=0.04)
    return m


def miraculous_gnome():
    m = Meme("MiraculousGnome")
    # a garden gnome with a tall red hat and a glorious beard, sparkling: you've been gnomed
    m.squircle("green", (2.2, 2.0, 0.15), (0, 0, 0.07), power=3)
    for s in (-1, 1):
        m.squircle("brown", (0.45, 0.7, 0.3), (s * 0.35, -0.15, 0.25), power=2.5)
    m.squircle("gnomeblue", (1.4, 1.2, 1.5), (0, 0, 1.15), power=2.3)
    m.squircle("darkbrown", (1.45, 1.25, 0.18), (0, 0, 1.0), power=3)
    m.blob("skin", (1.0, 0.95, 0.9), (0, -0.1, 2.2))
    m.blob("skin", (0.4, 0.35, 0.35), (0, -0.62, 2.15))  # round nose
    for s in (-1, 1):
        m.eye((s * 0.22, -0.52, 2.38), (0.18, 0.1, 0.18), iris="black")
        m.tube("gnomeblue", [(s * 0.7, 0, 1.6), (s * 0.75, -0.4, 1.2), (s * 0.35, -0.55, 1.1)], 0.15)
    for k in range(9):  # big curly beard
        a = math.radians(-70 + k * 17.5)
        m.blob("beard", (0.4, 0.35, 0.6), (math.sin(a) * 0.45, -0.5 + abs(math.sin(a)) * 0.15, 1.75 - math.cos(a) * 0.3))
    m.lathe("gnomered", [(0.6, 0), (0.55, 0.4), (0.35, 1.1), (0.12, 1.7), (0, 1.9)], (0, 0.0, 2.45), rot=(-8, 0, 10))
    for k in range(6):
        a = k / 6 * math.tau
        m.relief("goldbright", [(0, 0.15), (0.04, 0.04), (0.15, 0), (0.04, -0.04), (0, -0.15), (-0.04, -0.04), (-0.15, 0), (-0.04, 0.04)],
                 0.03, (math.cos(a) * 1.3, -0.3, 2.4 + math.sin(a) * 1.0))
    m.text("gnomered", "GNOMED", (0, -0.8, 4.6), size=0.36, depth=0.05)
    return m


def apex_wow_shiba():
    m = wow_shiba("ApexWowShiba", ("wow", "very summit", "such top", "much view"))
    m.transform((0, 0, 1.5), 0.8)
    m.lathe("rock", [(0, 0), (2.0, 0), (1.6, 0.6), (1.0, 1.25), (0.0, 1.55)], (0, 0, 0), seg=10)  # mountain peak
    m.lathe("snow", [(0.95, 1.2), (0.7, 1.35), (0, 1.56)], (0, 0, 0), seg=10)
    m.cyl("darkgray", 0.04, 1.6, (0.9, 0.3, 2.5), seg=8)  # summit flag
    m.relief("red", [(0, 0), (0.7, 0.2), (0, 0.45)], 0.03, (0.92, 0.3, 2.85))
    return m


def golden_swamp_frog():
    m = Meme("GoldenSwampFrog")
    # the swamp frog cast in solid gold, on a velvet plinth
    m.squircle("velvet", (2.6, 2.2, 0.8), (0, 0, 0.4), power=4)
    m.squircle("golddeep", (2.7, 2.3, 0.12), (0, 0, 0.82), power=4)
    swamp_frog(m, "froggold", "goldbright", z=0.85, scale=0.95, cheeks=None)
    for k in range(5):
        a = k / 5 * math.tau
        m.relief("white", [(0, 0.12), (0.03, 0.03), (0.12, 0), (0.03, -0.03), (0, -0.12), (-0.03, -0.03), (-0.12, 0), (-0.03, 0.03)],
                 0.03, (math.cos(a) * 1.3, -0.5, 2.5 + math.sin(a) * 0.9))
    return m


def toorng_entity():
    m = Meme("ToorngEntity")
    # a floating dark sphere covered in mismatched eyes, all staring at you
    m.blob("toorng", (3.0, 3.0, 3.0), (0, 0, 2.4))
    m.cyl("voidpurple", 0.9, 0.1, (0, 0, 0.05), seg=32)
    m.torus("voidglow", 1.6, 0.05, (0, 0, 2.4), rot=(80, 0, 10))
    eyes = [(-0.5, 2.9, 0.35), (0.45, 2.75, 0.45), (0.0, 2.05, 0.6), (-0.95, 2.1, 0.25), (0.95, 2.0, 0.3), (-0.3, 3.5, 0.22),
            (0.5, 3.45, 0.25), (-0.7, 1.4, 0.2), (0.6, 1.35, 0.22), (1.15, 2.9, 0.2), (-1.15, 2.85, 0.18)]
    for x, z, r in eyes:
        d = math.sqrt(max(0.0, 1.5 ** 2 - x ** 2 - (z - 2.4) ** 2))
        m.eye((x, -d + 0.05, z), (r * 2, r, r * 2), iris=("voidglow", "led", "goldbright")[int(r * 10) % 3], pupil="black", look=(-x * 0.3, (2.4 - z) * 0.3))
    for k in range(6):  # tendrils
        a = k / 6 * math.tau
        m.tube("toorng", [(math.cos(a) * 1.2, math.sin(a) * 1.2, 1.4), (math.cos(a) * 1.6, math.sin(a) * 1.6, 0.8), (math.cos(a + 0.4) * 1.5, math.sin(a + 0.4) * 1.5, 0.3)],
               lambda t: 0.16 - 0.12 * t)
    return m


def high_roller_brainrot():
    m = Meme("HighRollerBrainrot")
    # two giant dice showing double six on green felt, mini brainrot figures cheering on top
    from memes_batch1 import log_guy, sneaker_shark
    m.squircle("felt", (4.2, 2.4, 0.2), (0, 0, 0.1), power=4)
    for x, turn in ((-0.95, 12), (0.95, -15)):
        m.box("dice", (1.6, 1.6, 1.6), (x, 0, 1.0), rot=(0, 0, turn), bevel=0.25)
        c, sn = math.cos(math.radians(turn)), math.sin(math.radians(turn))
        for j in range(6):  # six on the front
            px, pz = (-0.35 if j < 3 else 0.35), 0.55 + (j % 3) * 0.45
            m.blob("pip", (0.24, 0.08, 0.24), (x + px * c, px * sn - 0.81 * c, pz + 0.0))
    shark = sneaker_shark()
    shark.transform((-0.95, 0, 1.8), 0.42, 10)
    m.absorb(shark)
    log = log_guy()
    log.transform((0.95, 0, 1.8), 0.5, -10)
    m.absorb(log)
    for k in range(4):  # chips
        m.cyl(("red", "blue", "gold", "black")[k], 0.2, 0.06 + k * 0.0, (-1.6 + k * 0.12, -0.9, 0.24 + k * 0.07), seg=20)
    return m


def immeasupreme_overlord():
    m = Meme("ImmeasupremeOverlord")
    # a cloaked overlord with glowing eyes and a giant crown, on a throne stacked from meme relics
    from memes_batch5 import shocked_rodent as rodent
    m.squircle("voidpurple", (4.2, 2.6, 0.25), (0, 0, 0.12), power=4)
    for k, (x, z, c) in enumerate(((-1.4, 0.6, "yellow"), (1.4, 0.6, "sky"), (-1.3, 1.5, "pink"), (1.3, 1.5, "lime"), (-1.2, 2.4, "orange"), (1.2, 2.4, "hotpink"))):
        m.box(c, (0.9, 0.9, 0.85), (x, 0.2, z), rot=(0, 0, (k % 3 - 1) * 10), bevel=0.08)  # stacked meme crates
        m.blob("black", (0.1, 0.05, 0.1), (x - 0.15, -0.27, z + 0.1))
        m.blob("black", (0.1, 0.05, 0.1), (x + 0.15, -0.27, z + 0.1))
    m.squircle("crowngold", (2.0, 1.4, 0.6), (0, 0.1, 1.3), power=4)  # seat
    m.squircle("crowngold", (2.0, 0.5, 3.4), (0, 0.85, 2.2), power=4)  # back
    m.squircle("cloak", (1.6, 1.3, 2.4), (0, -0.05, 2.5), power=2.2)  # the overlord's cloak
    m.blob("overlord", (1.0, 0.9, 1.0), (0, -0.15, 3.85))
    m.blob("cloak", (1.3, 1.2, 1.0), (0, 0.0, 4.0))  # hood
    for s in (-1, 1):
        m.blob("voidglow", (0.22, 0.1, 0.12), (s * 0.2, -0.6, 3.9))
        m.tube("cloak", [(s * 0.7, -0.1, 3.0), (s * 1.0, -0.6, 2.4), (s * 0.9, -0.7, 1.9)], 0.18)
        m.blob("overlord", (0.25, 0.25, 0.25), (s * 0.9, -0.75, 1.85))
    m.lathe("crowngold", [(0.55, 0), (0.6, 0.5), (0, 0.5)], (0, -0.1, 4.35))
    for k in range(7):
        a = k / 7 * math.tau
        m.cyl("crowngold", 0.12, 0.5, (math.cos(a) * 0.55, -0.1 + math.sin(a) * 0.55, 5.05), radius2=0.0, seg=6)
        m.blob(("led", "holo", "circuit")[k % 3], (0.14, 0.1, 0.14), (math.cos(a) * 0.6, -0.1 + math.sin(a) * 0.6, 4.6))
    pet = rodent()
    pet.transform((1.55, -0.6, 0.25), 0.25, -20)  # a little rodent minion at his feet
    m.absorb(pet)
    return m


ALL = [cyber_wow_shiba, glitch_swamp_frog, quantum_shocked_rodent, void_stonks, multiverse_space_infant, bullet_dodge_guy,
       neon_sus_bean, holo_jawline_chad, cosmic_shake, space_polka_cow, interdimensional_chill_dude, cyber_singing_throne,
       universal_sanic, exponential_ogre, miraculous_gnome, apex_wow_shiba, golden_swamp_frog, toorng_entity,
       high_roller_brainrot, immeasupreme_overlord]
