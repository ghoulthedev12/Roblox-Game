"""Batch 13 of the meme sculptures: World 9 (the quantum world, the end of the game).
Many are cosmic upgrades of earlier memes (built, recolored, transformed, given extras).
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp
from memes_batch1 import baby_hippo, birthday_shake, chill_dude
from memes_batch2 import jawline_chad, stonks_head
from memes_batch5 import chonky_bunny, da_wae_echidna
from memes_batch6 import sponge_leaving
from memes_batch11 import problem_grin_coin, wow_shiba
from memes_batch12 import stars, swamp_frog, throne

for _name, _c in [
    ("quantum", (120, 255, 240)), ("quantumdark", (30, 120, 140)), ("antired", (60, 230, 230)), ("antidark", (30, 140, 150)),
    ("string", (255, 120, 220)), ("warp", (180, 220, 255)), ("chad2", (255, 170, 120)), ("darkmatter", (30, 25, 50)),
    ("darkmatter2", (70, 55, 110)), ("crystal", (190, 240, 255)), ("crystaldark", (110, 190, 230)), ("blackhole", (8, 6, 12)),
    ("accretion", (255, 150, 60)), ("accretion2", (255, 230, 150)), ("stair", (230, 230, 240)), ("stairdark", (170, 170, 190)),
    ("trench", (110, 90, 70)), ("godskin", (120, 90, 220)), ("lotus", (255, 170, 210)), ("matrix", (60, 255, 120)),
    ("unicycle", (200, 40, 50)), ("panelnah", (255, 220, 120)), ("panelyeah", (150, 230, 150)), ("clock", (245, 245, 235)),
    ("shibagold", (240, 190, 90)), ("halo", (255, 240, 150)),
]:
    rgb(_name, *_c)


def wire_cube(m, color, center, size, r=0.04):
    """The 12 edges of a cube, as rods."""
    cx, cy, cz = center
    h = size / 2
    corners = [(cx + sx * h, cy + sy * h, cz + sz * h) for sx in (-1, 1) for sy in (-1, 1) for sz in (-1, 1)]
    for i, a in enumerate(corners):
        for b in corners[i + 1:]:
            if sum(1 for j in range(3) if abs(a[j] - b[j]) > 1e-6) == 1:
                m.tube(color, [a, b], r, seg=6)
    return corners


def tesseract(m, color, inner, center, outer_size, inner_size, r=0.04):
    """A hypercube drawing: an outer cube, an inner cube and the rods joining their corners."""
    a = wire_cube(m, color, center, outer_size, r)
    b = wire_cube(m, inner, center, inner_size, r * 0.8)
    for p, q in zip(a, b):
        m.tube(color, [p, q], r * 0.7, seg=6)


def sparkle(m, color, p, s=0.15):
    m.relief(color, [(0, s), (s * 0.25, s * 0.25), (s, 0), (s * 0.25, -s * 0.25), (0, -s), (-s * 0.25, -s * 0.25), (-s, 0), (-s * 0.25, s * 0.25)],
             0.03, p, bevel=0)


# ------------------------------------------------------------------------------------------
# memes
# ------------------------------------------------------------------------------------------
def quantum_dat_frog():
    m = Meme("QuantumDatFrog")
    # a frog riding a unicycle, with two faint copies of itself in superposition beside it
    def rider(x, color, light, cheeks, wheel):
        m.torus(wheel, 0.75, 0.12, (x, 0, 0.87), rot=(0, 90, 0))
        for k in range(8):
            a = k / 8 * math.tau
            m.tube("chrome", [(x, 0, 0.87), (x, math.cos(a) * 0.72, 0.87 + math.sin(a) * 0.72)], 0.02, seg=4)
        m.cyl("chrome", 0.05, 1.2, (x, 0, 1.5), seg=8)
        m.squircle("black", (0.5, 0.7, 0.15), (x, 0, 2.1), power=3)  # seat
        swamp_frog(m, color, light, x=x, y=0.0, z=1.9, scale=0.58, cheeks=cheeks)
    rider(-1.3, "quantum", "quantum", None, "quantum")
    rider(1.3, "quantumdark", "quantumdark", None, "quantumdark")
    rider(0.0, "frog", "froglight", "blush", "unicycle")
    m.squircle("ink", (4.2, 1.8, 0.12), (0, 0, 0.06), power=4)
    m.text("quantum", "here come", (0, -0.6, 4.3), size=0.3, depth=0.04)
    return m


def subatomic_swamp_frog():
    m = Meme("SubatomicSwampFrog")
    # an atom: a tiny frog curled up as the nucleus, electrons whizzing round three orbits
    m.cyl("ink", 1.0, 0.12, (0, 0, 0.06), seg=32)
    m.cyl("chromedark", 0.06, 1.4, (0, 0, 0.75), seg=8)
    swamp_frog(m, x=0, y=0, z=1.6, scale=0.55)
    for k, (rx, rz) in enumerate(((70, 0), (70, 60), (70, -60))):
        m.torus("quantum", 1.7, 0.04, (0, 0, 2.4), rot=(rx, 0, rz))
        a = k * 2.1
        ex = 1.7 * math.cos(a)
        ey = 1.7 * math.sin(a) * math.cos(math.radians(rx))
        ez = 1.7 * math.sin(a) * math.sin(math.radians(rx))
        c, s_ = math.cos(math.radians(rz)), math.sin(math.radians(rz))
        m.blob("sky", (0.25, 0.25, 0.25), (ex * c - ey * s_, ex * s_ + ey * c, 2.4 + ez))
    return m


def particle_wow_shiba():
    m = wow_shiba("ParticleWowShiba", ("wow", "such particle", "very small", "much quantum"))
    m.transform((0, 0, 0.3), 0.85)
    m.recolor({"comicpink": "quantum", "comicgreen": "quantum"})
    for k in range(60):  # a cloud of particles around it
        a = k * 2.39996
        r = 1.4 + (k % 7) * 0.12
        z = 0.5 + (k * 0.618) % 1 * 3.6
        m.blob(("quantum", "voidglow", "starwhite")[k % 3], (0.08, 0.08, 0.08), (math.cos(a) * r, math.sin(a) * r * 0.7, z))
    m.cyl("ink", 1.2, 0.1, (0, 0, 0.05), seg=32)
    return m


def antimatter_echidna():
    m = da_wae_echidna()
    m.name = "AntimatterEchidna"
    m.recolor({"echidna": "antired", "echidnadark": "antidark", "muzzle": "darkmatter2", "lips": "voidglow", "white": "darkmatter", "brown": "quantumdark"})
    m.relief("voidglow", [(math.cos(a) * 0.35, math.sin(a) * 0.35) for a in [k / 16 * math.tau for k in range(16)]], 0.05, (-1.4, -0.4, 3.9))
    m.text("darkmatter", "-", (-1.4, -0.45, 3.9), size=0.6, depth=0.06)  # an anti-sign
    return m


def string_theory_bunny():
    m = chonky_bunny()
    m.name = "StringTheoryBunny"
    m.recolor({"bunny": "darkmatter2", "bunnybelly": "lilac"})
    for k in range(5):  # vibrating strings looping round it in many dimensions
        a = k / 5 * math.pi
        pts = [(math.cos(t) * (2.0 + 0.15 * math.sin(t * 7 + k)), math.sin(t) * (1.8 + 0.15 * math.sin(t * 7 + k)) * math.cos(a),
                2.3 + math.sin(t) * 1.6 * math.sin(a)) for t in [i / 40 * math.tau for i in range(41)]]
        m.tube(("string", "quantum", "voidglow")[k % 3], pts, 0.03, seg=5)
    return m


def warp_speed_stonks():
    m = stonks_head()
    m.name = "WarpSpeedStonks"
    for k in range(2):  # after-images streaking behind
        ghost = stonks_head().recolor({"navy": "warp", "mememan": "warp", "white": "warp", "red": "warp", "orange": "warp",
                                       "ink": "warp", "darkgray": "warp"})
        ghost.transform((1.0 + k * 0.9, 0.3 + k * 0.3, 0), 0.92 - k * 0.1)
        m.absorb(ghost)
    for k in range(9):  # warp streaks
        z = 0.5 + k * 0.45
        m.box("warp", (2.5 + (k % 3) * 0.8, 0.05, 0.05), (1.8, -0.6 + (k % 2) * 0.3, z), bevel=0)
    return m


def parallel_jawline_chad():
    m = jawline_chad()
    m.name = "ParallelJawlineChad"
    m.transform((-0.95, 0.1, 0), 0.85, -25)
    twin = jawline_chad().recolor({"lightgray": "chad2", "darkgray": "accretion", "ink": "quantumdark"})
    twin.transform((0.95, 0.1, 0), 0.85, 25)  # its twin from the other universe, jaw to jaw
    m.absorb(twin)
    m.torus("quantum", 1.4, 0.05, (0, 0, 0.3))
    return m


def reality_warped_sponge():
    m = sponge_leaving()
    m.name = "RealityWarpedSponge"
    m.recolor({"chair": "voidglow", "door": "darkmatter2"})
    for k in range(5):  # reality swirling where he's heading
        r = 0.4 + k * 0.28
        m.torus(("quantum", "voidglow", "string")[k % 3], r, 0.04, (-2.0, -0.2, 1.6 + k * 0.05), rot=(80, k * 12, k * 20))
    for k in range(6):
        m.box("warp", (1.2, 0.04, 0.04), (0.9 + (k % 2) * 0.3, -0.6, 1.2 + k * 0.3), bevel=0)
    return m


def time_fold_panels():
    m = Meme("TimeFoldPanels")
    # two hinged panels folded at an angle: a hand saying NAH on one, a thumbs up saying YEAH on the other
    m.squircle("darkgray", (3.4, 1.6, 0.2), (0, 0.2, 0.1), power=4)
    for s, word, c in ((-1, "NAH", "panelnah"), (1, "YEAH", "panelyeah")):
        x = s * 0.82
        m.squircle(c, (1.6, 0.15, 3.0), (x, 0.0, 1.8), rot=(0, 0, s * -20), power=8)
        m.text("ink", word, (x - s * 0.05, -0.12 + 0.0, 0.75), size=0.36, depth=0.04, rot=(0, 0, s * -20))
        if s < 0:  # a flat palm held up: nah
            m.squircle("skin", (0.65, 0.18, 0.75), (x, -0.25, 2.2), rot=(0, 0, 20), power=2.4)
            for f in range(4):
                m.squircle("skin", (0.13, 0.15, 0.45), (x - 0.2 + f * 0.14, -0.27, 2.75), rot=(0, 0, 20), power=2.4)
        else:  # a thumbs up: yeah
            m.squircle("skin", (0.6, 0.35, 0.55), (x, -0.3, 2.0), rot=(0, 0, -20), power=2.4)
            m.squircle("skin", (0.18, 0.2, 0.5), (x - 0.1, -0.3, 2.45), rot=(0, 0, -20), power=2.4)
    m.cyl("chromedark", 0.06, 3.0, (0, -0.05, 1.8), seg=8)  # hinge
    m.cyl("clock", 0.45, 0.08, (0, -0.25, 3.7), rot=(90, 0, 0), seg=32)  # a clock folded into the hinge
    m.torus("ink", 0.45, 0.03, (0, -0.3, 3.7), rot=(90, 0, 0))
    m.box("ink", (0.04, 0.04, 0.3), (0, -0.32, 3.82), bevel=0)
    m.box("ink", (0.22, 0.04, 0.04), (0.1, -0.32, 3.7), bevel=0)
    return m


def dark_matter_hippo():
    m = baby_hippo()
    m.name = "DarkMatterHippo"
    m.recolor({"hippo": "darkmatter", "hippopink": "darkmatter2", "sky": "voidglow"})
    stars(m, 16, ((-1.2, 1.2), (-0.8, -0.5), (0.3, 2.2)), "starwhite", 0.08, seed=5)
    m.torus("voidglow", 1.6, 0.03, (0, 0, 1.2), rot=(75, 0, 0))
    return m


def hypercube_chill_dude():
    m = chill_dude()
    m.name = "HypercubeChillDude"
    m.transform((0, 0, 0.1), 0.78)
    tesseract(m, "quantum", "voidglow", (0, 0, 2.25), 4.2, 2.3, r=0.05)
    return m


def zero_point_throne():
    m = Meme("ZeroPointThrone")
    # a crystal singing throne floating on a glowing zero-point field
    throne(m, body="crystal", trim="crystaldark", eyes="quantum")
    m.transform((0, 0, 0.7), 0.95)
    for k in range(3):
        m.torus(("quantum", "voidglow", "quantum")[k], 0.6 + k * 0.3, 0.04, (0, 0.2, 0.35 - k * 0.08))
    for k in range(6):
        a = k / 6 * math.tau
        m.squircle("crystal", (0.25, 0.25, 0.6), (math.cos(a) * 1.6, 0.2 + math.sin(a) * 1.2, 1.5 + (k % 2) * 0.8), rot=(20, 20, 0), power=1.2)
    return m


def tesseract_shake():
    m = birthday_shake()
    m.name = "TesseractShake"
    m.transform((0, 0, 0.2), 0.8)
    m.recolor({"purple": "nebula2"})
    tesseract(m, "quantum", "voidglow", (0, 0, 2.0), 3.6, 2.4, r=0.045)
    return m


def singularity_grin_coin():
    m = problem_grin_coin()
    m.name = "SingularityGrinCoin"
    m.recolor({"medal": "blackhole", "gray": "darkmatter2", "white": "darkmatter", "black": "accretion2"})
    for k, (r, c) in enumerate(((2.0, "accretion"), (2.25, "accretion2"), (2.5, "accretion"))):
        m.torus(c, r, 0.07 - k * 0.015, (0, 0, 2.1), rot=(75, 0, 12))  # accretion disk
    return m


def event_horizon_shiba():
    m = wow_shiba("EventHorizonShiba", ("wow", "such gravity", "very dense", "much void"))
    m.transform((-0.5, -0.2, 0), 0.85)
    m.blob("blackhole", (1.4, 1.4, 1.4), (1.3, 0.9, 1.6))  # the black hole its tail falls into
    for k, (r, c) in enumerate(((0.95, "accretion"), (1.15, "accretion2"), (1.35, "accretion"))):
        m.torus(c, r, 0.06, (1.3, 0.9, 1.6), rot=(72, 0, 20 + k * 5))
    m.tube("shiba", [(0.0, 1.0, 0.8), (0.5, 1.2, 1.2), (0.9, 1.0, 1.5)], lambda t: 0.16 - 0.12 * t)  # stretched tail
    return m


def never_gonna_stair():
    m = Meme("NeverGonnaStair")
    # a staircase that climbs around a square forever, a guy in a trench coat dancing on the top step
    steps = []
    n = 16
    for k in range(n):
        side, t = divmod(k, 4)
        u = -1.2 + t * 0.8
        pos = [(u, -1.2), (1.2, u), (-u, 1.2), (-1.2, -u)][side]
        z = 0.3 + k * 0.17 if k < 12 else 0.3 + (15 - k) * 0.6  # the last side 'drops' back to the start: impossible
        steps.append((pos, z))
    for k, ((x, y), z) in enumerate(steps):
        m.box("stair" if k % 2 else "stairdark", (0.8, 0.8, z), (x, y, z / 2), bevel=0.02)
    p = mp.person(m, skin="skin", shirt="trench", pants="black", shoes="black", hair="hairbrown", hair_style="slick",
                  height=0.55, build=0.55, head=0.55, expr="smile", z=0.3 + 11 * 0.17, x=-1.2, y=1.2, sole=None,
                  arms={"l": ((-0.45, -0.1, 1.3), (-0.4, -0.35, 1.65)), "r": ((0.45, -0.1, 1.3), (0.4, -0.35, 1.65))})
    for k in range(3):
        m.blob("black", (0.16, 0.08, 0.12), (-0.6 + k * 0.4, -0.5, 4.1 + k * 0.2), rot=(0, -20, 0))
        m.cyl("black", 0.02, 0.35, (-0.53 + k * 0.4, -0.5, 4.27 + k * 0.2), seg=6)
    return m


def quantum_brainrot_god():
    m = Meme("QuantumBrainrotGod")
    # a serene six-armed god seated on a lotus, each hand holding a tiny meme relic, halo glowing
    for k in range(10):  # lotus petals
        a = k / 10 * math.tau
        m.blob("lotus", (0.9, 0.45, 0.25), (math.cos(a) * 1.0, math.sin(a) * 1.0, 0.45), rot=(0, -25, math.degrees(a)))
    m.cyl("lotus", 1.0, 0.3, (0, 0, 0.35), seg=32)
    for s in (-1, 1):  # crossed legs
        m.tube("godskin", [(s * 0.9, -0.3, 0.9), (0, -0.6, 0.85), (-s * 0.5, -0.4, 0.9)], 0.22)
    m.squircle("godskin", (1.3, 0.9, 1.6), (0, 0, 1.75), power=2.4)
    m.squircle("gold", (1.35, 0.92, 0.35), (0, 0, 1.15), power=3)  # sash
    m.squircle("godskin", (0.95, 0.9, 1.0), (0, -0.05, 3.05), power=2.3)
    for s in (-1, 1):
        m.tube("ink", [(s * 0.32, -0.48, 3.12), (s * 0.2, -0.5, 3.08), (s * 0.08, -0.48, 3.12)], 0.025)  # closed serene eyes
    m.tube("mouth", [(-0.12, -0.48, 2.8), (0, -0.5, 2.77), (0.12, -0.48, 2.8)], 0.02)
    m.blob("voidglow", (0.12, 0.06, 0.12), (0, -0.48, 3.35))  # third eye
    m.lathe("gold", [(0.4, 0), (0.35, 0.3), (0.15, 0.6), (0, 0.7)], (0, 0, 3.45))  # crown
    m.torus("halo", 1.0, 0.07, (0, 0.4, 3.2), rot=(90, 0, 0))
    relics = ["yellow", "lime", "sky", "pink", "orange", "voidglow"]
    for i, (ang, zz) in enumerate(((25, 2.6), (0, 2.1), (-25, 1.6))):
        for s in (-1, 1):
            a = math.radians(ang)
            hand = (s * (1.4 + 0.2 * math.cos(a)), -0.3, zz + 0.6 * math.sin(a))
            m.tube("godskin", [(s * 0.55, 0, 2.3), (s * 1.0, -0.2, zz + 0.2), hand], 0.11)
            m.blob("godskin", (0.22, 0.22, 0.22), hand)
            m.box(relics[(i * 2 + (s > 0)) % 6], (0.28, 0.28, 0.28), (hand[0], hand[1] - 0.1, hand[2] + 0.25), rot=(20, 30, 0), bevel=0.04)
    return m


def meme_matrix():
    m = Meme("MemeMatrix")
    # a huge faceted crystal on a base, tiny famous memes suspended in a grid inside it, code rain around
    from memes_batch2 import stonks_head as stonks, sus_bean as bean
    from memes_batch5 import shocked_rodent as rodent
    m.squircle("ink", (2.6, 2.0, 0.3), (0, 0, 0.15), power=4)
    m.torus("matrix", 1.2, 0.05, (0, 0, 0.32))
    # crystal: an outline of glowing edges (so the memes inside stay visible)
    top, bottom = (0, 0, 4.8), (0, 0, 0.35)
    ring = [(math.cos(k / 6 * math.tau) * 1.3, math.sin(k / 6 * math.tau) * 1.0, 2.6) for k in range(6)]
    for i, p in enumerate(ring):
        m.tube("crystal", [p, ring[(i + 1) % 6]], 0.05, seg=6)
        m.tube("crystal", [p, top], 0.04, seg=6)
        m.tube("crystal", [p, bottom], 0.04, seg=6)
    minis = [(stonks, (-0.45, 0, 2.95), 0.22), (bean, (0.45, 0, 2.95), 0.3), (rodent, (0, 0, 1.6), 0.24)]
    for build, pos, scale in minis:
        mini = build()
        mini.transform(pos, scale)
        m.absorb(mini)
    for k in range(10):  # code rain
        a = k / 10 * math.tau
        for j in range(4):
            m.box("matrix", (0.08, 0.04, 0.16), (math.cos(a) * 1.75, math.sin(a) * 1.4, 1.0 + j * 0.3 + (k % 3) * 0.6), bevel=0)
    return m


def original_shiba():
    m = Meme("OriginalShiba")
    # the good girl who started it all: a calm shiba lying on a golden cushion under a halo
    m.lathe("gold", [(0, 0), (1.3, 0), (1.3, 0.2), (1.0, 0.35), (0.9, 0.9), (1.2, 1.0), (1.2, 1.1), (0, 1.1)], (0, 0, 0), seg=40)
    m.squircle("velvet", (2.4, 2.0, 0.4), (0, 0, 1.3), power=3.5)
    m.squircle("shibagold", (1.7, 2.0, 0.9), (0, 0.15, 1.85), power=2.2)  # lying body
    m.blob("shibacream", (1.2, 0.6, 0.6), (0, -0.6, 1.75))
    for s in (-1, 1):
        m.squircle("shibacream", (0.3, 0.7, 0.22), (s * 0.35, -0.85, 1.55), power=2.5)  # front paws
    m.tube("shibagold", [(0.6, 1.1, 1.8), (0.9, 1.0, 2.3), (0.6, 0.85, 2.5)], lambda t: 0.2 - 0.06 * t)  # curled tail
    m.squircle("shibagold", (1.25, 1.1, 1.0), (0, -0.4, 2.7), power=2.3)
    m.blob("shibacream", (0.8, 0.6, 0.45), (0, -0.85, 2.5))
    m.blob("black", (0.2, 0.14, 0.14), (0, -1.15, 2.6))
    for s in (-1, 1):
        mp.ear(m, "shibagold", (s * 0.35, -0.4, 3.1), (s * 0.48, -0.4, 3.6), width=0.24, inner="shibacream", thick=0.09)
        m.blob("shibacream", (0.2, 0.08, 0.1), (s * 0.26, -0.86, 2.95))
        m.eye((s * 0.26, -0.86, 2.8), (0.2, 0.1, 0.18), iris="black", look=(-0.6, 0), lid="shibagold", lid_drop=0.3)
    m.tube("mouth", [(-0.2, -1.1, 2.33), (0, -1.12, 2.3), (0.2, -1.1, 2.35)], 0.022)
    m.torus("halo", 0.55, 0.06, (0, -0.4, 3.85), rot=(15, 0, 0))
    m.text("gold", "GOOD GIRL", (0, -1.2, 0.6), size=0.24, depth=0.04)
    return m


ALL = [quantum_dat_frog, subatomic_swamp_frog, particle_wow_shiba, antimatter_echidna, string_theory_bunny, warp_speed_stonks,
       parallel_jawline_chad, reality_warped_sponge, time_fold_panels, dark_matter_hippo, hypercube_chill_dude,
       zero_point_throne, tesseract_shake, singularity_grin_coin, event_horizon_shiba, never_gonna_stair,
       quantum_brainrot_god, meme_matrix, original_shiba]
