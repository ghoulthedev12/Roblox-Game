"""Builds the pets and their eggs as Blender meshes: one egg per world and five pets in each
egg (Common, Uncommon, Rare, Epic, Legendary), 45 pets in all. Every design is an original
cartoon creature themed on its world (no copied characters).
Each pet and egg is one mesh in the shared palette style, standing on z = 0 and facing -y.
Writes assets/models/PetMeshes.fbx (File > Import 3D once; the installer moves them to
ReplicatedStorage > PetModels), src/shared/PetMeshData.lua (each mesh's size in studs) and
a contact sheet in assets/models/previews/Sheet_pets.png (one row per world: egg, then the
five pets from Common to Legendary).
Run:  blender -b --factory-startup --python tools/blender/pets.py [-- --no-sheet]"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402

import memekit  # noqa: E402
from memekit import Meme, rgb  # noqa: E402

for _name, _c in [
    # shared
    ("blush", (255, 140, 170)), ("eyeink", (20, 18, 30)), ("petwhite", (250, 250, 252)),
    # world 1: the old internet
    ("pupcream", (250, 230, 190)), ("puptan", (220, 160, 100)), ("netcyan", (60, 220, 240)), ("netnavy", (40, 50, 110)),
    ("snailbody", (190, 220, 150)), ("froggreen", (110, 200, 90)), ("frogbelly", (220, 245, 170)), ("floppy", (50, 70, 160)),
    ("owllilac", (190, 160, 245)), ("owlbelly", (240, 230, 255)), ("dragonnavy", (40, 46, 96)), ("dragonbelly", (120, 200, 230)),
    # world 2: sakura
    ("sakura", (255, 180, 210)), ("sakuradeep", (240, 110, 160)), ("lanternred", (230, 60, 60)), ("koiorange", (255, 120, 40)),
    ("pandablack", (40, 40, 46)), ("bamboo", (130, 200, 90)), ("bamboodark", (80, 150, 60)), ("kitsune", (255, 245, 250)),
    # world 3: galaxy
    ("star", (255, 220, 80)), ("cosmos", (60, 40, 140)), ("cosmosdeep", (30, 22, 80)), ("comet", (120, 230, 255)),
    ("planet", (255, 150, 90)), ("planetring", (250, 220, 150)), ("axolotl", (255, 170, 200)), ("gill", (240, 90, 150)),
    ("nebula", (150, 90, 230)), ("nebulapink", (255, 120, 210)),
    # world 4: frost
    ("seal", (235, 240, 248)), ("sealgray", (180, 190, 205)), ("penguin", (40, 50, 70)), ("icefox", (210, 235, 255)),
    ("icecrystal", (130, 220, 255)), ("yeti", (245, 248, 255)), ("yetiface", (120, 170, 230)), ("mammoth", (150, 190, 230)),
    # world 5: dunes
    ("chrome", (200, 210, 225)), ("chromedark", (120, 130, 150)), ("cactus", (90, 170, 90)), ("cactusflower", (255, 110, 160)),
    ("camel", (220, 175, 110)), ("sphinx", (240, 190, 70)), ("sphinxblue", (40, 90, 200)), ("sand", (240, 200, 130)),
    # world 6: coral
    ("puffer", (255, 210, 90)), ("crab", (255, 110, 70)), ("jelly", (200, 150, 255)), ("jellyglow", (130, 255, 230)),
    ("octo", (170, 90, 210)), ("seahorse", (60, 200, 190)), ("coral", (255, 120, 140)), ("sea", (40, 150, 170)),
    # world 7: candy
    ("gummy", (255, 80, 110)), ("donut", (230, 170, 100)), ("frosting", (255, 150, 210)), ("cottoncandy", (255, 190, 230)),
    ("lolly", (120, 210, 255)), ("cupcake", (130, 210, 220)), ("cherry", (220, 30, 60)), ("candydragon", (190, 240, 210)),
    ("sprinkle1", (255, 230, 60)), ("sprinkle2", (90, 200, 255)),
    # world 8: forge
    ("ember", (255, 140, 30)), ("emberhot", (255, 220, 80)), ("basaltpet", (50, 44, 50)), ("gecko", (70, 60, 70)),
    ("anvil", (90, 94, 108)), ("golem", (110, 90, 85)), ("phoenix", (255, 90, 40)), ("phoenixgold", (255, 200, 60)),
    # world 9: glitch
    ("glitchpink", (255, 60, 200)), ("glitchgreen", (60, 255, 120)), ("glitchblack", (30, 20, 44)), ("glitchcyan", (60, 230, 255)),
    ("nullpurple", (60, 30, 90)), ("unicornmane", (120, 255, 220)),
    # eggs
    ("eggwhite", (246, 244, 250)), ("eggice", (190, 230, 255)), ("eggchrome", (215, 220, 232)), ("eggteal", (60, 190, 190)),
    ("eggcandy", (255, 240, 248)), ("eggmagma", (44, 38, 44)), ("eggglitch", (200, 50, 200)),
    # the Relic Egg (bought with Robux) and its pets: gold, turquoise, ruby, old stone and bone
    ("relicgold", (255, 218, 80)), ("relicgolddark", (226, 162, 44)), ("relicteal", (40, 205, 190)),
    ("relicruby", (235, 40, 80)), ("relicstone", (150, 130, 110)), ("relicstonedark", (100, 84, 72)),
    ("bone", (240, 232, 205)), ("bonedark", (200, 186, 150)), ("bandage", (236, 228, 208)), ("bandagedark", (190, 178, 150)),
    ("totemred", (210, 70, 50)), ("totemwood", (170, 105, 60)), ("jade", (70, 200, 120)),
]:
    rgb(_name, *_c)

OUT_LUA = os.path.join(memekit.ROOT, "src", "shared", "PetMeshData.lua")


# ------------------------------------------------------------------------------------------
# helpers
# ------------------------------------------------------------------------------------------
def front_y(head, dx, dz):
    """The y of the front (-y) surface of an ellipsoid head at an offset (dx, dz) from its center."""
    cx, cy, cz, w, d, h = head
    k = 1 - (2 * dx / w) ** 2 - (2 * dz / h) ** 2
    return cy - d / 2 * math.sqrt(max(k, 0.04))


def face(m, head, eye=0.24, spacing=0.22, ez=0.05, blush="blush", mouth="eyeink", white="eyeink", iris="eyeink",
         smile=True, cheeks=True):
    """Big glossy cartoon eyes, blush and a small smile on the front of an ellipsoid head."""
    cx, cy, cz, w, d, h = head
    ew = eye * w
    for sx in (-1, 1):
        dx, dz = sx * spacing * w, ez * h
        y = front_y(head, dx, dz)
        m.eye((cx + dx, y + ew * 0.2, cz + dz), (ew, ew * 0.6, ew * 1.2), iris=iris, white=white)
        if cheeks:
            bx, bz = sx * (spacing * w + ew * 0.55), dz - ew * 0.8
            m.blob(blush, (ew * 0.8, ew * 0.25, ew * 0.42), (cx + bx, front_y(head, bx, bz) + 0.02, cz + bz))
    if smile:
        pts = []
        for k in range(7):
            t = k / 6
            x = (t - 0.5) * w * 0.16
            z = ez * h - ew * 0.75 - math.sin(t * math.pi) * ew * 0.22
            pts.append((cx + x, front_y(head, x, z) + 0.01, cz + z))
        m.tube(mouth, pts, ew * 0.07, seg=8)


def head_blob(m, color, head):
    cx, cy, cz, w, d, h = head
    m.blob(color, (w, d, h), (cx, cy, cz))
    return head


def legs4(m, color, x, y_front, y_back, z_top, length=0.5, r=0.2):
    for lx in (-x, x):
        for ly in (y_front, y_back):
            m.cyl(color, r, length, (lx, ly, z_top - length / 2), seg=16)
            m.blob(color, (r * 2.3, r * 2.5, r * 1.4), (lx, ly - 0.04, r * 0.6))


def star_pts(r_out, r_in, n=5, turn=90):
    pts = []
    for k in range(n * 2):
        a = math.radians(turn + k * 180 / n)
        r = r_out if k % 2 == 0 else r_in
        pts.append((math.cos(a) * r, math.sin(a) * r))
    return pts


def tail_tube(m, color, pts, r0, r1, seg=12):
    m.tube(color, pts, lambda t: r0 + (r1 - r0) * t, seg=seg)


def ear(m, color, inner, x, y, z, w, h, tilt=0, inner_scale=0.6):
    """A pointy cat/fox ear standing up (a flattened cone), with a colored inside."""
    m.cyl(color, w / 2, h, (x, y, z + h / 2), rot=(0, tilt, 0), radius2=0.02, seg=16, scale=(1, 0.45, 1))
    if inner:
        m.cyl(inner, w / 2 * inner_scale, h * 0.75, (x, y - w * 0.12, z + h * 0.4), rot=(0, tilt, 0), radius2=0.02, seg=12,
              scale=(1, 0.3, 1))


def wing(m, color, side, x, y, z, w, h, rot=0):
    pts = [(0, 0), (w * 0.5, h * 0.35), (w, h * 0.9), (w * 0.75, h * 0.25), (w * 0.95, -h * 0.05), (w * 0.4, -h * 0.15)]
    pts = [(px * side, pz) for px, pz in pts]
    if side < 0:
        pts.reverse()
    m.relief(color, pts, 0.12, (x, y, z), rot=(0, 0, rot * side), bevel=0.04, smooth=True)


# ------------------------------------------------------------------------------------------
# WORLD 1: the old internet
# ------------------------------------------------------------------------------------------
def pixel_pup():
    m = Meme("PixelPup")
    m.box("pupcream", (1.5, 2.2, 1.2), (0, 0.3, 1.1), bevel=0.15)
    for lx in (-0.5, 0.5):
        for ly in (-0.5, 1.1):
            m.box("pupcream", (0.45, 0.45, 0.7), (lx, ly, 0.35), bevel=0.08)
    m.box("puptan", (0.7, 0.6, 0.5), (0.3, 0.6, 1.72), bevel=0.1)  # a spot
    m.box("pupcream", (1.6, 1.4, 1.4), (0, -0.85, 2.2), bevel=0.2)  # head
    m.box("puptan", (0.7, 0.5, 0.5), (0, -1.6, 1.95), bevel=0.12)  # snout
    m.box("eyeink", (0.3, 0.2, 0.22), (0, -1.86, 2.08), bevel=0.06)  # nose
    for sx in (-1, 1):
        m.box("eyeink", (0.28, 0.1, 0.36), (sx * 0.4, -1.56, 2.45), bevel=0.04)  # square eyes
        m.box("petwhite", (0.09, 0.05, 0.09), (sx * 0.4 + 0.06, -1.62, 2.55), bevel=0.02)
        m.box("puptan", (0.42, 0.3, 0.8), (sx * 0.86, -0.75, 2.4), rot=(0, sx * 25, 0), bevel=0.1)  # floppy ears
        m.box("blush", (0.26, 0.06, 0.14), (sx * 0.62, -1.56, 2.0), bevel=0.03)
    m.box("netcyan", (1.65, 0.2, 0.22), (0, -0.2, 1.75), bevel=0.06)  # collar
    m.box("star", (0.3, 0.12, 0.3), (0, -0.33, 1.6), bevel=0.05)
    for k in range(3):  # a pixel-stepped tail
        m.box("pupcream", (0.3, 0.3, 0.3), (0, 1.45 + k * 0.15, 1.5 + k * 0.28), bevel=0.06)
    return m


def buffer_snail():
    m = Meme("BufferSnail")
    tail_tube(m, "snailbody", [(0, 1.4, 0.25), (0, 0.6, 0.3), (0, -0.3, 0.35), (0, -0.9, 0.6), (0, -1.15, 1.25)], 0.22, 0.5, seg=16)
    head = head_blob(m, "snailbody", (0, -1.15, 1.55, 1.0, 0.9, 0.95))
    face(m, head, eye=0.24, spacing=0.22)
    for sx in (-1, 1):  # eye stalks with little balls
        m.tube("snailbody", [(sx * 0.2, -1.1, 1.9), (sx * 0.32, -1.15, 2.4)], 0.07)
        m.blob("netcyan", (0.2, 0.2, 0.2), (sx * 0.33, -1.15, 2.48))
    # the shell: a loading ring, segments lit in a sweep
    m.blob("netnavy", (1.2, 1.25, 1.5), (0, 0.45, 1.25))
    for k in range(12):
        a = math.radians(k * 30)
        color = "netcyan" if k < 8 else "petwhite"
        m.box(color, (0.14, 0.26, 0.38), (0.62, 0.45 + math.cos(a) * 0.5, 1.25 + math.sin(a) * 0.5), rot=(-math.degrees(a), 0, 0), bevel=0.04)
        m.box(color, (0.14, 0.26, 0.38), (-0.62, 0.45 + math.cos(a) * 0.5, 1.25 + math.sin(a) * 0.5), rot=(-math.degrees(a), 0, 0), bevel=0.04)
    return m


def floppy_frog():
    m = Meme("FloppyFrog")
    m.blob("froggreen", (2.0, 1.9, 1.4), (0, 0.1, 0.85))
    m.blob("frogbelly", (1.4, 0.6, 0.9), (0, -0.62, 0.8))
    head = head_blob(m, "froggreen", (0, -0.45, 1.65, 1.8, 1.3, 1.0))
    face(m, head, eye=0.0, cheeks=True, smile=True, spacing=0.2)
    for sx in (-1, 1):  # big frog eyes on top
        m.blob("froggreen", (0.62, 0.6, 0.6), (sx * 0.5, -0.55, 2.15))
        m.eye((sx * 0.5, -0.8, 2.2), (0.46, 0.3, 0.5), iris="eyeink", white="petwhite", pupil="eyeink")
        m.blob("froggreen", (0.6, 0.9, 0.3), (sx * 0.85, -0.6, 0.18))  # feet
        for t in (-1, 0, 1):
            m.blob("froggreen", (0.2, 0.3, 0.14), (sx * 0.85 + t * 0.2, -1.05, 0.1))
    # a floppy disk worn like a backpack
    m.box("floppy", (1.3, 0.22, 1.3), (0, 0.95, 1.35), rot=(-15, 0, 0), bevel=0.06)
    m.box("chrome", (0.7, 0.06, 0.42), (0, 1.07, 1.75), rot=(-15, 0, 0), bevel=0.02)
    m.box("petwhite", (0.9, 0.06, 0.5), (0, 1.03, 1.08), rot=(-15, 0, 0), bevel=0.02)
    return m


def wifi_owl():
    m = Meme("WifiOwl")
    m.blob("owllilac", (1.9, 1.8, 2.3), (0, 0, 1.25))
    m.blob("owlbelly", (1.3, 0.6, 1.4), (0, -0.6, 1.05))
    head = (0, -0.1, 2.05, 1.8, 1.7, 1.4)
    for sx in (-1, 1):
        m.blob("petwhite", (0.8, 0.3, 0.8), (sx * 0.38, front_y(head, sx * 0.38, 0.05) + 0.1, 2.1))
        m.eye((sx * 0.38, front_y(head, sx * 0.38, 0.05) - 0.03, 2.1), (0.52, 0.3, 0.56), iris="eyeink", white="star", pupil="eyeink")
        wing(m, "owllilac", sx, sx * 0.85, 0.05, 1.1, 0.75, 1.3, rot=0)
        m.blob("star", (0.3, 0.4, 0.16), (sx * 0.35, -0.35, 0.1))  # feet
    m.cyl("star", 0.16, 0.35, (0, front_y(head, 0, -0.1) - 0.02, 1.85), rot=(90, 0, 0), radius2=0.02, seg=12)  # beak
    # wi-fi arcs as ear tufts
    for k, r in enumerate((0.3, 0.55, 0.8)):
        m.torus("netcyan" if k != 1 else "petwhite", r, 0.07, (0, 0.05, 2.55), rot=(90, 0, 0), scale=(1, 1, 1))
    m.blob("netcyan", (0.2, 0.2, 0.2), (0, 0.05, 2.62))
    # hide the lower half of the arcs inside the head: a lilac cap over them
    m.blob("owllilac", (1.75, 1.6, 1.05), (0, -0.05, 2.15))
    return m


def server_dragon():
    m = Meme("ServerDragon")
    m.squircle("dragonnavy", (1.7, 1.8, 1.9), (0, 0.25, 1.15), power=3)
    for k in range(4):  # server rack lights on its belly
        m.box("netcyan" if k % 2 == 0 else "dragonbelly", (1.0, 0.1, 0.16), (0, -0.66, 0.65 + k * 0.32), bevel=0.04)
    head = head_blob(m, "dragonnavy", (0, -0.75, 2.35, 1.5, 1.4, 1.25))
    m.blob("dragonbelly", (0.9, 0.7, 0.55), (0, -1.35, 2.15))  # snout
    face(m, head, eye=0.24, spacing=0.24, ez=0.15, white="petwhite", iris="netcyan", smile=False)
    for sx in (-1, 1):
        m.blob("eyeink", (0.1, 0.1, 0.08), (sx * 0.18, -1.7, 2.22))  # nostrils
        m.cyl("dragonbelly", 0.14, 0.7, (sx * 0.45, -0.55, 3.15), rot=(-20, sx * 20, 0), radius2=0.02, seg=12)  # horns
        wing(m, "netcyan", sx, sx * 0.6, 0.55, 1.6, 1.6, 1.5, rot=-15)
        m.blob("dragonnavy", (0.55, 0.7, 0.5), (sx * 0.55, -0.35, 0.25))  # feet
    tail_tube(m, "dragonnavy", [(0, 1.0, 0.6), (0, 1.7, 0.45), (0.3, 2.3, 0.6), (0.5, 2.6, 1.0)], 0.4, 0.1)
    m.cyl("netcyan", 0.28, 0.4, (0.55, 2.7, 1.25), rot=(0, 0, 0), radius2=0.02, seg=4)  # glowing tail tip
    for k in range(4):  # back spikes
        m.cyl("netcyan", 0.16, 0.36, (0, 0.0 + k * 0.38, 2.2 - k * 0.12), radius2=0.02, seg=4)
    return m


# ------------------------------------------------------------------------------------------
# WORLD 2: Neon Sakura Grove
# ------------------------------------------------------------------------------------------
def petal_bunny():
    m = Meme("PetalBunny")
    m.blob("petwhite", (1.6, 1.7, 1.5), (0, 0.25, 0.8))
    head = head_blob(m, "petwhite", (0, -0.45, 1.75, 1.5, 1.3, 1.25))
    face(m, head, eye=0.22, spacing=0.22)
    for sx in (-1, 1):
        m.blob("petwhite", (0.42, 0.3, 1.4), (sx * 0.35, -0.3, 2.9), rot=(0, sx * 12, 0))
        m.blob("sakura", (0.24, 0.1, 1.0), (sx * 0.36, -0.44, 2.9), rot=(0, sx * 12, 0))
        m.blob("petwhite", (0.45, 0.65, 0.3), (sx * 0.4, -0.45, 0.15))
    m.blob("petwhite", (0.6, 0.6, 0.6), (0, 1.1, 0.8))  # tail
    for k in range(5):  # a blossom on its head
        a = math.radians(k * 72)
        m.blob("sakuradeep", (0.3, 0.12, 0.3), (0.45 + math.cos(a) * 0.17, -0.55, 2.35 + math.sin(a) * 0.17))
    m.blob("star", (0.14, 0.14, 0.14), (0.45, -0.62, 2.35))
    return m


def lantern_moth():
    m = Meme("LanternMoth")
    m.blob("sakura", (0.9, 0.9, 1.5), (0, 0.2, 1.4))
    head = head_blob(m, "petwhite", (0, -0.35, 2.15, 1.1, 1.0, 1.0))
    face(m, head, eye=0.26, spacing=0.22)
    for sx in (-1, 1):
        # wings are paper lanterns: red ribbed balls with gold caps
        for (wz, s) in ((1.9, 1.0), (1.05, 0.75)):
            cx = sx * (0.95 if s == 1.0 else 0.8)
            m.blob("lanternred", (0.95 * s, 0.6 * s, 1.0 * s), (cx, 0.25, wz))
            for k in range(3):
                m.torus("star", 0.45 * s * (1 - abs(k - 1) * 0.25), 0.03, (cx, 0.25, wz - 0.3 * s + k * 0.3 * s), scale=(1, 0.65, 1))
            m.cyl("star", 0.16 * s, 0.12, (cx, 0.25, wz + 0.52 * s), seg=12)
        m.tube("eyeink", [(sx * 0.2, -0.35, 2.55), (sx * 0.35, -0.5, 3.0), (sx * 0.55, -0.45, 3.2)], 0.04)
        m.blob("star", (0.16, 0.16, 0.16), (sx * 0.56, -0.45, 3.24))
    m.blob("petwhite", (1.0, 0.5, 0.35), (0, 0.2, 2.45))  # fluffy collar
    return m


def koi_bot():
    m = Meme("KoiBot")
    m.blob("petwhite", (1.3, 2.6, 1.3), (0, 0.2, 1.4))
    for (x, y, z, s) in ((0.25, -0.2, 1.85, 0.6), (-0.3, 0.5, 1.7, 0.7), (0.1, 1.0, 1.5, 0.45)):
        m.blob("koiorange", (s, s * 1.2, s * 0.5), (x, y, z))
    head = (0, -0.75, 1.45, 1.2, 1.2, 1.15)
    face(m, head, eye=0.24, spacing=0.26, white="petwhite", iris="eyeink")
    m.box("chrome", (1.0, 0.1, 0.18), (0, front_y(head, 0, 0.35) + 0.03, 1.85), bevel=0.04)  # visor band
    for sx in (-1, 1):
        m.relief("koiorange", [(0, 0), (sx * 0.7, -0.35), (sx * 0.55, 0.15)], 0.08, (sx * 0.6, 0.1, 1.2), bevel=0.03, smooth=True)
        m.blob("chrome", (0.16, 0.16, 0.16), (sx * 0.62, -0.3, 1.45))  # bolts
    m.relief("koiorange", [(0, 0), (-0.55, 0.8), (0.55, 0.8)], 0.1, (0, 1.6, 1.35), rot=(90, 0, 0), bevel=0.04, smooth=True)  # tail fin
    m.relief("koiorange", [(-0.4, 0), (0.4, 0), (0, 0.55)], 0.08, (0, 0.2, 2.0), rot=(0, 0, 90), bevel=0.03, smooth=True)  # dorsal
    m.cyl("chrome", 0.35, 0.2, (0, 0.2, 0.35), seg=24)  # hover base
    m.cyl("netcyan", 0.25, 0.08, (0, 0.2, 0.2), seg=24)
    m.cyl("chrome", 0.08, 0.6, (0, 0.2, 0.7), seg=8)
    return m


def bamboo_panda():
    m = Meme("BambooPanda")
    m.blob("petwhite", (1.8, 1.6, 1.7), (0, 0.15, 0.9))
    head = head_blob(m, "petwhite", (0, -0.25, 2.1, 1.7, 1.45, 1.4))
    for sx in (-1, 1):
        m.blob("pandablack", (0.45, 0.3, 0.55), (sx * 0.38, front_y(head, sx * 0.38, 0.05) + 0.08, 2.15), rot=(0, sx * 20, 0))
        m.blob("pandablack", (0.5, 0.35, 0.5), (sx * 0.62, -0.2, 2.8))  # ears
        m.blob("pandablack", (0.5, 0.55, 0.9), (sx * 0.85, -0.3, 1.2), rot=(25, 0, sx * 20))  # arms
        m.blob("pandablack", (0.65, 0.7, 0.45), (sx * 0.55, -0.45, 0.25))  # feet
    face(m, head, eye=0.17, spacing=0.22, white="eyeink")
    m.blob("eyeink", (0.22, 0.12, 0.14), (0, front_y(head, 0, -0.15) - 0.02, 1.95))
    # a bamboo stalk hugged in its arms
    for k in range(4):
        m.cyl("bamboo", 0.13, 0.48, (0, -0.95, 0.6 + k * 0.5), rot=(10, 0, 0), seg=12)
        m.torus("bamboodark", 0.14, 0.03, (0, -0.95 - 0.04 * k, 0.85 + k * 0.5), rot=(10, 0, 0))
    m.relief("bamboo", [(0, 0), (0.4, 0.15), (0.6, 0.05), (0.35, -0.05)], 0.04, (0.05, -1.3, 2.55), rot=(0, -20, 0), bevel=0.02, smooth=True)
    return m


def blossom_kitsune():
    m = Meme("BlossomKitsune")
    m.blob("kitsune", (1.4, 1.9, 1.4), (0, 0.2, 1.0))
    head = head_blob(m, "kitsune", (0, -0.75, 2.05, 1.45, 1.25, 1.2))
    m.blob("kitsune", (0.6, 0.6, 0.45), (0, -1.35, 1.85))  # snout
    m.blob("sakuradeep", (0.16, 0.12, 0.12), (0, -1.66, 1.92))
    face(m, head, eye=0.22, spacing=0.22, ez=0.12, smile=False)
    for sx in (-1, 1):
        ear(m, "kitsune", "sakura", sx * 0.42, -0.7, 2.45, 0.5, 0.75, tilt=sx * 15)
        m.blob("sakuradeep", (0.3, 0.1, 0.3), (sx * 0.38, front_y(head, sx * 0.38, 0.3) + 0.02, 2.45))  # face markings
    legs4(m, "kitsune", 0.4, -0.35, 0.75, 0.6, length=0.55, r=0.17)
    # three big tails fanning up behind it, pink tipped
    for k, a in enumerate((-35, 0, 35)):
        ra = math.radians(a)
        pts = [(0, 1.05, 0.9), (math.sin(ra) * 0.6, 1.6, 1.6), (math.sin(ra) * 1.2, 1.7, 2.6)]
        tail_tube(m, "kitsune", pts, 0.3, 0.42, seg=14)
        m.blob("sakuradeep", (0.7, 0.7, 0.75), (math.sin(ra) * 1.25, 1.72, 2.85))
    for k in range(5):  # blossom by the ear
        a = math.radians(k * 72)
        m.blob("sakura", (0.24, 0.1, 0.24), (-0.55 + math.cos(a) * 0.14, -1.0, 2.55 + math.sin(a) * 0.14))
    m.blob("star", (0.12, 0.12, 0.12), (-0.55, -1.06, 2.55))
    m.torus("lanternred", 0.42, 0.06, (0, -0.55, 1.5), rot=(80, 0, 0))  # ribbon collar
    m.blob("star", (0.22, 0.14, 0.22), (0, -0.95, 1.45))  # bell
    return m


# ------------------------------------------------------------------------------------------
# WORLD 3: Galaxy Drift
# ------------------------------------------------------------------------------------------
def star_blob():
    m = Meme("StarBlob")
    m.relief("star", star_pts(1.4, 0.68), 0.75, (0, 0, 1.45), bevel=0.3, smooth=True)
    head = (0, 0, 1.45, 1.6, 0.8, 1.6)
    face(m, head, eye=0.17, spacing=0.17, ez=0.05)
    for sx in (-1, 1):
        m.blob("star", (0.35, 0.35, 0.3), (sx * 0.4, 0, 0.2))
    return m


def comet_pup():
    m = Meme("CometPup")
    m.blob("cosmos", (1.3, 1.9, 1.2), (0, 0.2, 1.0))
    head = head_blob(m, "cosmos", (0, -0.75, 1.9, 1.4, 1.25, 1.2))
    m.blob("comet", (0.6, 0.55, 0.45), (0, -1.3, 1.7))
    m.blob("eyeink", (0.2, 0.1, 0.14), (0, -1.58, 1.82))
    face(m, head, eye=0.22, spacing=0.24, ez=0.15, smile=False, white="petwhite", iris="comet")
    for sx in (-1, 1):
        m.blob("cosmos", (0.4, 0.3, 0.75), (sx * 0.7, -0.7, 2.2), rot=(0, sx * 35, 0))
        m.blob("star", (0.12, 0.12, 0.12), (sx * 0.35 - 0.2, 0.3, 1.62))  # stars on its back
    legs4(m, "cosmos", 0.38, -0.35, 0.75, 0.6, length=0.5, r=0.17)
    # a comet tail of glowing balls
    for k in range(6):
        s = 0.6 - k * 0.07
        m.blob("comet" if k % 2 == 0 else "petwhite", (s, s, s), (0, 1.3 + k * 0.35, 1.2 + k * 0.25))
    m.torus("star", 0.4, 0.06, (0, -0.5, 1.45), rot=(80, 0, 0))
    return m


def planet_turtle():
    m = Meme("PlanetTurtle")
    m.blob("planet", (2.2, 2.2, 1.7), (0, 0.15, 1.15))
    for (z, c) in ((0.9, "planetring"), (1.45, "lanternred"), (1.85, "planetring")):
        m.torus(c, math.sqrt(max(0.05, 1 - ((z - 1.15) / 0.85) ** 2)) * 1.08, 0.08, (0, 0.15, z))
    m.torus("planetring", 1.65, 0.1, (0, 0.15, 1.2), rot=(14, 0, 0), scale=(1, 1, 0.4))
    head = head_blob(m, "bamboo", (0, -1.3, 1.25, 0.95, 0.95, 0.85))
    face(m, head, eye=0.28, spacing=0.24)
    for sx in (-1, 1):
        for sy in (-0.55, 0.85):
            m.blob("bamboo", (0.5, 0.55, 0.45), (sx * 0.8, sy, 0.22))
    m.blob("bamboo", (0.3, 0.45, 0.25), (0, 1.3, 0.55))
    m.blob("petwhite", (0.2, 0.2, 0.2), (0.6, -0.3, 2.05))  # a little moon orbiting
    return m


def astro_axolotl():
    m = Meme("AstroAxolotl")
    m.blob("axolotl", (1.3, 2.0, 1.1), (0, 0.25, 0.85))
    head = head_blob(m, "axolotl", (0, -0.75, 1.65, 1.6, 1.25, 1.15))
    face(m, head, eye=0.18, spacing=0.26, ez=0.08)
    for sx in (-1, 1):
        for k in range(3):  # frilly gills
            a = math.radians(-20 + k * 30)
            m.blob("gill", (0.55, 0.16, 0.2), (sx * (0.85 + math.cos(a) * 0.25), -0.7, 1.8 + math.sin(a) * 0.45), rot=(0, -sx * (k * 30 - 20), 0))
        m.blob("axolotl", (0.3, 0.5, 0.25), (sx * 0.55, -0.4, 0.2))
        m.blob("axolotl", (0.3, 0.5, 0.25), (sx * 0.5, 0.75, 0.2))
    tail_tube(m, "axolotl", [(0, 1.1, 0.8), (0, 1.8, 0.85), (0, 2.3, 1.05)], 0.35, 0.08)
    # a little astronaut backpack and helmet rim
    m.squircle("petwhite", (0.9, 0.5, 0.75), (0, 0.4, 1.55), power=3)
    m.cyl("netcyan", 0.12, 0.1, (0.22, 0.65, 1.65), rot=(90, 0, 0), seg=12)
    m.torus("petwhite", 0.75, 0.08, (0, -0.65, 1.7), rot=(90, 0, 0), scale=(1.05, 1, 0.82))
    m.cyl("chrome", 0.03, 0.5, (0.35, -0.55, 2.45), seg=8)  # antenna
    m.blob("star", (0.16, 0.16, 0.16), (0.35, -0.55, 2.72))
    return m


def nebula_whale():
    m = Meme("NebulaWhale")
    m.blob("nebula", (2.0, 3.0, 1.8), (0, 0.2, 1.5))
    m.blob("nebulapink", (1.5, 2.2, 0.9), (0, 0.0, 0.85))  # belly
    head = (0, -0.6, 1.6, 1.9, 1.9, 1.7)
    face(m, head, eye=0.17, spacing=0.24, ez=0.0)
    for sx in (-1, 1):
        m.relief("nebula", [(0, 0), (sx * 0.9, -0.3), (sx * 0.8, 0.2)], 0.1, (sx * 0.85, -0.1, 1.0), bevel=0.04, smooth=True)
    m.relief("nebula", [(0, 0), (-0.9, 0.6), (-0.4, 0.15), (0, 0.4), (0.4, 0.15), (0.9, 0.6)], 0.14, (0, 1.75, 1.6), rot=(90, 0, 0), bevel=0.05,
             smooth=True)
    for (x, y, z) in ((0.5, 0.3, 2.3), (-0.4, 0.7, 2.25), (0.2, 1.1, 2.0), (-0.6, -0.1, 2.1), (0.7, 0.9, 1.7)):
        m.blob("star", (0.13, 0.13, 0.13), (x, y, z))
    # a spout of sparkles
    for k in range(5):
        a = math.radians(k * 72)
        m.blob("comet", (0.18, 0.18, 0.18), (math.cos(a) * 0.35, -0.2 + math.sin(a) * 0.35, 2.75 + (k % 2) * 0.2))
    m.cyl("comet", 0.1, 0.5, (0, -0.2, 2.5), seg=10)
    return m


# ------------------------------------------------------------------------------------------
# WORLD 4: Frostbyte Tundra
# ------------------------------------------------------------------------------------------
def snow_seal():
    m = Meme("SnowSeal")
    tail_tube(m, "seal", [(0, 1.2, 0.35), (0, 0.4, 0.55), (0, -0.4, 0.75)], 0.35, 0.75, seg=18)
    head = head_blob(m, "seal", (0, -0.65, 1.3, 1.5, 1.3, 1.3))
    face(m, head, eye=0.25, spacing=0.22, ez=0.08)
    m.blob("eyeink", (0.18, 0.1, 0.12), (0, front_y(head, 0, -0.1) - 0.02, 1.2))
    for sx in (-1, 1):
        m.blob("sealgray", (0.65, 0.3, 0.2), (sx * 0.7, -0.5, 0.25), rot=(0, 0, sx * 25))
        for k in range(2):
            m.cyl("sealgray", 0.015, 0.4, (sx * (0.22 + k * 0.05), front_y(head, sx * 0.3, -0.15) - 0.05, 1.12 + k * 0.08), rot=(0, 90, sx * 10), seg=6)
    m.relief("sealgray", [(0, 0), (-0.45, 0.35), (0.45, 0.35)], 0.1, (0, 1.6, 0.4), rot=(90, 0, 0), bevel=0.04, smooth=True)
    m.blob("icecrystal", (0.5, 0.5, 0.25), (0, -0.55, 2.0))  # snow cap
    return m


def penguin_bot():
    m = Meme("PenguinBot")
    m.blob("penguin", (1.5, 1.4, 2.2), (0, 0.1, 1.2))
    m.blob("petwhite", (1.1, 0.5, 1.6), (0, -0.45, 1.05))
    head = (0, -0.0, 2.2, 1.35, 1.3, 1.1)
    m.blob("penguin", (1.35, 1.3, 1.1), (0, 0, 2.2))
    m.box("netcyan", (1.0, 0.12, 0.34), (0, front_y(head, 0, 0.05) - 0.01, 2.25), bevel=0.06)  # visor
    for sx in (-1, 1):
        m.blob("eyeink", (0.18, 0.06, 0.18), (sx * 0.24, front_y(head, sx * 0.24, 0.05) - 0.06, 2.25))
        m.blob("penguin", (0.35, 0.5, 1.1), (sx * 0.8, 0.0, 1.35), rot=(0, sx * 15, 0))  # flippers
        m.blob("star", (0.45, 0.6, 0.18), (sx * 0.3, -0.25, 0.1))  # feet
    m.cyl("star", 0.16, 0.38, (0, front_y(head, 0, -0.25) - 0.05, 1.95), rot=(90, 0, 0), radius2=0.03, seg=12)  # beak
    m.cyl("chrome", 0.04, 0.5, (0, 0, 2.9), seg=8)
    m.blob("lanternred", (0.2, 0.2, 0.2), (0, 0, 3.18))
    m.torus("lanternred", 0.55, 0.08, (0, 0.05, 1.75), rot=(0, 0, 0))  # scarf
    m.blob("lanternred", (0.3, 0.2, 0.6), (0.4, -0.45, 1.45), rot=(0, 20, 0))
    return m


def ice_fox():
    m = Meme("IceFox")
    m.blob("icefox", (1.3, 1.9, 1.2), (0, 0.2, 1.0))
    head = head_blob(m, "icefox", (0, -0.75, 1.95, 1.45, 1.25, 1.15))
    m.blob("petwhite", (0.6, 0.6, 0.45), (0, -1.35, 1.75))
    m.blob("eyeink", (0.15, 0.1, 0.12), (0, -1.66, 1.82))
    face(m, head, eye=0.22, spacing=0.22, ez=0.12, smile=False, white="eyeink")
    for sx in (-1, 1):
        ear(m, "icefox", "petwhite", sx * 0.42, -0.7, 2.35, 0.5, 0.75, tilt=sx * 15)
    legs4(m, "icefox", 0.38, -0.35, 0.75, 0.6, length=0.55, r=0.16)
    tail_tube(m, "icefox", [(0, 1.05, 0.9), (0, 1.7, 1.2), (0, 2.0, 1.9)], 0.3, 0.45, seg=14)
    for k in range(5):  # crystal tail tip
        a = math.radians(k * 72)
        m.cyl("icecrystal", 0.13, 0.6, (math.cos(a) * 0.15, 2.0 + math.sin(a) * 0.15, 2.35), rot=(math.sin(a) * 25, math.cos(a) * 25, 0),
              radius2=0.02, seg=6)
    m.cyl("icecrystal", 0.1, 0.4, (0, -0.75, 2.75), radius2=0.02, seg=6)
    return m


def yeti_cub():
    m = Meme("YetiCub")
    for (x, y, z, s) in ((0, 0.1, 1.2, 2.0), (0.5, 0, 1.6, 0.9), (-0.5, 0, 1.6, 0.9), (0, -0.2, 0.7, 1.4)):
        m.blob("yeti", (s, s * 0.9, s * 0.95), (x, y, z))  # fluffy body
    head = (0, -0.15, 2.15, 1.5, 1.3, 1.3)
    m.blob("yeti", (1.5, 1.3, 1.3), (0, -0.15, 2.15))
    m.blob("yetiface", (1.0, 0.4, 0.8), (0, front_y(head, 0, -0.05) + 0.12, 2.1))
    face(m, (0, -0.55, 2.1, 1.0, 0.4, 0.8), eye=0.22, spacing=0.22, ez=0.1)
    for sx in (-1, 1):
        m.cyl("petwhite", 0.15, 0.55, (sx * 0.55, -0.1, 2.85), rot=(0, sx * 30, 0), radius2=0.03, seg=12)  # little horns
        m.blob("yeti", (0.55, 0.6, 1.0), (sx * 1.0, -0.25, 1.3), rot=(0, sx * 15, 0))  # arms
        m.blob("yetiface", (0.6, 0.75, 0.3), (sx * 0.5, -0.4, 0.15))  # feet
    return m


def crystal_mammoth():
    m = Meme("CrystalMammoth")
    m.blob("mammoth", (2.0, 2.4, 1.8), (0, 0.3, 1.5))
    m.blob("petwhite", (1.7, 1.9, 0.6), (0, 0.4, 2.3))  # snow on its back
    head = head_blob(m, "mammoth", (0, -0.9, 1.8, 1.6, 1.3, 1.5))
    face(m, head, eye=0.17, spacing=0.22, ez=0.12, smile=False)
    tail_tube(m, "mammoth", [(0, -1.45, 1.6), (0, -1.75, 1.1), (0, -1.75, 0.6), (0, -1.55, 0.4)], 0.28, 0.16)  # trunk
    for sx in (-1, 1):
        m.blob("mammoth", (0.3, 0.9, 1.0), (sx * 0.85, -0.7, 1.9), rot=(0, 0, sx * 10))  # ears
        tail_tube(m, "icecrystal", [(sx * 0.35, -1.35, 1.35), (sx * 0.6, -1.85, 1.1), (sx * 0.7, -2.05, 1.5)], 0.12, 0.03)  # tusks
    legs4(m, "mammoth", 0.6, -0.4, 1.0, 0.9, length=0.85, r=0.3)
    for k in range(3):  # crystals growing from its back
        m.cyl("icecrystal", 0.18, 0.75 - k * 0.12, (-0.3 + k * 0.3, 0.2 + k * 0.4, 2.85), rot=(10 - k * 10, -15 + k * 15, 0), radius2=0.02, seg=6)
    return m


# ------------------------------------------------------------------------------------------
# WORLD 5: Chrome Dunes
# ------------------------------------------------------------------------------------------
def sand_beetle():
    m = Meme("SandBeetle")
    m.blob("chrome", (1.8, 2.2, 1.2), (0, 0.2, 0.9))
    m.box("chromedark", (0.08, 2.0, 0.08), (0, 0.25, 1.48), bevel=0.02)
    head = head_blob(m, "chromedark", (0, -1.0, 0.95, 1.2, 0.8, 0.9))
    face(m, head, eye=0.26, spacing=0.22, white="petwhite", iris="eyeink")
    for sx in (-1, 1):
        for k in range(3):
            m.tube("chromedark", [(sx * 0.7, -0.4 + k * 0.55, 0.6), (sx * 1.1, -0.5 + k * 0.6, 0.35), (sx * 1.2, -0.55 + k * 0.6, 0.0)], 0.06)
        m.tube("sphinx", [(sx * 0.2, -1.3, 1.25), (sx * 0.35, -1.6, 1.7)], 0.05)
        m.blob("sphinx", (0.14, 0.14, 0.14), (sx * 0.36, -1.62, 1.75))
    m.relief("sphinx", star_pts(0.4, 0.18, n=8), 0.06, (0, 0.5, 1.48), rot=(-90, 0, 0), bevel=0.02)  # a little sun on its back
    return m


def cactus_cat():
    m = Meme("CactusCat")
    m.cyl("sand", 0.85, 0.5, (0, 0, 0.25), radius2=0.75, seg=24)  # a clay pot
    m.cyl("puptan", 0.92, 0.2, (0, 0, 0.55), seg=24)
    m.blob("cactus", (1.4, 1.3, 1.7), (0, 0, 1.4))
    head = head_blob(m, "cactus", (0, -0.15, 2.3, 1.4, 1.2, 1.1))
    face(m, head, eye=0.22, spacing=0.22)
    for sx in (-1, 1):
        ear(m, "cactus", None, sx * 0.42, -0.15, 2.65, 0.45, 0.55, tilt=sx * 15)
        tail_tube(m, "cactus", [(sx * 0.6, 0, 1.4), (sx * 1.05, 0, 1.5), (sx * 1.1, 0, 2.0)], 0.2, 0.18)  # cactus arms
    for (x, z) in ((-0.35, 1.2), (0.35, 1.5), (0, 0.95), (0.5, 2.0), (-0.5, 1.8)):
        m.blob("petwhite", (0.06, 0.12, 0.06), (x, front_y((0, 0, 1.4, 1.4, 1.3, 1.7), x, z - 1.4) - 0.04, z))  # spines
    for k in range(5):
        a = math.radians(k * 72)
        m.blob("cactusflower", (0.24, 0.24, 0.12), (0.3 + math.cos(a) * 0.15, -0.15 + math.sin(a) * 0.15, 2.88))
    m.blob("star", (0.13, 0.13, 0.1), (0.3, -0.15, 2.92))
    return m


def drone_camel():
    m = Meme("DroneCamel")
    m.blob("camel", (1.4, 2.1, 1.2), (0, 0.2, 1.3))
    for y in (-0.15, 0.65):  # two humps with propellers
        m.blob("camel", (0.85, 0.75, 0.8), (0, y, 1.85))
        m.cyl("chromedark", 0.05, 0.4, (0, y, 2.35), seg=8)
        m.box("chrome", (1.3, 0.16, 0.04), (0, y, 2.55), rot=(0, 0, 30), bevel=0.02)
        m.box("chrome", (1.3, 0.16, 0.04), (0, y, 2.55), rot=(0, 0, -60), bevel=0.02)
    tail_tube(m, "camel", [(0, -0.75, 1.5), (0, -1.0, 2.0), (0, -1.1, 2.45)], 0.25, 0.22)  # neck
    head = head_blob(m, "camel", (0, -1.3, 2.6, 0.85, 1.0, 0.75))
    face(m, head, eye=0.26, spacing=0.24, ez=0.15)
    for sx in (-1, 1):
        m.blob("camel", (0.18, 0.15, 0.32), (sx * 0.32, -1.2, 3.0))
    legs4(m, "camel", 0.4, -0.45, 0.85, 0.95, length=0.95, r=0.14)
    m.box("sphinxblue", (1.2, 1.0, 0.1), (0, 0.25, 1.88), bevel=0.03)  # saddle blanket
    return m


def chrome_scorpion():
    m = Meme("ChromeScorpion")
    m.blob("chrome", (1.5, 1.9, 0.9), (0, 0.1, 0.7))
    head = head_blob(m, "chrome", (0, -0.85, 0.85, 1.2, 0.9, 0.85))
    face(m, head, eye=0.27, spacing=0.22, ez=0.1, white="eyeink")
    for sx in (-1, 1):
        for k in range(3):
            m.tube("chromedark", [(sx * 0.6, -0.3 + k * 0.45, 0.5), (sx * 1.05, -0.3 + k * 0.5, 0.35), (sx * 1.15, -0.3 + k * 0.5, 0.0)], 0.06)
        tail_tube(m, "chrome", [(sx * 0.5, -1.0, 0.75), (sx * 0.9, -1.5, 0.85), (sx * 0.8, -1.95, 0.9)], 0.13, 0.12)  # arms
        m.blob("sphinx", (0.45, 0.55, 0.3), (sx * 0.8, -2.2, 0.95))  # gold claws
        m.blob("sphinx", (0.2, 0.4, 0.15), (sx * 0.95, -2.5, 1.0))
    # the tail curls up and over
    pts = []
    for k in range(9):
        t = k / 8
        a = math.radians(t * 200)
        pts.append((0, 1.0 + math.sin(a) * 0.7 + t * 0.2, 0.7 + (1 - math.cos(a)) * 0.9))
    tail_tube(m, "chrome", pts, 0.28, 0.14, seg=14)
    m.cyl("sphinx", 0.18, 0.5, (0, 0.65, 2.45), rot=(-120, 0, 0), radius2=0.02, seg=12)
    return m


def sun_sphinx():
    m = Meme("SunSphinx")
    m.box("sand", (2.2, 2.6, 0.4), (0, 0.1, 0.2), bevel=0.1)  # a little plinth
    m.blob("sphinx", (1.4, 2.2, 1.1), (0, 0.4, 0.95))
    for sx in (-1, 1):
        m.blob("sphinx", (0.45, 1.1, 0.35), (sx * 0.5, -0.8, 0.6))  # front paws
    head = head_blob(m, "sphinx", (0, -0.75, 2.1, 1.3, 1.2, 1.2))
    face(m, head, eye=0.22, spacing=0.22, ez=0.05)
    # striped headdress
    for k in range(5):
        c = "sphinxblue" if k % 2 == 0 else "star"
        m.blob(c, (1.55 - k * 0.04, 1.3, 0.3), (0, -0.6, 2.75 - k * 0.2))
    for sx in (-1, 1):
        m.box("sphinxblue", (0.38, 0.4, 1.2), (sx * 0.7, -0.75, 1.75), rot=(0, sx * 8, 0), bevel=0.1)
        m.box("star", (0.4, 0.42, 0.12), (sx * 0.71, -0.75, 1.5), rot=(0, sx * 8, 0), bevel=0.04)
    m.relief("star", star_pts(0.7, 0.4, n=12), 0.1, (0, 0.0, 3.25), bevel=0.03)  # sun disc crown
    m.blob("lanternred", (0.3, 0.12, 0.3), (0, -0.05, 3.25))
    tail_tube(m, "sphinx", [(0, 1.45, 0.6), (0.4, 1.7, 0.8), (0.55, 1.6, 1.3)], 0.12, 0.08)
    return m


# ------------------------------------------------------------------------------------------
# WORLD 6: Coral Circuit
# ------------------------------------------------------------------------------------------
def bubble_fish():
    m = Meme("BubbleFish")
    m.blob("puffer", (1.9, 1.9, 1.8), (0, 0, 1.4))
    head = (0, 0, 1.4, 1.9, 1.9, 1.8)
    face(m, head, eye=0.2, spacing=0.22, ez=0.08)
    for k in range(10):  # soft spikes
        a = math.radians(k * 36)
        m.cyl("pupcream", 0.08, 0.3, (math.cos(a) * 0.85, 0.3 + math.sin(a) * 0.3, 1.4 + math.sin(a) * 0.75),
              rot=(0, 90, math.degrees(a)), radius2=0.01, seg=6)
    for sx in (-1, 1):
        m.relief("koiorange", [(0, 0), (sx * 0.5, 0.3), (sx * 0.45, -0.2)], 0.06, (sx * 0.9, 0.0, 1.3), bevel=0.02, smooth=True)
    m.relief("koiorange", [(0, 0), (-0.45, 0.45), (0.45, 0.45)], 0.08, (0, 1.05, 1.3), rot=(90, 0, 0), bevel=0.03, smooth=True)
    for (x, z, s) in ((0.9, 2.5, 0.3), (1.15, 2.9, 0.2), (-0.8, 2.6, 0.22)):
        m.torus("bubble", s, s * 0.18, (x, -0.2, z), rot=(90, 0, 0))
    m.cyl("sea", 0.4, 0.2, (0, 0, 0.1), seg=20)
    return m


def crab_bot():
    m = Meme("CrabBot")
    m.blob("crab", (2.0, 1.4, 0.95), (0, 0.1, 0.9))
    head = (0, 0.1, 0.9, 2.0, 1.4, 0.95)
    for sx in (-1, 1):
        m.tube("crab", [(sx * 0.3, -0.3, 1.25), (sx * 0.4, -0.4, 1.8)], 0.07)
        m.eye((sx * 0.42, -0.45, 1.95), (0.36, 0.3, 0.38), iris="eyeink", white="petwhite")
        for k in range(3):
            m.tube("crab", [(sx * 0.9, -0.1 + k * 0.35, 0.7), (sx * 1.3, -0.1 + k * 0.4, 0.45), (sx * 1.4, -0.1 + k * 0.4, 0.0)], 0.08)
        tail_tube(m, "chrome", [(sx * 0.9, -0.3, 0.95), (sx * 1.3, -0.75, 1.2)], 0.12, 0.1)  # robot arms
        m.blob("chrome", (0.65, 0.5, 0.55), (sx * 1.35, -1.05, 1.35))
        m.box("chromedark", (0.5, 0.35, 0.1), (sx * 1.35, -1.3, 1.35), bevel=0.04)
    face(m, head, eye=0.0, spacing=0.2, ez=-0.05, cheeks=True)
    m.box("netcyan", (0.6, 0.08, 0.1), (0, front_y(head, 0, 0.15) - 0.02, 1.05), bevel=0.03)
    return m


def jelly_lamp():
    m = Meme("JellyLamp")
    m.lathe("jelly", [(0, 1.3), (0.95, 1.35), (1.05, 1.7), (0.85, 2.3), (0.45, 2.7), (0, 2.8)], (0, 0, 0), seg=32)
    m.lathe("jellyglow", [(0, 1.5), (0.5, 1.6), (0.45, 2.1), (0, 2.3)], (0, 0, 0), seg=24)
    head = (0, 0, 2.0, 2.0, 2.0, 1.5)
    face(m, head, eye=0.17, spacing=0.2, ez=-0.05)
    for k in range(8):  # wavy tentacles
        a = math.radians(k * 45)
        pts = [(math.cos(a) * 0.7, math.sin(a) * 0.7, 1.35)]
        for j in range(1, 5):
            pts.append((math.cos(a) * (0.7 - j * 0.05) + math.sin(j * 1.7 + k) * 0.12, math.sin(a) * (0.7 - j * 0.05), 1.35 - j * 0.3))
        tail_tube(m, "jelly" if k % 2 else "jellyglow", pts, 0.08, 0.03, seg=8)
    return m


def octo_hacker():
    m = Meme("OctoHacker")
    head = head_blob(m, "octo", (0, 0.1, 1.95, 1.9, 1.8, 2.0))
    face(m, head, eye=0.2, spacing=0.22, ez=-0.08)
    for k in range(8):
        a = math.radians(k * 45 + 22)
        pts = [(math.cos(a) * 0.6, math.sin(a) * 0.6 + 0.1, 1.1), (math.cos(a) * 1.1, math.sin(a) * 1.1 + 0.1, 0.5),
               (math.cos(a) * 1.35, math.sin(a) * 1.35 + 0.1, 0.2), (math.cos(a) * 1.55, math.sin(a) * 1.55 + 0.1, 0.35)]
        tail_tube(m, "octo", pts, 0.22, 0.08, seg=10)
    for (x, z) in ((0.45, 2.6), (-0.5, 2.5), (0.0, 2.85)):
        m.blob("owllilac", (0.22, 0.12, 0.22), (x, front_y(head, x, z - 1.95) + 0.03, z))  # spots
    # a gaming headset
    m.torus("eyeink", 0.98, 0.07, (0, 0.1, 2.0), rot=(0, 90, 0), scale=(1, 1, 1.05))
    for sx in (-1, 1):
        m.cyl("eyeink", 0.28, 0.2, (sx * 0.98, 0.1, 1.95), rot=(0, 90, 0), seg=20)
        m.cyl("glitchgreen", 0.18, 0.05, (sx * 1.09, 0.1, 1.95), rot=(0, 90, 0), seg=20)
    m.tube("eyeink", [(-0.98, 0.1, 1.85), (-0.75, -0.6, 1.5), (-0.35, -0.95, 1.45)], 0.04)
    m.blob("eyeink", (0.14, 0.14, 0.14), (-0.33, -0.98, 1.45))  # microphone
    return m


def tide_seahorse():
    m = Meme("TideSeahorse")
    # the curled body
    pts = []
    for k in range(10):
        t = k / 9
        pts.append((0, 0.2 - math.sin(t * math.pi * 0.9) * 0.5, 2.3 - t * 1.6))
    tail_tube(m, "seahorse", pts, 0.6, 0.45, seg=18)
    curl = []
    for k in range(10):
        a = math.radians(k * 32)
        r = 0.55 - k * 0.04
        curl.append((0, 0.35 + math.sin(a) * r, 0.75 - math.cos(a) * r * 0.9 + 0.3 - 0.3))
    tail_tube(m, "seahorse", curl, 0.35, 0.1, seg=12)
    m.blob("puffer", (0.75, 0.45, 1.3), (0, -0.3, 1.35))  # belly plates
    for k in range(4):
        m.torus("star", 0.32, 0.03, (0, -0.33, 0.9 + k * 0.3), rot=(90, 0, 0), scale=(1, 0.5, 1))
    head = head_blob(m, "seahorse", (0, -0.1, 2.85, 1.15, 1.15, 1.0))
    tail_tube(m, "seahorse", [(0, -0.55, 2.75), (0, -1.05, 2.65)], 0.22, 0.15)  # snout
    face(m, head, eye=0.24, spacing=0.26, ez=0.1, smile=False, white="petwhite", iris="eyeink")
    for k in range(5):  # a crown of fins
        m.relief("star", [(-0.12, 0), (0.12, 0), (0, 0.4)], 0.06, (-0.3 + k * 0.15, 0.05, 3.25), bevel=0.02, smooth=True)
    m.relief("jellyglow", [(0, 0), (0.6, 0.4), (0.5, -0.35)], 0.06, (0, 0.35, 1.9), rot=(0, 0, 90), bevel=0.03, smooth=True)
    return m


# ------------------------------------------------------------------------------------------
# WORLD 7: Candy Mainframe
# ------------------------------------------------------------------------------------------
def gummy_cub():
    m = Meme("GummyCub")
    m.blob("gummy", (1.5, 1.3, 1.7), (0, 0.1, 1.0))
    head = head_blob(m, "gummy", (0, -0.05, 2.2, 1.4, 1.2, 1.2))
    face(m, head, eye=0.22, spacing=0.22, white="eyeink", blush="petwhite")
    for sx in (-1, 1):
        m.blob("gummy", (0.45, 0.35, 0.45), (sx * 0.55, 0, 2.8))
        m.blob("gummy", (0.45, 0.45, 0.8), (sx * 0.8, -0.2, 1.3), rot=(0, sx * 25, 0))
        m.blob("gummy", (0.6, 0.65, 0.45), (sx * 0.45, -0.3, 0.25))
    m.blob("petwhite", (0.3, 0.1, 0.2), (0.4, front_y(head, 0.4, 0.4), 2.65))  # sugar shine
    return m


def donut_pup():
    m = Meme("DonutPup")
    m.blob("donut", (1.3, 1.8, 1.2), (0, 0.2, 1.0))
    head = head_blob(m, "donut", (0, -0.7, 1.95, 1.4, 1.25, 1.2))
    m.blob("petwhite", (0.55, 0.5, 0.42), (0, -1.25, 1.75))
    m.blob("eyeink", (0.18, 0.1, 0.13), (0, -1.52, 1.85))
    face(m, head, eye=0.22, spacing=0.24, ez=0.15, smile=False)
    for sx in (-1, 1):
        m.blob("frosting", (0.42, 0.3, 0.8), (sx * 0.72, -0.65, 2.15), rot=(0, sx * 30, 0))
    legs4(m, "donut", 0.38, -0.3, 0.75, 0.6, length=0.5, r=0.17)
    # a frosted donut swim ring around its middle
    m.torus("donut", 0.75, 0.3, (0, 0.2, 1.05), scale=(1, 1.2, 1))
    m.torus("frosting", 0.75, 0.26, (0, 0.2, 1.15), scale=(1, 1.2, 0.8))
    for k in range(10):
        a = math.radians(k * 36)
        m.box("sprinkle1" if k % 2 else "sprinkle2", (0.2, 0.06, 0.06), (math.cos(a) * 0.78, 0.2 + math.sin(a) * 0.92, 1.38), rot=(0, 0, k * 47), bevel=0.02)
    m.blob("donut", (0.3, 0.3, 0.3), (0, 1.15, 1.35))  # tail
    return m


def lollipop_sheep():
    m = Meme("LollipopSheep")
    for (x, y, z) in ((0, 0.2, 1.35), (0.5, 0.0, 1.5), (-0.5, 0.0, 1.5), (0.45, 0.6, 1.4), (-0.45, 0.6, 1.4), (0, 0.4, 1.85), (0, -0.25, 1.75)):
        m.blob("cottoncandy", (1.0, 1.0, 0.95), (x, y, z))  # cotton candy wool
    legs4(m, "eyeink", 0.4, -0.25, 0.75, 0.9, length=0.8, r=0.14)
    head = head_blob(m, "petwhite", (0, -0.8, 1.75, 1.0, 0.9, 1.0))
    face(m, head, eye=0.26, spacing=0.22, ez=0.0)
    for sx in (-1, 1):
        m.cyl("chrome", 0.04, 0.5, (sx * 0.45, -0.7, 2.4), rot=(0, sx * 30, 0), seg=8)  # lollipop horns
        m.cyl("lolly", 0.28, 0.1, (sx * 0.62, -0.7, 2.68), rot=(90, 0, 0), seg=24)
        for k in range(3):
            m.torus("petwhite", 0.08 + k * 0.08, 0.025, (sx * 0.62, -0.77, 2.68), rot=(90, 0, 0))
        m.blob("petwhite", (0.4, 0.15, 0.25), (sx * 0.55, -0.7, 2.0), rot=(0, sx * 30, 0))
    m.blob("cottoncandy", (0.5, 0.5, 0.4), (0, -0.75, 2.3))
    return m


def cupcake_cat():
    m = Meme("CupcakeCat")
    m.cyl("cupcake", 0.95, 1.0, (0, 0, 0.5), radius2=1.15, seg=20)  # the paper cup
    for k in range(20):
        a = math.radians(k * 18)
        m.box("petwhite", (0.08, 0.06, 0.95), (math.cos(a) * 1.07, math.sin(a) * 1.07, 0.52), rot=(0, 0, math.degrees(a)), bevel=0.02)
    head = head_blob(m, "puptan", (0, 0, 1.6, 1.7, 1.5, 1.4))
    face(m, head, eye=0.2, spacing=0.22, ez=-0.05)
    for sx in (-1, 1):
        ear(m, "puptan", "blush", sx * 0.5, 0.05, 2.0, 0.5, 0.6, tilt=sx * 15)
        m.blob("puptan", (0.35, 0.35, 0.3), (sx * 0.6, -0.75, 1.1))  # paws on the rim
    # frosting hat with a cherry
    m.lathe("frosting", [(0, 2.1), (0.62, 2.12), (0.6, 2.3), (0.42, 2.45), (0.38, 2.6), (0.18, 2.75), (0, 2.85)], (0.25, 0.1, 0.2), seg=24)
    m.blob("cherry", (0.3, 0.3, 0.3), (0.25, 0.1, 3.18))
    m.tube("bamboodark", [(0.25, 0.1, 3.3), (0.32, 0.15, 3.55)], 0.03)
    for k in range(6):
        a = math.radians(k * 60)
        m.box("sprinkle1" if k % 2 else "sprinkle2", (0.14, 0.05, 0.05), (0.25 + math.cos(a) * 0.4, 0.1 + math.sin(a) * 0.4, 2.48), rot=(0, 0, k * 40), bevel=0.02)
    return m


def sugar_dragon():
    m = Meme("SugarDragon")
    m.blob("candydragon", (1.6, 1.8, 1.7), (0, 0.2, 1.1))
    m.blob("frosting", (1.0, 0.6, 1.2), (0, -0.55, 1.0))
    head = head_blob(m, "candydragon", (0, -0.6, 2.3, 1.5, 1.35, 1.25))
    m.blob("candydragon", (0.85, 0.65, 0.5), (0, -1.2, 2.1))
    face(m, head, eye=0.22, spacing=0.24, ez=0.15, smile=False)
    for sx in (-1, 1):
        # candy-cane horns
        pts = [(sx * 0.4, -0.45, 2.8), (sx * 0.55, -0.4, 3.2), (sx * 0.75, -0.35, 3.35), (sx * 0.85, -0.4, 3.2)]
        tail_tube(m, "petwhite", pts, 0.1, 0.08)
        for k in range(3):
            m.torus("cherry", 0.1, 0.035, pts[k], rot=(0, 90, 0))
        wing(m, "frosting", sx, sx * 0.55, 0.5, 1.6, 1.3, 1.25, rot=-15)
        m.blob("candydragon", (0.5, 0.65, 0.45), (sx * 0.5, -0.3, 0.25))
    tail_tube(m, "candydragon", [(0, 1.0, 0.6), (0, 1.6, 0.45), (0.3, 2.1, 0.6)], 0.38, 0.1)
    m.blob("cherry", (0.35, 0.35, 0.35), (0.35, 2.25, 0.7))
    for (x, y, z, c) in ((0.4, 0.6, 1.8, "sprinkle1"), (-0.45, 0.5, 1.6, "sprinkle2"), (0.1, 0.9, 1.4, "cherry"), (-0.2, 0.1, 1.95, "sprinkle1")):
        m.box(c, (0.2, 0.07, 0.07), (x, y, z), rot=(0, 30, x * 90), bevel=0.02)
    return m


# ------------------------------------------------------------------------------------------
# WORLD 8: Volcano Forge
# ------------------------------------------------------------------------------------------
def ember_slime():
    m = Meme("EmberSlime")
    m.lathe("ember", [(0, 0), (1.05, 0.05), (1.15, 0.4), (0.95, 1.1), (0.55, 1.6), (0, 1.75)], (0, 0, 0), seg=32)
    head = (0, 0, 0.8, 2.2, 2.2, 1.6)
    face(m, head, eye=0.17, spacing=0.18, ez=0.0, white="eyeink", blush="emberhot")
    for k, (x, z, s) in enumerate(((0, 1.9, 0.6), (0.25, 2.2, 0.35), (-0.2, 2.15, 0.3))):
        m.cyl("emberhot" if k else "phoenix", s * 0.5, s * 1.2, (x, 0.1, z), radius2=0.02, seg=12)
    for (x, y) in ((0.6, 0.6), (-0.7, 0.3), (0.2, 0.85)):
        m.blob("emberhot", (0.25, 0.25, 0.12), (x, y, 0.35 + abs(x) * 0.3))
    return m


def magma_gecko():
    m = Meme("MagmaGecko")
    m.blob("gecko", (1.2, 2.0, 0.9), (0, 0.2, 0.7))
    head = head_blob(m, "gecko", (0, -1.0, 0.95, 1.2, 1.0, 0.8))
    face(m, head, eye=0.28, spacing=0.3, ez=0.2, white="emberhot", iris="eyeink")
    for k in range(4):
        m.box("ember", (0.9 - abs(k - 1.5) * 0.15, 0.12, 0.06), (0, -0.3 + k * 0.38, 1.13), bevel=0.03)  # lava stripes
    for sx in (-1, 1):
        for sy in (-0.45, 0.75):
            tail_tube(m, "gecko", [(sx * 0.5, sy, 0.6), (sx * 0.9, sy - 0.1, 0.3), (sx * 1.0, sy - 0.2, 0.05)], 0.12, 0.1)
            m.blob("ember", (0.3, 0.3, 0.1), (sx * 1.0, sy - 0.25, 0.05))
    pts = [(0, 1.1, 0.6), (0.3, 1.7, 0.4), (0.0, 2.3, 0.3), (-0.4, 2.6, 0.35)]
    tail_tube(m, "gecko", pts, 0.3, 0.06)
    m.cyl("ember", 0.15, 0.35, (0, 0.4, 1.2), radius2=0.02, seg=4)
    return m


def anvil_turtle():
    m = Meme("AnvilTurtle")
    # an anvil for a shell
    m.box("anvil", (1.4, 2.0, 0.5), (0, 0.2, 0.75), bevel=0.08)
    m.box("anvil", (0.9, 1.4, 0.45), (0, 0.2, 1.2), bevel=0.06)
    m.box("anvil", (1.6, 2.4, 0.5), (0, 0.1, 1.65), bevel=0.08)
    m.cyl("anvil", 0.25, 0.8, (0, -1.35, 1.65), rot=(90, 0, 0), radius2=0.03, seg=16)  # horn
    m.box("chrome", (1.5, 2.3, 0.06), (0, 0.1, 1.92), bevel=0.02)
    head = head_blob(m, "bamboodark", (0, -1.25, 0.85, 0.9, 0.9, 0.8))
    face(m, head, eye=0.28, spacing=0.24)
    m.blob("emberhot", (0.75, 0.15, 0.08), (0, -0.85, 1.22))  # a little welding visor
    for sx in (-1, 1):
        for sy in (-0.5, 0.85):
            m.blob("bamboodark", (0.45, 0.5, 0.5), (sx * 0.6, sy, 0.25))
    m.blob("ember", (0.35, 0.35, 0.2), (0.3, 0.6, 2.0))  # a glowing ingot on top
    return m


def lava_golem():
    m = Meme("LavaGolem")
    m.squircle("golem", (1.8, 1.4, 1.6), (0, 0.15, 1.3), power=3)
    m.squircle("golem", (1.3, 1.1, 1.0), (0, -0.05, 2.45), power=3)
    head = (0, -0.05, 2.45, 1.3, 1.1, 1.0)
    for sx in (-1, 1):
        m.box("emberhot", (0.28, 0.08, 0.14), (sx * 0.28, front_y(head, sx * 0.28, 0.05) + 0.02, 2.5), bevel=0.04)  # glowing eyes
        m.squircle("golem", (0.6, 0.6, 1.2), (sx * 1.15, -0.05, 1.3), power=3)  # arms
        m.squircle("basaltpet", (0.7, 0.7, 0.55), (sx * 1.2, -0.1, 0.55), power=3)  # fists
        m.squircle("basaltpet", (0.65, 0.75, 0.5), (sx * 0.45, -0.1, 0.25), power=3)  # feet
    m.box("emberhot", (0.4, 0.06, 0.08), (0, front_y(head, 0, -0.25) + 0.02, 2.2), bevel=0.03)
    # glowing cracks
    for pts in ([(-0.5, -0.56, 1.7), (-0.2, -0.6, 1.4), (-0.35, -0.6, 1.0)], [(0.4, -0.58, 1.8), (0.25, -0.6, 1.3), (0.5, -0.56, 0.9)]):
        m.tube("ember", pts, 0.06)
    m.blob("ember", (0.5, 0.2, 0.5), (0, -0.55, 1.35))  # a lava heart
    return m


def phoenix():
    m = Meme("Phoenix")
    m.blob("phoenix", (1.3, 1.5, 1.7), (0, 0.2, 1.4))
    head = head_blob(m, "phoenix", (0, -0.35, 2.45, 1.15, 1.1, 1.05))
    face(m, head, eye=0.24, spacing=0.24, ez=0.08, smile=False, white="eyeink")
    m.cyl("phoenixgold", 0.15, 0.35, (0, front_y(head, 0, -0.15) - 0.05, 2.3), rot=(90, 0, 0), radius2=0.02, seg=12)  # beak
    for k in range(3):  # flame crest
        m.cyl("phoenixgold" if k == 1 else "ember", 0.14, 0.7 - abs(k - 1) * 0.2, (-0.2 + k * 0.2, -0.2, 3.1), rot=(-20, 0, (k - 1) * 20),
              radius2=0.02, seg=10)
    for sx in (-1, 1):
        # big flame wings: layered feathers
        for k, (c, s) in enumerate((("phoenix", 1.0), ("ember", 0.8), ("phoenixgold", 0.55))):
            wing(m, c, sx, sx * (0.55 + k * 0.05), 0.2 - k * 0.06, 1.3 + k * 0.1, 1.7 * s, 1.6 * s, rot=-10)
        m.blob("phoenixgold", (0.3, 0.45, 0.15), (sx * 0.25, -0.15, 0.08))
        m.cyl("phoenixgold", 0.06, 0.6, (sx * 0.25, 0.1, 0.35), seg=8)
    for k in range(5):  # tail of flames
        a = math.radians(-40 + k * 20)
        m.cyl("phoenixgold" if k % 2 else "ember", 0.18, 1.4, (math.sin(a) * 0.5, 1.4, 0.9 + math.cos(a) * 0.1),
              rot=(-70, 0, -math.degrees(a)), radius2=0.03, seg=10)
    return m


# ------------------------------------------------------------------------------------------
# WORLD 9: Glitch Nexus
# ------------------------------------------------------------------------------------------
def error_cube():
    m = Meme("ErrorCube")
    m.box("glitchblack", (1.9, 1.9, 1.9), (0, 0, 1.15), bevel=0.25)
    for sx in (-1, 1):
        m.box("glitchgreen", (0.3, 0.1, 0.45), (sx * 0.4, -0.95, 1.4), bevel=0.04)
    m.box("glitchgreen", (0.6, 0.1, 0.1), (0, -0.95, 0.9), bevel=0.03)
    # an error sign on top
    m.relief("star", [(-0.55, 0), (0.55, 0), (0, 0.9)], 0.15, (0, 0, 2.15), bevel=0.05)
    m.box("eyeink", (0.1, 0.18, 0.35), (0, -0.05, 2.5), bevel=0.03)
    m.box("eyeink", (0.1, 0.18, 0.1), (0, -0.05, 2.25), bevel=0.03)
    for (x, z) in ((0.95, 1.7), (-0.95, 0.6), (0.6, 2.05)):
        m.box("glitchpink", (0.35, 0.35, 0.2), (x, 0.3, z), bevel=0.04)  # stray pixels
    for sx in (-1, 1):
        m.box("glitchblack", (0.45, 0.5, 0.3), (sx * 0.55, -0.1, 0.12), bevel=0.06)
    return m


def pixel_ghost():
    m = Meme("PixelGhost")
    # stepped like an old 8-bit sprite
    rows = [(1.0, 2.6), (1.6, 2.4), (2.0, 2.15), (2.0, 1.85), (2.0, 1.55), (2.0, 1.25), (2.0, 0.95)]
    for w, z in rows:
        m.box("glitchpink", (w, 1.4, 0.32), (0, 0, z), bevel=0.04)
    for k in range(4):  # the wavy bottom
        m.box("glitchpink", (0.4, 1.4, 0.3), (-0.75 + k * 0.5, 0, 0.65 - (k % 2) * 0.2), bevel=0.04)
    for sx in (-1, 1):
        m.box("petwhite", (0.42, 0.1, 0.5), (sx * 0.4, -0.72, 1.85), bevel=0.04)
        m.box("glitchblack", (0.22, 0.08, 0.26), (sx * 0.4 - 0.08, -0.78, 1.8), bevel=0.03)
        m.box("glitchpink", (0.3, 0.6, 0.3), (sx * 1.15, -0.1, 1.4), bevel=0.04)  # little arms
    m.box("glitchcyan", (0.3, 0.3, 0.3), (0.9, 0.35, 2.5), bevel=0.04)
    m.box("glitchgreen", (0.22, 0.22, 0.22), (-1.0, 0.3, 2.3), bevel=0.04)
    return m


def glitch_cat():
    m = Meme("GlitchCat")
    # a cat sliced into layers that slipped sideways, like a corrupted picture
    shifts = [0.0, 0.18, -0.15, 0.1, -0.2, 0.0]
    for k, dx in enumerate(shifts):
        z = 0.35 + k * 0.3
        m.box("glitchblack" if k % 2 else "nullpurple", (1.5, 1.6, 0.3), (dx, 0.15, z), bevel=0.05)
    head = (0, -0.55, 2.4, 1.5, 1.2, 1.1)
    for k, dx in enumerate((0.12, -0.1, 0.0)):
        m.box("nullpurple" if k % 2 else "glitchblack", (1.5, 1.3, 0.38), (dx, -0.5, 2.05 + k * 0.38), bevel=0.06)
    for sx in (-1, 1):
        m.box("glitchgreen", (0.34, 0.1, 0.24), (sx * 0.35 + 0.1, -1.18, 2.45), bevel=0.04)
        ear(m, "glitchblack", "glitchpink", sx * 0.45, -0.5, 2.85, 0.45, 0.55, tilt=sx * 12)
    m.box("glitchpink", (0.2, 0.08, 0.12), (0.05, -1.18, 2.2), bevel=0.03)
    tail_tube(m, "glitchblack", [(0, 0.95, 0.6), (0.4, 1.3, 1.0), (0.3, 1.4, 1.6), (0.55, 1.3, 1.95)], 0.13, 0.11)
    for (x, z) in ((0.95, 1.4), (-0.95, 2.4), (0.85, 2.8)):
        m.box("glitchcyan", (0.22, 0.22, 0.22), (x, 0.0, z), bevel=0.03)
    return m


def code_bug():
    m = Meme("CodeBug")
    m.blob("glitchblack", (1.6, 2.1, 1.1), (0, 0.25, 0.95))
    m.box("glitchgreen", (0.06, 2.0, 0.06), (0, 0.3, 1.5), bevel=0.02)
    for k in range(4):  # code on its shell, as glowing dashes
        for j in range(3):
            if (k + j) % 3:
                m.box("glitchgreen", (0.2, 0.06, 0.05), (0.2 + j * 0.22, -0.3 + k * 0.4, 1.46 - abs(j - 1) * 0.05), bevel=0.02)
                m.box("glitchgreen", (0.2, 0.06, 0.05), (-0.2 - j * 0.22, -0.3 + k * 0.4, 1.46 - abs(j - 1) * 0.05), bevel=0.02)
    head = head_blob(m, "nullpurple", (0, -0.95, 1.0, 1.15, 0.85, 0.9))
    face(m, head, eye=0.27, spacing=0.22, white="glitchgreen", iris="eyeink")
    for sx in (-1, 1):
        for k in range(3):
            m.tube("nullpurple", [(sx * 0.65, -0.3 + k * 0.5, 0.6), (sx * 1.1, -0.35 + k * 0.55, 0.35), (sx * 1.2, -0.4 + k * 0.55, 0.0)], 0.07)
        m.tube("nullpurple", [(sx * 0.2, -1.2, 1.35), (sx * 0.45, -1.5, 1.9)], 0.05)
        m.box("glitchgreen", (0.18, 0.18, 0.18), (sx * 0.47, -1.52, 1.97), bevel=0.04)
    return m


def null_unicorn():
    m = Meme("NullUnicorn")
    m.blob("nullpurple", (1.4, 2.1, 1.3), (0, 0.25, 1.35))
    tail_tube(m, "nullpurple", [(0, -0.6, 1.55), (0, -0.85, 2.05), (0, -0.95, 2.4)], 0.38, 0.32)  # neck
    head = head_blob(m, "nullpurple", (0, -1.05, 2.7, 0.95, 1.2, 0.9))
    m.blob("glitchblack", (0.75, 0.6, 0.55), (0, -1.55, 2.5))  # muzzle
    face(m, head, eye=0.3, spacing=0.3, ez=0.12, smile=False, white="glitchcyan", iris="eyeink")
    m.cyl("star", 0.13, 0.9, (0, -1.2, 3.45), rot=(-25, 0, 0), radius2=0.02, seg=12)  # horn
    for k in range(4):
        m.torus("petwhite", 0.12 - k * 0.02, 0.025, (0, -1.15 - k * 0.1, 3.2 + k * 0.18), rot=(-25, 0, 0))
    for sx in (-1, 1):
        ear(m, "nullpurple", "glitchpink", sx * 0.3, -0.9, 3.0, 0.3, 0.45, tilt=sx * 12)
    for k in range(6):  # a neon mane
        m.blob("unicornmane" if k % 2 else "glitchpink", (0.45, 0.4, 0.5), (0.05, -0.55 + k * 0.08, 3.05 - k * 0.28))
    legs4(m, "nullpurple", 0.42, -0.4, 0.9, 0.95, length=0.9, r=0.16)
    for sx in (-1, 1):
        for sy in (-0.4, 0.9):
            m.cyl("glitchcyan", 0.2, 0.12, (sx * 0.42, sy, 0.06), seg=16)  # glowing hooves
    for k in range(4):  # a flowing neon tail
        m.blob("unicornmane" if k % 2 else "glitchpink", (0.5 - k * 0.06, 0.5, 0.45), (0.1 * k, 1.35 + k * 0.25, 1.5 - k * 0.25))
    for (x, y, z) in ((0.75, 0.0, 1.9), (-0.75, 0.5, 1.6)):
        m.box("glitchgreen", (0.2, 0.2, 0.2), (x, y, z), bevel=0.03)
    return m


# ------------------------------------------------------------------------------------------
# EGGS: one per world, about 3.2 tall
# ------------------------------------------------------------------------------------------
EGG_H, EGG_R = 3.2, 1.15


def egg_r(t):
    """Egg radius at height fraction t (0 = bottom, 1 = top): wider low, narrower on top."""
    t = max(0.0, min(1.0, t))
    return EGG_R * math.sin(math.pi * t) ** 0.75 * (1.08 - 0.22 * t)


def egg_point(a_deg, t, out=0.0):
    a = math.radians(a_deg)
    r = egg_r(t) + out
    return (math.cos(a) * r, math.sin(a) * r, t * EGG_H)


def egg_shell(m, color, base="eyeink"):
    prof = [(0, 0.02)] + [(egg_r(k / 24), k / 24 * EGG_H) for k in range(1, 24)] + [(0, EGG_H)]
    m.lathe(color, prof, (0, 0, 0), seg=40)


def egg_band(m, color, t, thick=0.09, out=0.0):
    m.torus(color, egg_r(t) + out, thick, (0, 0, t * EGG_H))


def on_shell(m, color, a, t, size, shape="blob", out=0.0):
    x, y, z = egg_point(a, t, out)
    tilt = (0.5 - t) * 70
    if shape == "blob":
        m.blob(color, size, (x, y, z), rot=(0, tilt, a))
    else:
        m.box(color, size, (x, y, z), rot=(0, tilt, a), bevel=min(size) * 0.3)


def byte_egg():
    m = Meme("ByteEgg")
    egg_shell(m, "eggwhite")
    egg_band(m, "netcyan", 0.48, 0.1)
    egg_band(m, "netnavy", 0.42, 0.05)
    for k in range(14):
        a, t = k * 51 % 360, 0.18 + (k * 37 % 60) / 100
        if abs(t - 0.45) > 0.06:
            on_shell(m, "netnavy" if k % 3 else "netcyan", a, t, (0.07, 0.24, 0.24), shape="box")
    m.blob("owllilac", (0.7, 0.7, 0.3), (0, 0, EGG_H - 0.08))
    return m


def blossom_egg():
    m = Meme("BlossomEgg")
    egg_shell(m, "sakura")
    egg_band(m, "star", 0.4, 0.08)
    for k in range(9):
        a, t = k * 40, 0.62 if k % 2 else 0.22
        for j in range(5):  # a five-petal blossom
            b = math.radians(j * 72)
            da = math.degrees(math.cos(b) * 0.17 / max(egg_r(t), 0.3))
            on_shell(m, "petwhite", a + da, t + math.sin(b) * 0.17 / EGG_H, (0.08, 0.22, 0.22))
        on_shell(m, "sakuradeep", a, t, (0.1, 0.12, 0.12), out=0.02)
    m.blob("petwhite", (0.5, 0.5, 0.25), (0, 0, EGG_H - 0.05))
    return m


def cosmic_egg():
    m = Meme("CosmicEgg")
    egg_shell(m, "cosmosdeep")
    egg_band(m, "nebula", 0.3, 0.12)
    egg_band(m, "nebulapink", 0.7, 0.07)
    for k in range(12):
        a, t = k * 67 % 360, 0.15 + (k * 29 % 70) / 100
        on_shell(m, "star", a, t, (0.08, 0.16 if k % 2 else 0.1, 0.16 if k % 2 else 0.1))
    m.torus("planetring", 1.55, 0.09, (0, 0, 1.4), rot=(18, 0, 0), scale=(1, 1, 1))  # a planet ring around it
    m.torus("star", 1.7, 0.05, (0, 0, 1.4), rot=(18, 0, 0))
    return m


def frost_egg():
    m = Meme("FrostEgg")
    egg_shell(m, "eggice")
    # a snowy cap and icicles
    m.lathe("petwhite", [(0, EGG_H + 0.05), (egg_r(0.82) + 0.06, 0.8 * EGG_H), (egg_r(0.78) + 0.08, 0.76 * EGG_H)], (0, 0, 0), seg=40)
    for k in range(12):
        a = k * 30
        x, y, z = egg_point(a, 0.77, 0.04)
        m.cyl("petwhite", 0.08, 0.3 + (k % 3) * 0.12, (x, y, z - 0.2 - (k % 3) * 0.06), rot=(180, 0, 0), radius2=0.01, seg=6)
    for k in range(6):  # crystals at its foot
        a = k * 60 + 15
        x, y, z = egg_point(a, 0.12, 0.05)
        m.cyl("icecrystal", 0.14, 0.6, (x, y, z + 0.1), rot=(math.sin(math.radians(a)) * -30, math.cos(math.radians(a)) * 30, 0), radius2=0.02, seg=6)
    for k in range(5):
        on_shell(m, "petwhite", k * 72 + 30, 0.45, (0.06, 0.22, 0.22))
    return m


def chrome_egg():
    m = Meme("ChromeEgg")
    egg_shell(m, "eggchrome")
    for t in (0.3, 0.38, 0.7):
        egg_band(m, "sphinx", t, 0.07)
    for k in range(6):
        on_shell(m, "sphinxblue", k * 60, 0.53, (0.07, 0.22, 0.3), shape="box")
    x, y, z = egg_point(-90, 0.53, 0.05)
    m.relief("sphinx", star_pts(0.35, 0.18, n=10), 0.06, (x, y, z), bevel=0.02)  # sun emblem facing front
    m.cyl("sphinx", 0.25, 0.2, (0, 0, EGG_H - 0.05), radius2=0.08, seg=20)
    return m


def coral_egg():
    m = Meme("CoralEgg")
    egg_shell(m, "eggteal")
    egg_band(m, "puffer", 0.62, 0.06)
    for k in range(5):  # coral branches growing up its sides
        a = k * 72
        x, y, z = egg_point(a, 0.08, 0.02)
        r = math.radians(a)
        pts = [(x, y, z), (x * 1.08, y * 1.08, z + 0.5), (x * 1.18 + math.sin(r) * 0.15, y * 1.18 - math.cos(r) * 0.15, z + 1.0)]
        tail_tube(m, "coral", pts, 0.12, 0.06, seg=8)
        m.blob("coral", (0.18, 0.18, 0.18), pts[-1])
    for k in range(8):
        on_shell(m, "bubble", k * 45 + 20, 0.75 + (k % 3) * 0.05, (0.08, 0.16, 0.16))
    return m


def candy_egg():
    m = Meme("CandyEgg")
    egg_shell(m, "eggcandy")
    for j, c in enumerate(("frosting", "lolly", "sprinkle1")):  # pastel swirl stripes
        pts = [egg_point(j * 120 + k * 22, 0.08 + k * 0.042, 0.02) for k in range(21)]
        tail_tube(m, c, pts, 0.09, 0.09, seg=8)
    for k in range(10):
        on_shell(m, "cherry" if k % 2 else "sprinkle2", k * 37, 0.85 - (k % 3) * 0.05, (0.06, 0.18, 0.06), shape="box")
    m.blob("cherry", (0.38, 0.38, 0.38), (0, 0, EGG_H + 0.12))
    m.tube("bamboodark", [(0, 0, EGG_H + 0.28), (0.12, 0.05, EGG_H + 0.55)], 0.04)
    return m


def magma_egg():
    m = Meme("MagmaEgg")
    egg_shell(m, "eggmagma")
    for j in range(4):  # glowing cracks
        a0 = j * 90 + 20
        pts = [egg_point(a0 + math.sin(k * 1.7) * 14, 0.15 + k * 0.1, 0.03) for k in range(7)]
        m.tube("ember", pts, 0.06, seg=8)
    egg_band(m, "ember", 0.12, 0.08)
    m.lathe("emberhot", [(0, EGG_H - 0.4), (0.4, EGG_H - 0.25), (0, EGG_H + 0.04)], (0, 0, 0), seg=24)  # a molten top
    return m


def glitch_egg():
    m = Meme("GlitchEgg")
    # the shell sliced into bands that slipped sideways
    for k in range(8):
        t0, t1 = k / 8, (k + 1) / 8
        prof = [(egg_r(t0 + (t1 - t0) * s / 4), (t0 + (t1 - t0) * s / 4) * EGG_H) for s in range(5)]
        if k == 0:
            prof = [(0, 0.02)] + prof[1:]
        if k == 7:
            prof = prof[:-1] + [(0, EGG_H)]
        dx = (0.0, 0.1, -0.08, 0.14, 0.0, -0.12, 0.06, 0.0)[k]
        m.lathe("eggglitch" if k % 2 else "glitchblack", prof, (dx, 0, 0), seg=32)
    for k in range(10):
        on_shell(m, "glitchgreen" if k % 2 else "glitchcyan", k * 41, 0.2 + (k * 13 % 60) / 100, (0.08, 0.2, 0.2), shape="box", out=0.08)
    return m


# ------------------------------------------------------------------------------------------
# THE RELIC EGG (bought with Robux): an ancient golden egg dug up from the old internet, and
# its five exclusive pets (Rare, Rare, Epic, Epic, Legendary)
# ------------------------------------------------------------------------------------------
def relic_egg():
    m = Meme("RelicEgg")
    egg_shell(m, "relicgold")
    egg_band(m, "relicteal", 0.3, 0.1)
    egg_band(m, "relicteal", 0.68, 0.08)
    for k in range(12):  # a ring of carved glyph tiles, leaving room for the ruby on the front
        a = k * 30
        if abs(a - 270) > 25:
            on_shell(m, "relicgolddark" if k % 2 else "relicteal", a, 0.49, (0.08, 0.2, 0.28), shape="box")
    x, y, z = egg_point(-90, 0.49, 0.04)
    m.blob("relicgolddark", (0.62, 0.22, 0.62), (x, y + 0.04, z))  # the ruby's gold setting
    m.blob("relicruby", (0.46, 0.2, 0.46), (x, y - 0.04, z))
    m.blob("petwhite", (0.1, 0.05, 0.1), (x + 0.1, y - 0.14, z + 0.1))
    for k in range(5):
        on_shell(m, "relicruby", k * 72 + 18, 0.14, (0.1, 0.2, 0.2))
        on_shell(m, "relicteal", k * 72 + 54, 0.84, (0.08, 0.15, 0.15))
    m.cyl("relicgolddark", 0.24, 0.22, (0, 0, EGG_H - 0.02), radius2=0.12, seg=20)
    m.blob("relicruby", (0.28, 0.28, 0.28), (0, 0, EGG_H + 0.18))
    return m


def fossil_rex():
    m = Meme("FossilRex")
    m.blob("bone", (1.4, 1.7, 1.5), (0, 0.3, 1.25))
    for k in range(4):  # rib bands, like a fossil
        m.torus("bonedark", 0.66, 0.06, (0, -0.05 + k * 0.25, 1.3), rot=(90, 0, 0), scale=(1.0, 1.0, 1.08))
    head = head_blob(m, "bone", (0, -0.7, 2.35, 1.3, 1.4, 1.1))
    m.blob("bone", (1.05, 0.8, 0.5), (0, -1.3, 2.02))  # snout
    face(m, head, eye=0.24, spacing=0.24, ez=0.17, smile=False)
    for x in (-0.3, -0.1, 0.1, 0.3):  # little teeth
        m.cyl("petwhite", 0.06, 0.16, (x, -1.58, 1.82), rot=(180, 0, 0), radius2=0.01, seg=6)
    for sx in (-1, 1):
        m.blob("eyeink", (0.08, 0.08, 0.06), (sx * 0.16, -1.69, 2.12))  # nostrils
        m.tube("bone", [(sx * 0.55, -0.45, 1.5), (sx * 0.62, -0.8, 1.32)], 0.1)  # tiny arms
        m.blob("bone", (0.55, 0.7, 0.8), (sx * 0.45, 0.35, 0.6))  # legs
        m.blob("bonedark", (0.5, 0.75, 0.25), (sx * 0.45, 0.12, 0.12))
    tail_tube(m, "bone", [(0, 1.0, 1.1), (0, 1.6, 0.9), (0, 2.1, 0.72), (0, 2.45, 0.66)], 0.45, 0.1)
    for k in range(4):  # stone plates down its back
        m.cyl("relicstone", 0.17, 0.32, (0, 0.0 + k * 0.32, 2.0 - k * 0.12), radius2=0.02, seg=4)
    return m


def mummy_cat():
    m = Meme("MummyCat")
    m.blob("bandage", (1.5, 1.4, 1.5), (0, 0.15, 0.85))
    head = head_blob(m, "bandage", (0, -0.25, 2.05, 1.5, 1.3, 1.2))
    for k, z in enumerate((0.45, 0.8, 1.15)):  # wraps around the body
        m.torus("bandagedark", 0.72, 0.06, (0, 0.15, z), rot=(0, (k - 1) * 10, 0), scale=(1, 0.93, 1))
    for k, z in enumerate((1.75, 2.42)):  # ...and the head
        m.torus("bandagedark", 0.68 if k == 0 else 0.62, 0.06, (0, -0.25, z), rot=(0, 8 - k * 16, 0), scale=(1, 0.86, 1))
    # one big glowing eye peeking out, the other bandaged over
    y = front_y(head, -0.33, 0.1)
    m.eye((-0.33, y + 0.05, 2.17), (0.42, 0.25, 0.48), iris="relicteal", white="eyeink")
    m.box("bandagedark", (0.55, 0.14, 0.16), (0.33, front_y(head, 0.33, 0.1) - 0.02, 2.17), rot=(0, -18, 0), bevel=0.05)
    m.blob("blush", (0.24, 0.06, 0.12), (0.4, front_y(head, 0.4, -0.15) + 0.02, 1.9))
    for sx in (-1, 1):
        ear(m, "bandage", "blush", sx * 0.45, -0.2, 2.45, 0.45, 0.55, tilt=sx * 15)
        m.blob("bandage", (0.4, 0.5, 0.3), (sx * 0.35, -0.5, 0.15))  # paws
    tail_tube(m, "bandage", [(0, 0.8, 0.4), (0.4, 1.2, 0.5), (0.6, 1.3, 1.0), (0.5, 1.2, 1.4)], 0.14, 0.1)
    m.blob("relicgold", (0.32, 0.12, 0.3), (0, -0.58, 1.3))  # a scarab amulet
    m.blob("relicteal", (0.16, 0.08, 0.15), (0, -0.64, 1.3))
    return m


def totem_owl():
    m = Meme("TotemOwl")
    m.squircle("totemwood", (1.6, 1.4, 2.4), (0, 0, 1.3), power=3)  # a carved wooden post
    m.box("relicteal", (1.66, 1.46, 0.2), (0, 0, 0.5), bevel=0.05)
    m.box("totemred", (1.66, 1.46, 0.16), (0, 0, 0.74), bevel=0.05)
    for sx in (-1, 1):  # big round gold eyes
        m.cyl("relicgold", 0.38, 0.12, (sx * 0.38, -0.7, 1.95), rot=(90, 0, 0), seg=24)
        m.cyl("eyeink", 0.2, 0.14, (sx * 0.38, -0.74, 1.95), rot=(90, 0, 0), seg=20)
        m.blob("petwhite", (0.09, 0.05, 0.09), (sx * 0.38 + 0.07, -0.82, 2.03))
        m.cyl("totemwood", 0.22, 0.6, (sx * 0.55, 0, 2.62), rot=(0, sx * 25, 0), radius2=0.03, seg=4)  # ear tufts
        wing(m, "totemred", sx, sx * 0.75, 0.1, 1.15, 1.1, 1.35, rot=0)
        wing(m, "relicteal", sx, sx * 0.78, 0.02, 1.2, 0.72, 0.9, rot=0)
        m.blob("relicgold", (0.35, 0.4, 0.15), (sx * 0.35, -0.45, 0.08))  # feet
    m.cyl("relicgold", 0.16, 0.38, (0, -0.78, 1.62), rot=(90, 0, 0), radius2=0.02, seg=4)  # beak
    for k in range(2):  # gold chevrons carved into its belly
        m.relief("relicgold", [(-0.35, 0), (0, -0.25), (0.35, 0), (0.35, 0.13), (0, -0.12), (-0.35, 0.13)], 0.08,
                 (0, -0.72, 1.12 - k * 0.24))
    return m


def idol_monkey():
    m = Meme("IdolMonkey")
    m.squircle("relicstone", (1.8, 1.6, 0.5), (0, 0, 0.25), power=4)  # a stone plinth
    m.box("relicstonedark", (1.84, 1.64, 0.1), (0, 0, 0.44), bevel=0.03)
    m.blob("relicgold", (1.4, 1.2, 1.3), (0, 0.1, 1.15))
    head = head_blob(m, "relicgold", (0, -0.2, 2.2, 1.4, 1.2, 1.15))
    m.blob("relicgolddark", (0.9, 0.5, 0.6), (0, -0.7, 2.0))  # muzzle
    for sx in (-1, 1):
        m.cyl("relicgold", 0.32, 0.18, (sx * 0.78, -0.1, 2.3), rot=(90, 0, 0), seg=20)  # round ears
        m.cyl("relicgolddark", 0.2, 0.2, (sx * 0.78, -0.14, 2.3), rot=(90, 0, 0), seg=16)
        x = sx * 0.28
        y = front_y(head, x, 0.2)
        m.blob("relicruby", (0.26, 0.12, 0.3), (x, y + 0.02, 2.4))  # ruby eyes
        m.blob("petwhite", (0.07, 0.04, 0.07), (x + 0.06, y - 0.04, 2.47))
        m.tube("relicgold", [(sx * 0.6, -0.05, 1.5), (sx * 0.55, -0.5, 1.2), (sx * 0.25, -0.68, 1.1)], 0.13)  # arms
        m.blob("relicgold", (0.6, 0.8, 0.4), (sx * 0.4, -0.35, 0.7))  # crossed legs
    m.tube("eyeink", [(-0.18, -0.96, 1.92), (0, -0.99, 1.86), (0.18, -0.96, 1.92)], 0.035, seg=8)  # a smile
    m.torus("relicteal", 0.64, 0.07, (0, -0.2, 2.58), scale=(1.05, 0.92, 1))  # a headband
    m.blob("relicteal", (0.42, 0.32, 0.42), (0, -0.78, 1.1))  # the gem it holds
    tail_tube(m, "relicgold", [(0, 0.7, 0.8), (0.5, 1.0, 0.9), (0.7, 0.9, 1.4), (0.5, 0.8, 1.7)], 0.12, 0.08)
    return m


def relic_dragon():
    m = Meme("RelicDragon")
    m.blob("relicgold", (1.5, 1.9, 1.8), (0, 0.25, 1.2))
    m.blob("relicteal", (1.0, 0.6, 1.3), (0, -0.5, 1.1))  # belly
    for k in range(4):
        m.box("relicgolddark", (0.8, 0.08, 0.07), (0, -0.79, 0.72 + k * 0.27), bevel=0.02)
    head = head_blob(m, "relicgold", (0, -0.75, 2.4, 1.45, 1.35, 1.2))
    m.blob("relicgolddark", (0.85, 0.7, 0.5), (0, -1.35, 2.18))  # snout
    face(m, head, eye=0.24, spacing=0.24, ez=0.15, white="petwhite", iris="relicteal", smile=False)
    m.blob("relicruby", (0.3, 0.14, 0.3), (0, front_y(head, 0, 0.4) + 0.03, 2.84))  # a ruby on its brow
    for sx in (-1, 1):
        m.blob("eyeink", (0.1, 0.1, 0.08), (sx * 0.18, -1.7, 2.24))
        m.cyl("relicteal", 0.13, 0.8, (sx * 0.42, -0.5, 3.15), rot=(-25, sx * 20, 0), radius2=0.02, seg=12)  # horns
        wing(m, "relicgold", sx, sx * 0.6, 0.55, 1.6, 1.8, 1.7, rot=-15)
        wing(m, "relicteal", sx, sx * 0.62, 0.47, 1.7, 1.35, 1.25, rot=-15)
        m.blob("relicgold", (0.55, 0.7, 0.5), (sx * 0.55, -0.35, 0.25))  # feet
        for t in (-1, 0, 1):
            m.cyl("bone", 0.06, 0.16, (sx * 0.55 + t * 0.15, -0.72, 0.15), rot=(90, 0, 0), radius2=0.01, seg=6)
    tail_tube(m, "relicgold", [(0, 1.0, 0.6), (0, 1.7, 0.45), (0.3, 2.3, 0.6), (0.5, 2.6, 1.0)], 0.4, 0.1)
    m.cyl("relicteal", 0.3, 0.45, (0.55, 2.7, 1.25), radius2=0.02, seg=4)
    for k in range(4):
        m.cyl("relicteal", 0.16, 0.36, (0, 0.0 + k * 0.38, 2.2 - k * 0.12), radius2=0.02, seg=4)
    m.torus("relicgold", 0.55, 0.06, (0, -0.65, 3.8), rot=(15, 0, 0))  # a golden halo
    return m


RELIC = (relic_egg, [fossil_rex, mummy_cat, totem_owl, idol_monkey, relic_dragon])

WORLDS = [
    (byte_egg,[pixel_pup, buffer_snail, floppy_frog, wifi_owl, server_dragon]),
    (blossom_egg, [petal_bunny, lantern_moth, koi_bot, bamboo_panda, blossom_kitsune]),
    (cosmic_egg, [star_blob, comet_pup, planet_turtle, astro_axolotl, nebula_whale]),
    (frost_egg, [snow_seal, penguin_bot, ice_fox, yeti_cub, crystal_mammoth]),
    (chrome_egg, [sand_beetle, cactus_cat, drone_camel, chrome_scorpion, sun_sphinx]),
    (coral_egg, [bubble_fish, crab_bot, jelly_lamp, octo_hacker, tide_seahorse]),
    (candy_egg, [gummy_cub, donut_pup, lollipop_sheep, cupcake_cat, sugar_dragon]),
    (magma_egg, [ember_slime, magma_gecko, anvil_turtle, lava_golem, phoenix]),
    (glitch_egg, [error_cube, pixel_ghost, glitch_cat, code_bug, null_unicorn]),
]
BUILDERS = [b for egg, pets in WORLDS + [RELIC] for b in [egg] + pets]


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    preview = os.path.join(memekit.ROOT, "assets", "models", "previews")
    os.makedirs(preview, exist_ok=True)
    if "--relic-sheet" in args:  # just the Relic Egg row, to look at it quickly
        memekit.sheet([RELIC[0]] + RELIC[1], os.path.join(preview, "Sheet_relic_pets.png"), per_row=6, cell=300)
        return
    if "--no-sheet" not in args:
        memekit.sheet(BUILDERS, os.path.join(preview, "Sheet_pets.png"), per_row=6, cell=300)
    memekit.reset()
    objs, sizes = [], []
    for i, build in enumerate(BUILDERS):
        obj = build().finish(max_tris=6000)
        xs = [v.co.x for v in obj.data.vertices]
        ys = [v.co.y for v in obj.data.vertices]
        zs = [v.co.z for v in obj.data.vertices]
        # Roblox size: x stays, Blender z (up) -> Roblox y, Blender y (depth) -> Roblox z
        sizes.append((obj.name, max(xs) - min(xs), max(zs) - min(zs), max(ys) - min(ys)))
        obj.location = ((i % 6) * 6, (i // 6) * 6, 0)
        objs.append(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    path = os.path.join(memekit.OUT, "PetMeshes.fbx")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="COPY", embed_textures=True,
                             bake_space_transform=True)
    lines = ["-- PetMeshData (ModuleScript in ReplicatedStorage)",
             "-- Written by tools/blender/pets.py: the size (studs, as modeled) of every pet and egg mesh.",
             "-- File > Import 3D of assets/models/PetMeshes.fbx + the installer put the meshes in",
             "-- ReplicatedStorage > PetModels. The game scales each one to the size it wants.",
             "return {"]
    for name, x, y, z in sizes:
        lines.append("\t%s = {Size = Vector3.new(%.3f, %.3f, %.3f)}," % (name, x, y, z))
    lines.append("}")
    with open(OUT_LUA, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("wrote", path, "and", OUT_LUA, "with", len(objs), "meshes")


if __name__ == "__main__":  # (promo.py imports the builders without exporting)
    main()
