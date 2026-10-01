"""Builds the game's UI icons as chunky cartoon 3D models in Blender (run with bpy), in the
style of big simulator games: bold shapes, bright colors and a thick dark outline (an
inverted-hull shell, which Roblox draws as an outline because it hides back faces).

Writes:
  assets/models/UIIcons.fbx        every icon, for one File > Import 3D in Studio (the
                                   installer moves them to ReplicatedStorage > UIIcons, and
                                   UIKit.icon shows them as live 3D icons in the UI)
  assets/ui/icons/<Name>.png       a rendered picture of each icon (transparent background)
  assets/ui/icons/_sheet.png       all of them on one sheet
  src/shared/UIIconList.lua        the icon names (so the installer knows what to collect)

Coordinates: z is up, the icon faces -y (Blender's front), about 4 units tall.
Run:  python tools/blender/ui_icons.py [names...]
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402  (bpy first: it makes bmesh importable)
import bmesh  # noqa: E402
from mathutils import Vector  # noqa: E402

import memekit  # noqa: E402
from memekit import Meme, cell_uv  # noqa: E402

PNG_DIR = os.path.join(memekit.ROOT, "assets", "ui", "icons")
LUA_OUT = os.path.join(memekit.ROOT, "src", "shared", "UIIconList.lua")
OUTLINE = 0.09
R = math.radians


# ------------------------------------------------------------------------------------------
# extra shapes
# ------------------------------------------------------------------------------------------
def prism(m, color, pts, depth, loc=(0, 0, 0), rot=(0, 0, 0), bevel=0.06):
    """A flat shape drawn in the x-z plane (seen from the front), extruded along y."""
    bm = bmesh.new()
    front = [bm.verts.new((x, -depth / 2, z)) for x, z in pts]
    back = [bm.verts.new((x, depth / 2, z)) for x, z in pts]
    bm.faces.new(front)
    bm.faces.new(back[::-1])
    n = len(pts)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((front[i], front[j], back[j], back[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    if bevel > 0:
        try:
            bmesh.ops.bevel(bm, geom=bm.edges[:], offset=bevel, segments=2, affect="EDGES", clamp_overlap=True)
        except Exception:
            pass
    me = bpy.data.meshes.new("prism")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("prism", me)
    bpy.context.scene.collection.objects.link(o)
    m._place(o, loc, rot, (1, 1, 1))
    return m._add(o, color, smooth=False)


def star_pts(points, outer, inner, turn=90):
    pts = []
    for i in range(points * 2):
        a = R(turn) + math.pi * i / points
        r = outer if i % 2 == 0 else inner
        pts.append((r * math.cos(a), r * math.sin(a)))
    return pts


def heart_pts(size, steps=40):
    pts = []
    for i in range(steps):
        t = 2 * math.pi * i / steps
        x = 16 * math.sin(t) ** 3
        z = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        pts.append((x * size / 32, z * size / 32))
    return pts


def arc(cx, cz, radius, a0, a1, y=0.0, steps=16):
    return [(cx + radius * math.cos(R(a0 + (a1 - a0) * i / steps)), y, cz + radius * math.sin(R(a0 + (a1 - a0) * i / steps)))
            for i in range(steps + 1)]


def cone_along(m, color, base, direction, length, radius, seg=16):
    """A cone from base pointing along a direction in the x-z plane (arrow heads)."""
    dx, dz = direction
    angle = math.degrees(math.atan2(dx, dz))
    cx, cy, cz = base
    centre = (cx + dx * length / 2, cy, cz + dz * length / 2)
    return m.cyl(color, radius, length, centre, rot=(0, angle, 0), seg=seg, radius2=0.0)


def eyes(m, z, spread, y, size=(0.32, 0.2, 0.42), pupil=True):
    for s in (-1, 1):
        if pupil:
            m.blob("white", (size[0] * 1.25, size[1], size[2] * 1.15), (s * spread, y, z))
            m.blob("black", (size[0] * 0.7, size[1], size[2] * 0.7), (s * spread, y - 0.06, z - 0.03))
            m.blob("white", (size[0] * 0.25, 0.08, size[2] * 0.22), (s * spread + 0.06, y - 0.12, z + 0.07))
        else:
            m.blob("black", size, (s * spread, y, z))


# ------------------------------------------------------------------------------------------
# icons
# ------------------------------------------------------------------------------------------
def shop():
    m = Meme("Shop")
    m.cyl("red", 1.5, 2.0, (0, 0, 1.0), rot=(0, 0, 45), seg=4, radius2=2.0, scale=(1, 0.75, 1))  # basket, wider at the top
    for x in (-0.62, 0, 0.62):  # slots in the front
        m.box("darkred", (0.34, 0.24, 1.15), (x, -0.99, 1.0), rot=(-7, 0, 0), bevel=0.06)
    m.box("darkred", (3.05, 2.3, 0.32), (0, 0, 2.05), bevel=0.14)  # rim
    m.torus("lightgray", 1.0, 0.16, (0, 0, 2.1), rot=(90, 0, 0), scale=(1.2, 1, 1.3))  # handle
    m.box("white", (0.6, 0.08, 0.12), (-0.95, -1.16, 2.12), bevel=0.04)  # shine
    return m


def bag():
    m = Meme("Bag")
    m.squircle("orange", (2.8, 1.5, 3.2), (0, 0, 1.7), power=3)
    m.squircle("brown", (2.9, 1.55, 1.2), (0, -0.05, 2.75), power=3)  # flap
    m.squircle("orange", (2.0, 0.6, 1.3), (0, -0.7, 1.15), power=3)  # front pocket
    m.box("brown", (2.0, 0.12, 0.12), (0, -1.02, 1.55), bevel=0.04)  # pocket zip
    m.blob("gold", (0.3, 0.2, 0.35), (0, -0.95, 2.28))  # buckle
    m.tube("brown", [(-0.7, 0.2, 3.25), (-0.4, 0.15, 3.8), (0.4, 0.15, 3.8), (0.7, 0.2, 3.25)], 0.14)  # handle
    for s in (-1, 1):
        m.box("brown", (0.35, 0.2, 2.6), (s * 0.85, 0.75, 1.7), bevel=0.06)  # straps on the back
    return m


def museum():
    m = Meme("Museum")
    for i, (w, d) in enumerate([(4.0, 2.2), (3.6, 1.9), (3.2, 1.6)]):
        m.box("lightgray" if i % 2 else "white", (w, d, 0.28), (0, 0, 0.14 + i * 0.28), bevel=0.05)
    for x in (-1.1, -0.37, 0.37, 1.1):
        m.cyl("white", 0.22, 1.8, (x, -0.2, 1.74), seg=12)
        m.box("lightgray", (0.55, 0.55, 0.16), (x, -0.2, 2.7), bevel=0.04)
    m.box("white", (3.5, 1.7, 0.4), (0, 0, 2.95), bevel=0.06)
    prism(m, "white", [(-1.95, 0), (1.95, 0), (0, 1.0)], 1.6, loc=(0, 0, 3.15), bevel=0.05)
    m.cyl("gold", 0.28, 0.1, (0, -0.84, 3.5), rot=(90, 0, 0), seg=16)
    return m


def rebirth():
    m = Meme("Rebirth")
    m.tube("arrowblue", arc(0, 1.9, 1.45, 170, 25), 0.32)
    cone_along(m, "arrowblue", (1.45 * math.cos(R(25)), 0, 1.9 + 1.45 * math.sin(R(25))), (math.sin(R(25)), -math.cos(R(25))), 0.9, 0.62)
    m.tube("yellow", arc(0, 1.9, 1.45, 350, 205), 0.32)
    cone_along(m, "yellow", (1.45 * math.cos(R(205)), 0, 1.9 + 1.45 * math.sin(R(205))), (math.sin(R(205)), -math.cos(R(205))), 0.9, 0.62)
    return m


def world():
    m = Meme("World")
    m.blob("sky", (3.2, 3.2, 3.2), (0, 0, 1.9), seg=32)
    for loc, size in [((-0.6, -1.25, 2.5), (1.3, 0.7, 0.9)), ((0.7, -1.3, 1.5), (1.0, 0.6, 1.2)), ((-0.3, -1.4, 1.2), (0.6, 0.5, 0.5)),
                      ((0.9, -0.9, 2.7), (0.7, 0.6, 0.5)), ((-1.3, -0.6, 1.6), (0.5, 0.6, 0.8))]:
        m.blob("green", size, loc)
    m.blob("white", (0.5, 0.2, 0.3), (-0.8, -1.35, 2.95))
    m.torus("gold", 2.05, 0.1, (0, 0, 1.9), rot=(70, 0, -20))
    return m


def settings():
    m = Meme("Settings")
    pts = []
    for i in range(10 * 4):
        a = 2 * math.pi * i / 40
        r = 1.85 if (i % 4) in (1, 2) else 1.4
        pts.append((r * math.cos(a), r * math.sin(a)))
    prism(m, "gray", pts, 0.8, loc=(0, 0, 1.9), bevel=0.05)
    m.cyl("darkgray", 0.65, 0.9, (0, 0, 1.9), rot=(90, 0, 0), seg=24)
    m.cyl("lightgray", 0.38, 0.95, (0, 0, 1.9), rot=(90, 0, 0), seg=20)
    return m


def gem():
    m = Meme("Gem")
    m.cyl("gemlight", 1.75, 0.7, (0, 0, 2.6), seg=8, radius2=1.05)  # crown
    m.cyl("gem", 1.75, 2.0, (0, 0, 1.25), rot=(180, 0, 0), seg=8, radius2=0.0)  # pavilion
    m.cyl("gemdark", 1.78, 0.12, (0, 0, 2.25), seg=8)  # girdle
    m.blob("white", (0.35, 0.15, 0.2), (-0.55, -0.9, 2.75))
    for part in m.parts:
        for p in part.data.polygons:
            p.use_smooth = False
    return m


def cash():
    m = Meme("Cash")
    for i, (x, rz) in enumerate([(-0.15, -6), (0.1, 4), (0, -2)]):
        m.box("cash", (3.2, 1.8, 0.3), (x, 0, 0.3 + i * 0.32), rot=(0, 0, rz), bevel=0.06)
        m.box("cashdark", (2.6, 1.3, 0.04), (x, 0, 0.46 + i * 0.32), rot=(0, 0, rz), bevel=0.0)
    m.cyl("cash", 0.42, 0.06, (0, 0, 1.13), seg=20)
    m.box("goldlight", (0.6, 1.9, 1.15), (0, 0, 0.75), bevel=0.05)  # paper band
    return m


def income():
    m = Meme("Income")
    pts = [(-0.3, 4.0), (1.3, 4.0), (0.45, 2.4), (1.5, 2.4), (-0.9, -0.2), (-0.1, 1.7), (-1.2, 1.7)]
    prism(m, "yellow", [(x * 1.1, z) for x, z in pts], 0.7, bevel=0.06)
    return m


def speaker(m):
    m.box("darkgray", (0.9, 1.1, 1.3), (-1.2, 0, 1.9), bevel=0.12)
    m.cyl("gray", 0.6, 1.3, (-0.45, 0, 1.9), rot=(0, 90, 0), seg=20, radius2=1.35)


def sound_on():
    m = Meme("SoundOn")
    speaker(m)
    for r in (0.7, 1.25):
        m.tube("white", arc(0.25, 1.9, r, -45, 45), 0.13)
    return m


def sound_off():
    m = Meme("SoundOff")
    speaker(m)
    for a in (45, -45):
        m.box("red", (1.4, 0.3, 0.32), (0.95, 0, 1.9), rot=(0, a, 0), bevel=0.1)
    return m


def music():
    m = Meme("Music")
    for x, z in ((-0.9, 0.7), (0.9, 1.1)):
        m.blob("ink", (1.1, 0.7, 0.8), (x, 0, z), rot=(0, -20, 0))
        m.box("ink", (0.2, 0.3, 2.6), (x + 0.45, 0, z + 1.3), bevel=0.05)
    m.box("ink", (2.0, 0.3, 0.45), (0.45, 0, 3.6), rot=(0, -11, 0), bevel=0.08)
    return m


def bell():
    m = Meme("Bell")
    m.cyl("gold", 1.5, 2.2, (0, 0, 1.6), seg=24, radius2=0.7)
    m.blob("gold", (1.45, 1.45, 1.0), (0, 0, 2.7))
    m.torus("golddark", 1.45, 0.14, (0, 0, 0.55))
    m.blob("golddark", (0.6, 0.6, 0.5), (0, 0, 0.3))
    m.torus("golddark", 0.25, 0.08, (0, 0, 3.3), rot=(90, 0, 0))
    m.blob("white", (0.25, 0.15, 0.5), (-0.5, -1.0, 2.1))
    return m


def lock():
    m = Meme("Lock")
    m.torus("lightgray", 0.85, 0.24, (0, 0, 2.3), rot=(90, 0, 0))
    m.box("gold", (2.6, 1.2, 2.1), (0, 0, 1.05), bevel=0.25)
    m.cyl("ink", 0.25, 0.2, (0, -0.6, 1.3), rot=(90, 0, 0), seg=16)
    m.box("ink", (0.18, 0.2, 0.6), (0, -0.6, 0.95), bevel=0.04)
    m.box("goldlight", (0.25, 0.1, 1.4), (-0.95, -0.6, 1.05), bevel=0.05)
    return m


def luck():
    m = Meme("Luck")
    for k in range(4):
        a = R(45 + k * 90)
        cx, cz = math.cos(a) * 0.85, 2.3 + math.sin(a) * 0.85
        for s in (-1, 1):
            b = a + s * R(35)
            m.blob("green", (1.0, 0.45, 1.0), (cx + math.cos(b) * 0.3, 0, cz + math.sin(b) * 0.3))
        m.tube("darkgreen", [(0, -0.2, 2.3), (cx * 0.8, -0.22, cz * 0.8 + 2.3 * 0.2)], 0.05)
    m.tube("darkgreen", [(0, 0, 2.3), (0.2, 0, 1.3), (0.6, 0, 0.4)], 0.13)
    return m


def pickaxe():
    m = Meme("Pickaxe")
    m.tube("wood", [(-1.3, 0, 0.2), (1.2, 0, 3.2)], 0.2)
    m.tube("gray", arc(1.1, 1.6, 1.9, 140, 40, steps=14), lambda t: 0.16 + 0.22 * math.sin(math.pi * t))
    m.box("darkgray", (0.7, 0.6, 0.7), (1.1, 0, 3.05), rot=(0, 40, 0), bevel=0.1)
    m.box("darkbrown", (0.5, 0.5, 0.3), (-1.25, 0, 0.25), rot=(0, 40, 0), bevel=0.1)
    return m


def star():
    m = Meme("Star")
    prism(m, "yellow", star_pts(5, 2.0, 0.9), 0.8, loc=(0, 0, 2.0), bevel=0.12)
    m.blob("white", (0.4, 0.1, 0.25), (-0.4, -0.45, 2.6))
    return m


def sparkle():
    m = Meme("Sparkle")
    prism(m, "goldlight", star_pts(4, 1.9, 0.45), 0.5, loc=(-0.3, 0, 1.8), bevel=0.08)
    prism(m, "white", star_pts(4, 0.8, 0.2), 0.4, loc=(1.3, -0.1, 3.2), bevel=0.04)
    return m


def heart():
    m = Meme("Heart")
    prism(m, "red", heart_pts(3.8), 1.0, loc=(0, 0, 2.2), bevel=0.15)
    m.blob("white", (0.5, 0.15, 0.3), (-0.8, -0.55, 2.9), rot=(0, 30, 0))
    return m


def pin():
    m = Meme("Pin")
    m.blob("red", (2.2, 2.2, 2.2), (0, 0, 2.6))
    m.cyl("red", 0.75, 1.9, (0, 0, 1.1), rot=(180, 0, 0), seg=20, radius2=0.0)
    m.blob("white", (0.8, 0.4, 0.8), (0, -0.85, 2.65))
    return m


def alien():
    m = Meme("Alien")
    m.blob("alien", (2.6, 2.2, 3.3), (0, 0, 2.0))
    for s in (-1, 1):
        m.blob("black", (0.95, 0.3, 0.55), (s * 0.55, -0.95, 2.1), rot=(0, s * -30, 0))
        m.blob("white", (0.2, 0.1, 0.15), (s * 0.55 - 0.1, -1.1, 2.25))
    m.tube("darkgreen", [(-0.25, -1.05, 1.0), (0, -1.08, 0.95), (0.25, -1.05, 1.0)], 0.05)
    return m


def fire():
    m = Meme("Fire")
    for color, scale, y in (("flame", 1.0, 0.0), ("orange", 0.72, -0.25), ("yellow", 0.45, -0.45)):
        m.blob(color, (2.4 * scale, 1.4 * scale, 2.4 * scale), (0, y, 1.3 * scale + 0.1))
        m.cyl(color, 1.17 * scale, 2.6 * scale, (0, y, 1.3 * scale + 1.4 * scale), seg=20, radius2=0.0, scale=(1, 0.58, 1))
    for s in (-1, 1):
        m.cyl("flame", 0.4, 1.2, (s * 0.95, 0.1, 2.2), rot=(0, s * 25, 0), seg=12, radius2=0.0)
    return m


def skull():
    m = Meme("Skull")
    m.blob("white", (3.0, 2.6, 2.6), (0, 0, 2.4))
    m.box("white", (1.8, 1.6, 1.0), (0, -0.2, 1.1), bevel=0.3)
    for s in (-1, 1):
        m.blob("ink", (0.8, 0.4, 0.75), (s * 0.62, -1.15, 2.3))
    prism(m, "ink", [(-0.2, 0), (0.2, 0), (0, 0.35)], 0.3, loc=(0, -1.2, 1.55), bevel=0.0)
    for x in (-0.45, 0, 0.45):
        m.box("ink", (0.08, 0.1, 0.45), (x, -1.0, 0.95), bevel=0.0)
    return m


def disk():
    m = Meme("Disk")
    m.box("navy", (3.0, 0.4, 3.0), (0, 0, 1.6), bevel=0.15)
    m.box("lightgray", (1.6, 0.46, 1.0), (0.2, 0, 2.6), bevel=0.06)
    m.box("navy", (0.4, 0.5, 0.7), (0.5, 0, 2.6), bevel=0.04)
    m.box("white", (2.3, 0.46, 1.2), (0, 0, 0.9), bevel=0.08)
    for z in (1.15, 0.85, 0.55):
        m.box("sky", (1.8, 0.48, 0.06), (0, 0, z), bevel=0.0)
    return m


def volcano():
    m = Meme("Volcano")
    m.cyl("brown", 2.2, 2.6, (0, 0, 1.3), seg=24, radius2=0.8)
    m.cyl("darkbrown", 2.25, 0.4, (0, 0, 0.2), seg=24)
    m.blob("lava", (1.7, 1.7, 0.6), (0, 0, 2.6))
    for x, length in ((-0.5, 1.2), (0.3, 1.6), (0.75, 0.9)):
        m.tube("lava", [(x * 0.7, -0.75, 2.5), (x, -1.1, 2.5 - length * 0.6), (x * 1.3, -1.35, 2.5 - length)], 0.16)
    m.blob("lightgray", (1.0, 0.8, 0.8), (-0.4, 0, 3.3))
    m.blob("lightgray", (1.3, 0.9, 1.0), (0.5, 0.1, 3.8))
    return m


def candy():
    m = Meme("Candy")
    m.cyl("white", 0.12, 2.0, (0, 0.05, 1.0), seg=10)
    m.cyl("candy", 1.4, 0.45, (0, 0, 2.6), rot=(90, 0, 0), seg=32)
    pts = [(0.14 * t * math.cos(t), -0.25, 2.6 + 0.14 * t * math.sin(t)) for t in [i * 0.35 for i in range(28)]]
    m.tube("white", pts, 0.1, seg=8)
    return m


def ghost():
    m = Meme("Ghost")
    m.blob("ghost", (2.6, 2.0, 3.0), (0, 0, 2.3))
    m.cyl("ghost", 1.3, 1.4, (0, 0, 1.2), seg=24, scale=(1, 0.77, 1))
    for x in (-0.85, 0, 0.85):
        m.blob("ghost", (0.9, 1.4, 0.8), (x, 0, 0.5))
    eyes(m, 2.6, 0.48, -0.85, size=(0.35, 0.2, 0.55), pupil=False)
    m.blob("ink", (0.45, 0.2, 0.55), (0, -0.88, 1.9))
    for s in (-1, 1):
        m.tube("ghost", [(s * 1.1, 0, 2.2), (s * 1.6, -0.2, 2.6)], 0.25)
    return m


def bubble():
    m = Meme("Bubble")
    m.blob("bubble", (3.0, 3.0, 3.0), (0, 0, 1.9), seg=32)
    m.blob("white", (0.7, 0.2, 0.45), (-0.65, -1.3, 2.7), rot=(0, 35, 0))
    m.blob("white", (0.25, 0.15, 0.25), (-1.05, -1.0, 2.15))
    m.blob("bubble", (1.0, 1.0, 1.0), (1.5, 0, 3.4))
    return m


def ice():
    m = Meme("Ice")
    m.box("ice", (2.8, 2.6, 2.8), (0, 0, 1.6), rot=(0, 0, 12), bevel=0.35)
    m.box("white", (0.25, 0.1, 1.4), (-0.85, -1.38, 2.0), rot=(0, 0, 12), bevel=0.08)
    m.box("white", (0.25, 0.1, 0.4), (-0.85, -1.38, 0.9), rot=(0, 0, 12), bevel=0.08)
    return m


def snowflake():
    m = Meme("Snowflake")
    for k in range(6):
        a = R(k * 60)
        dx, dz = math.cos(a), math.sin(a)
        m.tube("ice", [(0, 0, 2), (dx * 1.8, 0, 2 + dz * 1.8)], 0.16)
        for s in (-1, 1):
            b = a + s * R(40)
            base = (dx * 1.1, 0, 2 + dz * 1.1)
            m.tube("ice", [base, (base[0] + math.cos(b) * 0.55, 0, base[2] + math.sin(b) * 0.55)], 0.12)
    m.blob("white", (0.6, 0.4, 0.6), (0, 0, 2))
    return m


def coin():
    m = Meme("Coin")
    m.cyl("gold", 1.8, 0.5, (0, 0, 1.9), rot=(90, 0, 0), seg=32)
    m.cyl("goldlight", 1.45, 0.56, (0, 0, 1.9), rot=(90, 0, 0), seg=32)
    prism(m, "golddark", star_pts(5, 0.9, 0.4), 0.62, loc=(0, 0, 1.9), bevel=0.02)
    return m


def warning():
    m = Meme("Warning")
    prism(m, "yellow", [(-2.0, 0.2), (2.0, 0.2), (0, 3.7)], 0.7, bevel=0.2)
    m.box("ink", (0.38, 0.8, 1.4), (0, 0, 2.2), bevel=0.15)
    m.blob("ink", (0.45, 0.8, 0.45), (0, 0, 1.05))
    return m


def boom():
    m = Meme("Boom")
    prism(m, "flame", star_pts(10, 2.1, 1.25, turn=80), 0.5, loc=(0, 0, 2.0), bevel=0.05)
    prism(m, "yellow", star_pts(8, 1.3, 0.8, turn=70), 0.6, loc=(0, -0.05, 2.0), bevel=0.05)
    m.blob("white", (0.8, 0.5, 0.8), (0, -0.1, 2.0))
    return m


def party():
    m = Meme("Party")
    m.cyl("candy", 1.0, 2.6, (-0.4, 0, 1.4), rot=(0, 38, 0), seg=20, radius2=0.12)
    for t, color in ((0.3, "yellow"), (0.6, "sky")):
        m.torus(color, 1.0 - 0.88 * t, 0.07, (-0.4 + math.sin(R(38)) * (-1.3 + 2.6 * t), 0, 1.4 + math.cos(R(38)) * (-1.3 + 2.6 * t) * -1),
                rot=(0, 38, 0))
    for loc, color, rot in (((0.8, -0.2, 3.3), "yellow", 20), ((1.5, -0.1, 2.6), "sky", -30), ((0.5, -0.1, 3.9), "green", 60),
                            ((1.3, -0.2, 3.6), "candy", 0), ((1.9, -0.1, 3.4), "orange", 45)):
        m.box(color, (0.35, 0.12, 0.22), loc, rot=(0, rot, 0), bevel=0.03)
    m.tube("yellow", [(0.5, 0, 2.4), (1.0, -0.1, 2.9), (1.4, 0, 3.0), (1.7, -0.1, 3.5)], 0.07)
    return m


def picture():
    m = Meme("Picture")
    m.box("sky", (3.2, 0.2, 2.6), (0, 0.05, 1.8), bevel=0.0)
    prism(m, "green", [(-1.5, 0.6), (-0.4, 2.3), (0.5, 0.6)], 0.24, bevel=0.0)
    prism(m, "darkgreen", [(-0.3, 0.6), (0.7, 1.9), (1.5, 0.6)], 0.26, bevel=0.0)
    m.blob("yellow", (0.6, 0.3, 0.6), (0.9, -0.05, 2.6))
    for loc, size in (((0, 0, 3.2), (3.8, 0.45, 0.35)), ((0, 0, 0.4), (3.8, 0.45, 0.35)),
                      ((-1.75, 0, 1.8), (0.35, 0.45, 3.1)), ((1.75, 0, 1.8), (0.35, 0.45, 3.1))):
        m.box("gold", size, loc, bevel=0.08)
    return m


def hole():
    m = Meme("Hole")
    m.cyl("brown", 2.0, 0.5, (0, 0, 1.5), rot=(-60, 0, 0), seg=28, scale=(1, 1, 1))
    m.cyl("black", 1.5, 0.55, (0, -0.05, 1.5), rot=(-60, 0, 0), seg=28)
    for loc in ((-1.6, -0.3, 0.6), (1.5, -0.2, 0.7), (0.4, -0.9, 0.3), (-0.7, -0.8, 0.4)):
        m.blob("darkbrown", (0.55, 0.5, 0.4), loc)
    return m


def elevator():
    m = Meme("Elevator")
    m.box("gray", (3.0, 0.8, 3.6), (0, 0, 1.8), bevel=0.2)
    for s in (-1, 1):
        m.box("lightgray", (1.1, 0.9, 2.8), (s * 0.6, 0, 1.75), bevel=0.06)
    prism(m, "green", [(-0.4, 0), (0.4, 0), (0, 0.5)], 0.3, loc=(0, -0.5, 3.35), bevel=0.0)
    prism(m, "red", [(-0.4, 0.5), (0.4, 0.5), (0, 0)], 0.3, loc=(0, -0.5, 0.0), bevel=0.0)
    return m


def crown():
    m = Meme("Crown")
    m.cyl("gold", 1.7, 1.0, (0, 0, 0.9), seg=28)
    for k in range(5):
        a = R(-90 + (k - 2) * 36)
        x, y = math.cos(a) * 1.55, math.sin(a) * 1.55
        m.cyl("gold", 0.45, 1.5, (x, y, 2.1), seg=12, radius2=0.05)
        m.blob("goldlight", (0.4, 0.4, 0.4), (x, y, 2.85))
    for k, color in enumerate(("red", "sky", "red")):
        a = R(-90 + (k - 1) * 40)
        m.blob(color, (0.45, 0.3, 0.45), (math.cos(a) * 1.72, math.sin(a) * 1.72, 0.9))
    return m


def face(name, build):
    def make():
        m = Meme(name)
        m.blob("faceyellow" if name != "FaceSick" else "alien", (3.4, 3.0, 3.4), (0, 0, 1.9), seg=32)
        build(m)
        return m
    return make


def smile(m, wide=1.0, z=1.25):
    m.tube("ink", arc(0, z + 0.55, 0.75 * wide, 215, 325, y=-1.35), 0.09)


FACES = [
    face("FaceHappy", lambda m: (eyes(m, 2.35, 0.55, -1.3, size=(0.3, 0.2, 0.45), pupil=False), smile(m))),
    face("FaceLaugh", lambda m: ([m.tube("ink", arc(s * 0.6, 2.25, 0.3, 20, 160, y=-1.36), 0.08) for s in (-1, 1)],
                                 m.blob("darkred", (1.3, 0.4, 0.8), (0, -1.25, 1.35)),
                                 [m.blob("sky", (0.3, 0.2, 0.5), (s * 1.1, -1.1, 1.9)) for s in (-1, 1)])),
    face("FaceLove", lambda m: ([prism(m, "red", heart_pts(0.9), 0.3, loc=(s * 0.6, -1.35, 2.35), bevel=0.04) for s in (-1, 1)],
                                smile(m, 1.1))),
    face("FaceWow", lambda m: (eyes(m, 2.35, 0.6, -1.25), m.blob("ink", (0.6, 0.4, 0.75), (0, -1.38, 1.25)))),
    face("FaceCool", lambda m: ([m.box("ink", (1.05, 0.3, 0.6), (s * 0.58, -1.42, 2.3), bevel=0.12) for s in (-1, 1)],
                                m.box("ink", (2.6, 0.2, 0.14), (0, -1.38, 2.5), bevel=0.04),
                                m.tube("ink", arc(0.25, 1.75, 0.55, 230, 320, y=-1.35), 0.08))),
    face("FaceMeh", lambda m: (eyes(m, 2.3, 0.55, -1.3, size=(0.3, 0.2, 0.32), pupil=False),
                               m.box("ink", (1.0, 0.2, 0.16), (0, -1.38, 1.3), bevel=0.05))),
    face("FaceSick", lambda m: ([m.box("ink", (0.55, 0.2, 0.12), (s * 0.58, -1.36, 2.3), rot=(0, a, 0), bevel=0.03)
                                 for s in (-1, 1) for a in (40, -40)],
                                m.tube("darkgreen", [(-0.6, -1.4, 1.3), (-0.3, -1.42, 1.45), (0, -1.42, 1.3), (0.3, -1.42, 1.45), (0.6, -1.4, 1.3)], 0.08))),
]

ALL = [shop, bag, museum, rebirth, world, settings, gem, cash, income, sound_on, sound_off, music, bell, lock, luck,
       pickaxe, star, sparkle, heart, pin, alien, fire, skull, disk, volcano, candy, ghost, bubble, ice, snowflake, coin,
       warning, boom, party, picture, hole, elevator, crown] + FACES


# ------------------------------------------------------------------------------------------
# outline, render, export
# ------------------------------------------------------------------------------------------
def add_outline(obj, thickness=OUTLINE):
    """An inverted hull: a slightly puffed-up copy with its faces turned inside out, colored
    dark. Only its far side shows (around the edges), which reads as a thick outline."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.normal_update()
    old_faces = set(bm.faces)
    old_verts = set(bm.verts)
    normals = {v: v.normal.copy() for v in bm.verts}
    dup = bmesh.ops.duplicate(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:])
    for a, b in dup["vert_map"].items():
        old, new = (a, b) if a in old_verts else (b, a)
        if old in old_verts and new not in old_verts:
            new.co = old.co + normals[old] * thickness
    new_faces = [f for f in bm.faces if f not in old_faces]
    bmesh.ops.reverse_faces(bm, faces=new_faces)
    uv_layer = bm.loops.layers.uv.active
    uv = cell_uv("outline")
    for f in new_faces:
        f.smooth = True
        for loop in f.loops:
            loop[uv_layer].uv = uv
    bm.to_mesh(obj.data)
    bm.free()


def flat_material(name, color=None):
    """Pass materials for the preview: the palette colors, solid black, or nothing at all."""
    if color == "palette":
        mat = memekit.palette_material().copy()
        mat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.45
        return mat
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    out = nt.nodes["Material Output"]
    if color is None:
        shader = nt.nodes.new("ShaderNodeBsdfTransparent")
    else:
        shader = nt.nodes.new("ShaderNodeEmission")
        shader.inputs["Color"].default_value = (*color, 1)
    nt.links.new(shader.outputs[0], out.inputs["Surface"])
    return mat


def render_icon(obj, path, size=256):
    scene = bpy.context.scene
    for o in list(scene.objects):
        if o.type == "MESH" and o != obj:
            o.hide_render = True
    obj.hide_render = False
    # split a copy into the icon itself and its outline shell (every face painted the
    # outline color), each its own object for the two render passes
    ou = cell_uv("outline")

    def part(keep_shell):
        me = obj.data.copy()
        bm = bmesh.new()
        bm.from_mesh(me)
        uv_layer = bm.loops.layers.uv.active
        doomed = []
        for f in bm.faces:
            u = f.loops[0][uv_layer].uv
            is_shell = abs(u[0] - ou[0]) < 1e-4 and abs(u[1] - ou[1]) < 1e-4
            if is_shell != keep_shell:
                doomed.append(f)
        bmesh.ops.delete(bm, geom=doomed, context="FACES")
        bm.to_mesh(me)
        bm.free()
        o = bpy.data.objects.new(obj.name + ("Shell" if keep_shell else "Body"), me)
        o.matrix_world = obj.matrix_world
        scene.collection.objects.link(o)
        return o

    body, shell = part(False), part(True)
    obj.hide_render = True
    xs = [v.co.x for v in obj.data.vertices]
    ys = [v.co.y for v in obj.data.vertices]
    zs = [v.co.z for v in obj.data.vertices]
    centre = obj.matrix_world @ Vector(((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2, (min(zs) + max(zs)) / 2))
    extent = max(max(xs) - min(xs), max(zs) - min(zs))
    cam = bpy.data.objects.get("IconCam")
    if not cam:
        cam = bpy.data.objects.new("IconCam", bpy.data.cameras.new("IconCam"))
        scene.collection.objects.link(cam)
        for i, (rot, energy) in enumerate([((40, 0, -25), 4.0), ((65, 0, 140), 1.5)]):
            sun = bpy.data.objects.new("IconSun%d" % i, bpy.data.lights.new("IconSun%d" % i, "SUN"))
            sun.data.energy = energy
            sun.rotation_euler = [math.radians(a) for a in rot]
            scene.collection.objects.link(sun)
        w = bpy.data.worlds.new("IconWorld")
        w.use_nodes = True
        w.node_tree.nodes["Background"].inputs["Color"].default_value = (0.9, 0.92, 1.0, 1)
        w.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.9
        scene.world = w
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = extent * 1.15
    turn, tilt = math.radians(-14), math.radians(10)
    d = 20
    cam.location = centre + Vector((math.sin(turn) * d, -math.cos(turn) * d * math.cos(tilt), math.sin(tilt) * d))
    cam.rotation_euler = (centre - cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 32
    scene.cycles.use_denoising = False
    scene.render.film_transparent = True
    scene.render.resolution_x = scene.render.resolution_y = size
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"
    # two passes (Blender's renderer doesn't hide back faces the way Roblox does): the icon
    # itself, then the puffed-up outline shell in solid dark, laid under it
    outline = [c / 255 for c in memekit.PALETTE["outline"]]
    lin = [((c + 0.055) / 1.055) ** 2.4 if c > 0.04045 else c / 12.92 for c in outline]
    passes = []
    for show, material in ((body, flat_material("PassBody", "palette")), (shell, flat_material("PassShell", lin))):
        body.hide_render = show is not body
        shell.hide_render = show is not shell
        show.data.materials.clear()
        show.data.materials.append(material)
        scene.render.filepath = path
        bpy.ops.render.render(write_still=True)
        img = bpy.data.images.load(path)
        passes.append(list(img.pixels))
        bpy.data.images.remove(img)
    top, under = passes
    px = [0.0] * len(top)
    for k in range(0, len(top), 4):
        ta, ua = top[k + 3], under[k + 3]
        a = ta + ua * (1 - ta)
        px[k + 3] = a
        for c in range(3):
            px[k + c] = (top[k + c] * ta + under[k + c] * ua * (1 - ta)) / a if a > 0 else 0
    out = bpy.data.images.new("icon_out", size, size, alpha=True)
    out.pixels = px
    out.filepath_raw = path
    out.file_format = "PNG"
    out.save()
    bpy.data.images.remove(out)
    for o in (body, shell):
        bpy.data.objects.remove(o, do_unlink=True)
    obj.hide_render = False


def sheet(names, path, cell=128, cols=8):
    rows = (len(names) + cols - 1) // cols
    w, h = cols * cell, rows * cell
    px = [0.0] * (w * h * 4)
    for i, name in enumerate(names):
        img = bpy.data.images.load(os.path.join(PNG_DIR, name + ".png"))
        img.scale(cell, cell)
        src = list(img.pixels)
        cx, cy = i % cols, rows - 1 - i // cols
        for y in range(cell):
            row = src[y * cell * 4:(y + 1) * cell * 4]
            o = ((cy * cell + y) * w + cx * cell) * 4
            px[o:o + cell * 4] = row
        bpy.data.images.remove(img)
    out = bpy.data.images.new("sheet", w, h, alpha=True)
    out.pixels = px
    out.filepath_raw = path
    out.file_format = "PNG"
    out.save()


def build(make):
    obj = make().finish(max_tris=5000)
    add_outline(obj)
    return obj


def main():
    only = sys.argv[1:]
    os.makedirs(PNG_DIR, exist_ok=True)
    names = []
    for make in ALL:
        memekit.reset()
        obj = build(make)
        names.append(obj.name)
        if only and obj.name not in only:
            continue
        render_icon(obj, os.path.join(PNG_DIR, obj.name + ".png"))
        print("icon", obj.name, len(obj.data.polygons), "tris")
    sheet(names, os.path.join(PNG_DIR, "_sheet.png"))
    # one file with every icon, for a single Import 3D in Studio
    memekit.reset()
    objs = []
    for i, make in enumerate(ALL):
        obj = build(make)
        obj.location.x = i * 6
        objs.append(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.export_scene.fbx(filepath=os.path.join(memekit.OUT, "UIIcons.fbx"), use_selection=True, apply_unit_scale=True,
                             apply_scale_options="FBX_SCALE_ALL", axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE",
                             path_mode="COPY", embed_textures=True, bake_space_transform=True)
    with open(LUA_OUT, "w", encoding="utf-8") as f:
        f.write("-- UIIconList (ModuleScript in ReplicatedStorage)\n")
        f.write("-- Written by tools/blender/ui_icons.py: the names of the 3D UI icons in assets/models/UIIcons.fbx.\n")
        f.write("-- Import that file once (File > Import 3D) and run the installer; UIKit.icon shows them.\n\n")
        f.write("return {\n" + "".join('\t"%s",\n' % n for n in names) + "}\n")
    print("wrote UIIcons.fbx with", len(objs), "icons")


main()
