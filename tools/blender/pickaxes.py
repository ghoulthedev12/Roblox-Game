"""Builds a unique pickaxe for every world 2-9 shop slot (56 of them) as real Blender meshes,
each designed around its name: a koi-fish head, a paper lantern, a rocket, a ringed planet,
an anchor, a trident, kraken tentacles, candy canes, an anvil, a dragon fang, pixel art...
(World 1's nine pickaxes stay the part-built ones in PickaxeModels.)

Each pickaxe is two meshes:
  <Id>      the pickaxe, colored from the shared palette texture (memekit)
  <Id>Glow  its glowing bits (one color, drawn as Neon in the game), when it has any
Writes assets/models/PickaxeMeshes.fbx (one Import 3D in Studio; the installer moves the
meshes to ReplicatedStorage > PickaxeMeshes), preview sheets in assets/models/previews and
src/shared/PickaxeMeshData.lua (each mesh's size, where it sits in tool space, the glow
color and the tip points the spark trails come off).

Tool space (Roblox, what PickaxeModels uses): the handle runs along Z, the head is at
z = -2.6 and the grip end at z = +2.2, the arms point along +/-Y. Here it's built in Blender
space, where that is: head at y = +2.6, grip end at y = -2.2, arms along +/-z, thickness
along x (the exporter turns Blender (x, y, z) into Roblox (x, z, -y)).
The hands hold the handle between y = -0.4 and -1.7: keep that stretch a plain grip.

Run:  python tools/blender/pickaxes.py [ids...]   (bpy package), or inside Blender.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402
import bmesh  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

import memekit  # noqa: E402
from memekit import Meme, rgb  # noqa: E402

LUA_OUT = os.path.join(memekit.ROOT, "src", "shared", "PickaxeMeshData.lua")
PREVIEW = os.path.join(memekit.OUT, "previews")
R = math.radians
H = Vector((0, 2.6, 0))  # the head's socket, where the arms meet the handle

# new palette colors (always appended after the existing ones)
for _name, _c in [
    ("sakura", (255, 168, 204)), ("plum", (120, 50, 80)), ("petal", (255, 222, 236)), ("bamboo", (130, 190, 80)),
    ("bamboodark", (80, 130, 50)), ("koi", (255, 120, 50)), ("lantern", (220, 50, 50)), ("silk", (30, 30, 40)),
    ("blade", (225, 232, 240)), ("meteor", (90, 80, 90)), ("rocket", (240, 240, 245)), ("planet", (120, 150, 255)),
    ("planetring", (255, 210, 140)), ("nebula", (150, 80, 220)), ("comet", (120, 210, 255)), ("void", (20, 16, 34)),
    ("snow", (250, 252, 255)), ("icicle", (170, 225, 255)), ("frost", (80, 160, 230)), ("aurora", (90, 230, 170)),
    ("sandstone", (220, 180, 120)), ("cactus", (70, 160, 80)), ("chrome", (200, 210, 225)), ("lapis", (40, 80, 190)),
    ("solar", (30, 50, 110)), ("shell", (255, 214, 190)), ("iron", (70, 76, 90)), ("pearl", (245, 240, 250)),
    ("kraken", (150, 70, 160)), ("wave", (40, 130, 210)), ("coral", (255, 110, 120)), ("lolly", (255, 100, 170)),
    ("canered", (230, 40, 60)), ("gummy", (255, 70, 90)), ("gummygreen", (90, 220, 100)), ("frosting", (255, 150, 200)),
    ("jaw1", (255, 90, 90)), ("jaw2", (255, 220, 70)), ("jaw3", (90, 180, 255)), ("ember", (60, 50, 50)),
    ("anvil", (60, 64, 74)), ("magma", (110, 50, 40)), ("obsidian", (30, 24, 44)), ("dragonbone", (240, 230, 200)),
    ("placeholder", (160, 160, 160)), ("missing", (255, 0, 220)), ("pixel1", (90, 200, 255)), ("pixel2", (40, 110, 200)),
    ("wire", (60, 255, 140)), ("error", (230, 50, 60)), ("terminal", (20, 30, 24)), ("patch", (245, 200, 150)),
]:
    rgb(_name, *_c)


# ------------------------------------------------------------------------------------------
# kit
# ------------------------------------------------------------------------------------------
class Pick:
    def __init__(self, pid, glow_color):
        self.id = pid
        self.body = Meme(pid)
        self.glow = Meme(pid + "Glow")
        self.glow_color = glow_color
        self.tips = []


def faceted(m, color, size, loc, rot=(0, 0, 0), seg=6, rings=4):
    """A low-poly, flat-shaded gem/rock."""
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=rings, radius=0.5)
    o = bpy.context.object
    m._place(o, loc, rot, size)
    return m._add(o, color, smooth=False)


def rod(m, color, a, b, r, r2=None, seg=12):
    """A cylinder (or cone, with r2) from point a to point b."""
    a, b = Vector(a), Vector(b)
    radius = (lambda t: r + (r2 - r) * t) if r2 is not None else r
    return m.tube(color, [a + (b - a) * k / 3 for k in range(4)], radius, seg=seg)


def arc(side, R_, phi0, phi1, n=12, center=None, flare=0.0):
    """Points along a pick arm's curve: it leaves the socket and bends back toward the grip.
    side = +1 (arm points up) / -1 (down)."""
    c = (center or H) - Vector((0, R_, 0))
    pts = []
    for i in range(n + 1):
        phi = phi0 + (phi1 - phi0) * i / n
        pts.append(c + Vector((0, math.cos(phi), side * math.sin(phi))) * (R_ + flare * i / n))
    return pts


def arm(p, color, side, R_=2.3, reach=1.15, r0=0.3, r1=0.04, flat=0.62, center=None, m=None, tip=True):
    """A tapered, slightly flattened curved pick arm. Returns the tip point."""
    m = m or p.body
    pts = arc(side, R_, 0.05, reach, 14, center)
    o = m.tube(color, pts, lambda t: r0 + (r1 - r0) * t ** 0.8, seg=12)
    for v in o.data.vertices:
        v.co.x *= flat
    if tip:
        p.tips.append(pts[-1])
    return pts[-1]


def shape(m, color, pts, thick, x=0.0, bevel=0.04, smooth=False):
    """A flat shape drawn in the y-z plane (as (y, z) points), extruded along x."""
    bm = bmesh.new()
    front = [bm.verts.new((x - thick / 2, y, z)) for y, z in pts]
    back = [bm.verts.new((x + thick / 2, y, z)) for y, z in pts]
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
    me = bpy.data.meshes.new("shape")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("shape", me)
    bpy.context.scene.collection.objects.link(o)
    return m._add(o, color, smooth=smooth)


def ring_on(m, color, center, direction, major, minor):
    """A torus around a rod: centered at `center`, its hole facing along `direction`."""
    rot = Vector(direction).normalized().to_track_quat("Z", "Y").to_euler()
    return m.torus(color, major, minor, loc=tuple(center), rot=tuple(math.degrees(a) for a in rot))


def arm_ring(m, color, side, R_, reach, k, n, major, minor):
    """A ring around a pick arm made with arc(side, R_, 0.05, reach, n), at point k."""
    pts = arc(side, R_, 0.05, reach, n)
    d = pts[min(k + 1, n)] - pts[max(k - 1, 0)]
    return ring_on(m, color, pts[k], d, major, minor)


def star_pts(cy, cz, points, outer, inner, turn=0.0):
    pts = []
    for i in range(points * 2):
        a = turn + math.pi * i / points
        r = outer if i % 2 == 0 else inner
        pts.append((cy + math.cos(a) * r, cz + math.sin(a) * r))
    return pts


def circle_pts(cy, cz, r, n=24, sy=1.0, sz=1.0):
    return [(cy + math.cos(2 * math.pi * i / n) * r * sy, cz + math.sin(2 * math.pi * i / n) * r * sz) for i in range(n)]


def at(y, z=0.0, x=0.0):
    return Vector((x, y, z))


# --- handles (y from -2.2 at the grip end up to the head) ---------------------------------
GRIP = (-1.75, -0.35)


def handle(p, color, wrap, pommel=None, style="plain", accent=None):
    m = p.body
    top = H.y - 0.1
    if style == "bamboo":
        y = -2.25
        while y < top:
            seg = min(0.75, top - y)
            rod(m, color, at(y), at(y + seg), 0.15)
            m.torus(accent or "bamboodark", 0.15, 0.04, loc=(0, y + seg, 0), rot=(90, 0, 0))
            y += seg
    elif style == "candy":
        rod(m, color, at(-2.25), at(top), 0.15)
        pts = [at(-2.25 + (top + 2.25) * k / 90, 0.15 * math.sin(k * 0.62), 0.15 * math.cos(k * 0.62)) for k in range(91)]
        m.tube(accent or "white", pts, 0.05, seg=6)
    elif style == "branch":
        pts = [at(-2.25 + 4.8 * k / 12, 0.05 * math.sin(k * 1.3), 0.05 * math.cos(k * 0.9)) for k in range(13)]
        m.tube(color, pts, lambda t: 0.17 - 0.03 * t, seg=10)
    elif style == "pixel":
        y = -2.25
        while y < top:
            m.box(color, (0.3, 0.3, 0.3), loc=(0, y + 0.15, 0), bevel=0.01)
            y += 0.3
    elif style == "square":
        m.box(color, (0.28, top + 2.25, 0.28), loc=(0, (top - 2.25) / 2, 0), bevel=0.04)
    else:
        rod(m, color, at(-2.25), at(top), 0.14)
    # the grip: a thicker wrapped stretch with a collar at each end (left plain for the hands)
    if style != "pixel":
        rod(m, wrap, at(GRIP[0]), at(GRIP[1]), 0.18, seg=14)
        for y in GRIP:
            m.torus(accent or "gold", 0.18, 0.045, loc=(0, y, 0), rot=(90, 0, 0))
    if pommel:
        pommel(m)
    else:
        m.blob(accent or "gold", (0.36, 0.36, 0.36), loc=(0, -2.32, 0))


def socket(p, color, size=0.62):
    p.body.box(color, (size * 0.8, size, size), loc=tuple(H), bevel=0.08)


# ------------------------------------------------------------------------------------------
# designs: one function per pickaxe
# ------------------------------------------------------------------------------------------
D = {}


def design(pid, glow):
    def wrap(fn):
        D[pid] = (fn, glow)
        return fn
    return wrap


def flower(m, color, center_color, loc, r=0.5, petals=5, axis="x"):
    """A blossom facing +x / -x: round petals around a center."""
    c = Vector(loc)
    for i in range(petals):
        a = 2 * math.pi * i / petals
        off = Vector((0, math.cos(a), math.sin(a))) * r * 0.62
        m.blob(color, (0.16, r * 0.8, r * 0.62), loc=tuple(c + off), rot=(math.degrees(a), 0, 0))
    m.blob(center_color, (0.22, r * 0.42, r * 0.42), loc=tuple(c + Vector((0, 0, 0))))


# ---- World 2: Neon Sakura Grove --------------------------------------------------------
@design("BlossomTrowel", (255, 120, 180))
def _(p):
    handle(p, "wood", "sakura")
    socket(p, "plum")
    arm(p, "sakura", 1, r0=0.28)
    arm(p, "sakura", -1, r0=0.28)
    for x in (-0.22, 0.22):
        flower(p.body, "petal", "yellow", (x, H.y, 0), r=0.5)


@design("BambooSpade", (190, 255, 120))
def _(p):
    handle(p, "bamboo", "bamboodark", style="bamboo", accent="bamboodark")
    for side in (1, -1):
        pts = arc(side, 2.2, 0.05, 1.1, 4)
        for k, (a, b) in enumerate(zip(pts, pts[1:])):
            rod(p.body, "bamboo", a, b, 0.2 - 0.03 * k)
            ring_on(p.body, "bamboodark", b, b - a, 0.2 - 0.03 * k, 0.05)
        p.body.blob("bamboodark", (0.14, 0.2, 0.2), loc=tuple(pts[-1]))
        p.tips.append(pts[-1])
    for i, (dy, dz, rot) in enumerate(((0.3, 0.55, 35), (-0.2, -0.6, -40), (0.5, -0.3, -70))):
        p.body.blob("green", (0.06, 0.65, 0.2), loc=(0.15, H.y + dy, dz), rot=(rot, 0, 0))
    socket(p, "bamboodark", 0.5)


@design("KoiScoop", (255, 170, 90))
def _(p):
    handle(p, "darkbrown", "lantern")
    m = p.body
    # the koi: a fat body across the head, pointed mouth up, a big tail fin down
    m.blob("koi", (0.55, 1.3, 2.6), loc=(0, H.y + 0.1, 0.25))
    m.blob("white", (0.57, 0.9, 0.9), loc=(0, H.y + 0.05, 0.75))
    m.blob("koi", (0.4, 0.5, 0.6), loc=(0, H.y + 0.2, 1.6))
    for x in (-0.26, 0.26):
        m.blob("black", (0.06, 0.13, 0.13), loc=(x, H.y + 0.35, 1.45))
    shape(m, "koi", [(H.y + 0.2, -0.9), (H.y + 0.9, -2.0), (H.y + 0.15, -1.6), (H.y - 0.6, -2.1), (H.y - 0.1, -0.9)], 0.12)
    for side in (1, -1):
        shape(m, "white", [(H.y - 0.1, 0.2), (H.y - 0.75, 0.55 * side + 0.2), (H.y - 0.5, -0.1)], 0.08, x=0.3 * side)
    p.tips += [at(H.y + 0.2, 1.95), at(H.y + 0.1, -2.05)]


@design("LanternSpade", (255, 190, 90))
def _(p):
    handle(p, "darkbrown", "lantern")
    socket(p, "gold")
    arm(p, "lantern", 1, r0=0.3)
    arm(p, "lantern", -1, r0=0.3)
    m = p.body
    # a big paper lantern sitting on top of the head, lit from inside
    L = H + Vector((0, 0.95, 0))
    m.blob("lantern", (0.95, 1.15, 0.95), loc=tuple(L))
    for dy in (-0.55, 0.55):
        m.cyl("gold", 0.3, 0.14, loc=tuple(L + Vector((0, dy, 0))), rot=(90, 0, 0))
    for dy in (-0.28, 0, 0.28):
        ring_on(m, "darkred", L + Vector((0, dy, 0)), Vector((0, 1, 0)), 0.47 - abs(dy) * 0.35, 0.03)
    m.blob("gold", (0.18, 0.18, 0.18), loc=tuple(L + Vector((0, 0.72, 0))))
    p.glow.blob("glow", (0.7, 0.85, 0.7), loc=tuple(L))


@design("KatanaShovel", (210, 235, 255))
def _(p):
    handle(p, "silk", "silk", accent="gold", pommel=lambda m: m.cyl("gold", 0.16, 0.2, loc=(0, -2.3, 0), rot=(90, 0, 0)))
    for y in (-1.6, -1.3, -1.0, -0.7):  # the diamond ito wrap on the grip
        p.body.blob("white", (0.38, 0.14, 0.14), loc=(0, y, 0), rot=(45, 0, 0))
    m = p.body
    m.cyl("gold", 0.5, 0.1, loc=(0, H.y - 0.45, 0), rot=(90, 0, 0), scale=(1, 1, 1))  # tsuba guard
    for side in (1, -1):
        outer = arc(side, 2.7, 0.08, 1.05, 10)
        inner = arc(side, 1.95, 0.14, 0.98, 10)
        pts = [(q.y, q.z) for q in outer] + [(q.y, q.z) for q in reversed(inner)]
        shape(m, "blade", pts, 0.12, bevel=0.03)
        back = arc(side, 2.05, 0.14, 0.98, 10)  # the dark back of the blade (the spine)
        m.tube("steel", back, 0.07, seg=6)
        p.glow.tube("glow", [q + Vector((0, 0.02, 0.02 * side)) for q in outer], 0.025, seg=6)
        p.tips.append(outer[-1])
    socket(p, "silk", 0.5)


@design("PetalExcavator", (255, 110, 190))
def _(p):
    handle(p, "plum", "sakura", accent="gold")
    m = p.body
    # a hammer of stacked blossoms on one side, a long petal blade on the other
    m.cyl("plum", 0.45, 1.2, loc=(0, H.y, 0.75), rot=(0, 0, 0))
    flower(m, "sakura", "gold", (0, H.y, 1.4), r=0.75)
    flower(m, "petal", "gold", (0.32, H.y, 0.75), r=0.6)
    flower(m, "petal", "gold", (-0.32, H.y, 0.75), r=0.6)
    shape(m, "sakura", [(H.y + 0.35, -0.2), (H.y + 0.1, -2.3), (H.y - 0.55, -1.2), (H.y - 0.3, -0.2)], 0.22, bevel=0.06, smooth=True)
    p.glow.blob("glow", (0.5, 0.5, 0.5), loc=(0, H.y, 0.75))
    p.tips += [at(H.y + 0.1, -2.3), at(H.y, 1.8)]
    socket(p, "plum")


@design("HanamiHarvester", (255, 140, 210))
def _(p):
    handle(p, "plum", "petal", style="branch", accent="gold")
    m = p.body
    for side in (1, -1):
        pts = arc(side, 2.4, 0.05, 1.2, 12)
        m.tube("plum", pts, lambda t: 0.26 - 0.2 * t, seg=10)
        for k in (4, 7, 10):
            q = pts[k]
            for x in (-0.18, 0.18):
                flower(m, "sakura" if k % 2 else "petal", "gold", (x, q.y + 0.1, q.z), r=0.42)
        p.tips.append(pts[-1])
        p.glow.blob("glow", (0.22, 0.22, 0.22), loc=tuple(pts[-1]))
    flower(m, "sakura", "gold", (0.3, H.y, 0), r=0.75)
    flower(m, "sakura", "gold", (-0.3, H.y, 0), r=0.75)
    p.glow.blob("glow", (0.7, 0.42, 0.42), loc=tuple(H))


# ---- World 3: Galaxy Drift --------------------------------------------------------------
@design("MeteorScoop", (255, 140, 60))
def _(p):
    handle(p, "darkgray", "meteor")
    m = p.body
    faceted(m, "meteor", (0.9, 1.1, 1.1), tuple(H), seg=7, rings=5)
    for side in (1, -1):
        pts = arc(side, 2.2, 0.15, 1.05, 3)
        for k, q in enumerate(pts):
            faceted(m, "meteor", (0.7 - k * 0.12, 0.75 - k * 0.13, 0.75 - k * 0.13), tuple(q), rot=(k * 30, k * 20, 0))
            p.glow.blob("glow", (0.72 - k * 0.12, 0.12, 0.12), loc=tuple(q + Vector((0, 0.15, 0))))
        p.tips.append(pts[-1])


@design("RocketSpade", (255, 160, 60))
def _(p):
    handle(p, "gray", "rocket")
    m = p.body
    # the rocket lies across the head: nose cone up, fins and a nozzle down
    m.cyl("rocket", 0.45, 2.0, loc=tuple(H))
    m.cyl("red", 0.45, 0.9, loc=(0, H.y, 1.45), radius2=0.02)
    m.torus("red", 0.45, 0.06, loc=(0, H.y, 0.5))
    m.cyl("sky", 0.18, 0.1, loc=(0.42, H.y, 0.2), rot=(0, 90, 0))
    m.cyl("darkgray", 0.3, 0.5, loc=(0, H.y, -1.2), radius2=0.42)
    for a in (0, 90, 180, 270):
        ca, sa = math.cos(R(a)), math.sin(R(a))
        fin = [Vector((ca * 0.4, H.y + sa * 0.4, -0.5)), Vector((ca * 0.85, H.y + sa * 0.85, -1.2)), Vector((ca * 0.4, H.y + sa * 0.4, -1.0))]
        rod(m, "red", fin[0], fin[1], 0.07)
        rod(m, "red", fin[1], fin[2], 0.07)
    p.glow.cyl("glow", 0.24, 0.7, loc=(0, H.y, -1.75), radius2=0.02)
    p.tips += [at(H.y, 1.95), at(H.y, -2.05)]


@design("OrbitShovel", (150, 200, 255))
def _(p):
    handle(p, "navy", "planet")
    m = p.body
    arm(p, "planet", 1, r0=0.28)
    arm(p, "planet", -1, r0=0.28)
    m.blob("planet", (1.0, 1.0, 1.0), loc=tuple(H))
    m.torus("planetring", 0.85, 0.07, loc=tuple(H), rot=(20, 30, 0), scale=(1, 1, 0.25))
    m.blob("white", (0.32, 0.32, 0.32), loc=(0.2, H.y - 0.9, 0.9))
    rod(m, "gray", (0, H.y - 0.3, 0.3), (0.2, H.y - 0.9, 0.9), 0.03)
    p.glow.torus("glow", 0.95, 0.03, loc=tuple(H), rot=(20, 30, 0), scale=(1, 1, 0.25))


@design("NebulaTrowel", (200, 120, 255))
def _(p):
    handle(p, "void", "nebula")
    m = p.body
    for side in (1, -1):
        tip = arm(p, "nebula", side, r0=0.32, R_=2.4)
        # swirls of space dust along the arm
        for k in range(3):
            q = arc(side, 2.4, 0.3 + k * 0.28, 0.3 + k * 0.28, 1)[0]
            m.blob("lilac", (0.5, 0.5, 0.42), loc=tuple(q + Vector((0, 0.05, 0))))
            p.glow.blob("glow", (0.12, 0.12, 0.12), loc=tuple(q + Vector((0.28, 0.1, 0.1))))
    m.blob("nebula", (0.95, 0.95, 0.95), loc=tuple(H))
    p.glow.blob("glow", (0.5, 0.5, 0.5), loc=tuple(H + Vector((0, 0.1, 0))))


@design("CometCrusher", (130, 220, 255))
def _(p):
    handle(p, "navy", "comet")
    m = p.body
    # the comet's head is a hammer up top; its tail streams down as the pick
    m.blob("comet", (1.1, 1.1, 1.1), loc=(0, H.y, 0.8))
    p.glow.blob("glow", (0.8, 0.8, 0.8), loc=(0, H.y + 0.05, 0.85))
    for k in range(5):
        m.blob("sky" if k % 2 else "comet", (0.75 - k * 0.12, 0.7 - k * 0.1, 0.55), loc=(0, H.y - 0.05 * k, -0.1 - k * 0.42))
    m.cyl("sky", 0.12, 0.5, loc=(0, H.y - 0.25, -2.3), radius2=0.0)
    p.tips += [at(H.y, 1.5), at(H.y - 0.25, -2.5)]


@design("SupernovaSpade", (255, 220, 120))
def _(p):
    handle(p, "void", "gold")
    m = p.body
    shape(m, "orange", star_pts(H.y, 0, 8, 2.1, 0.55, turn=R(90)), 0.28, bevel=0.06)
    shape(m, "yellow", star_pts(H.y, 0, 8, 1.4, 0.45, turn=R(90 + 22.5)), 0.36, bevel=0.05)
    p.glow.blob("glow", (0.5, 0.9, 0.9), loc=tuple(H))
    p.tips += [at(H.y, 2.1), at(H.y, -2.1)]


@design("EventHorizon", (190, 130, 255))
def _(p):
    handle(p, "void", "nebula", accent="lilac")
    m = p.body
    for side in (1, -1):
        arm(p, "void", side, r0=0.34, R_=2.5, reach=1.25)
        p.glow.tube("glow", arc(side, 2.5, 0.3, 1.2, 10, flare=0.0), 0.04, seg=6)
    m.blob("void", (1.2, 1.2, 1.2), loc=tuple(H))
    p.glow.torus("glow", 0.95, 0.12, loc=tuple(H), rot=(70, 0, 0), scale=(1, 1, 0.3))


# ---- World 4: Frostbyte Tundra ----------------------------------------------------------
@design("SnowballScoop", (190, 235, 255))
def _(p):
    handle(p, "wood", "frost")
    m = p.body
    m.blob("snow", (1.3, 1.3, 1.3), loc=(0, H.y, 0.35))
    m.blob("snow", (0.9, 0.9, 0.9), loc=(0, H.y, 1.2))
    m.cyl("orange", 0.09, 0.45, loc=(0.6, H.y, 1.2), rot=(0, 90, 0), radius2=0.0)
    for x in (-0.38, 0.38):
        m.blob("black", (0.1, 0.1, 0.1), loc=(x * 0.6 + 0.2, H.y + 0.2, 1.35))
    arm(p, "frost", -1, r0=0.26, reach=1.05)
    p.tips.append(at(H.y, 1.65))


@design("IcicleSpade", (170, 230, 255))
def _(p):
    handle(p, "frost", "white")
    m = p.body
    for side in (1, -1):
        for k, (dy, length, r) in enumerate(((0.0, 2.1, 0.32), (0.35, 1.5, 0.22), (-0.35, 1.3, 0.2))):
            base = H + Vector((0, dy, 0.2 * side))
            end = base + Vector((0, -0.15 * length, side * length))
            rod(m, "icicle", base, end, r, 0.0, seg=8)
            if k == 0:
                p.tips.append(end)
    m.blob("white", (0.75, 0.9, 0.7), loc=tuple(H))


@design("PenguinPaddle", (255, 200, 90))
def _(p):
    handle(p, "navy", "frost")
    m = p.body
    m.blob("black", (0.95, 1.1, 1.5), loc=tuple(H))
    m.blob("white", (0.97, 0.75, 1.1), loc=(0, H.y - 0.08, -0.05))
    m.blob("black", (0.75, 0.75, 0.75), loc=(0, H.y, 0.9))
    m.cyl("orange", 0.12, 0.35, loc=(0, H.y - 0.45, 0.85), rot=(90, 0, 0), radius2=0.0)
    for x in (-0.25, 0.25):
        m.blob("white", (0.12, 0.14, 0.14), loc=(x, H.y - 0.3, 1.02))
    # the flippers are the pick blades
    for side in (1, -1):
        shape(m, "black", [(H.y + 0.1, 0.5 * side), (H.y - 0.2, 2.1 * side), (H.y - 0.55, 0.4 * side)], 0.16, bevel=0.06, smooth=True)
        p.tips.append(at(H.y - 0.2, 2.1 * side))
    for x in (-0.25, 0.25):
        m.blob("orange", (0.2, 0.35, 0.12), loc=(x, H.y - 0.15, -0.75))


@design("FrostbiteShovel", (110, 220, 255))
def _(p):
    handle(p, "iron", "frost", accent="icicle")
    m = p.body
    for side in (1, -1):
        arm(p, "frost", side, r0=0.32)
        for k in (4, 8, 12):
            q = arc(side, 2.3, 0.05, 1.15, 14)[k]
            rod(m, "icicle", q, q + Vector((0, 0.35, 0.15 * side)), 0.1, 0.0, seg=6)
        p.glow.tube("glow", arc(side, 2.45, 0.1, 1.1, 10), 0.03, seg=6)
    faceted(m, "icicle", (0.8, 0.8, 0.8), tuple(H))
    p.glow.blob("glow", (0.3, 0.3, 0.3), loc=tuple(H + Vector((0.3, 0, 0))))


@design("BlizzardBreaker", (200, 240, 255))
def _(p):
    handle(p, "iron", "white", accent="icicle")
    m = p.body
    m.box("icicle", (0.95, 1.05, 1.3), loc=(0, H.y, 0.9), bevel=0.12)
    m.box("snow", (1.0, 1.1, 0.3), loc=(0, H.y, 1.55), bevel=0.08)
    for k in range(6):
        a = 2 * math.pi * k / 6
        rod(m, "white", at(H.y, -1.15), at(H.y + math.cos(a) * 0.75, -1.15 + math.sin(a) * 0.75), 0.06)
        rod(m, "white", at(H.y + math.cos(a) * 0.45, -1.15 + math.sin(a) * 0.45), at(H.y + math.cos(a + 0.5) * 0.65, -1.15 + math.sin(a + 0.5) * 0.65), 0.04)
    rod(m, "iron", at(H.y, -0.3), at(H.y, -0.75), 0.15)
    p.glow.blob("glow", (0.28, 0.28, 0.28), loc=(0, H.y, -1.15))
    p.tips += [at(H.y, 1.75), at(H.y - 0.75, -1.15)]


@design("AuroraAuger", (110, 255, 190))
def _(p):
    handle(p, "navy", "aurora", accent="frost")
    m = p.body
    for side in (1, -1):
        for k, c in enumerate(("aurora", "frost", "nebula")):
            pts = arc(side, 2.2 + k * 0.14, 0.05, 1.15 - k * 0.12, 12)
            o = m.tube(c, pts, lambda t, k=k: (0.2 - k * 0.04) * (1 - t * 0.8), seg=10)
            for v in o.data.vertices:
                v.co.x = v.co.x * 0.35 + (k - 1) * 0.16
        p.tips.append(arc(side, 2.2, 0.05, 1.15, 1)[-1])
        p.glow.tube("glow", arc(side, 2.36, 0.15, 1.05, 10), 0.03, seg=6)
    faceted(m, "aurora", (0.8, 0.9, 0.9), tuple(H))


@design("AbsoluteZeroSpade", (220, 245, 255))
def _(p):
    handle(p, "frost", "white", accent="icicle")
    m = p.body
    for side in (1, -1):
        for k, (ang, length, r) in enumerate(((0, 2.3, 0.4), (25, 1.6, 0.28), (-22, 1.4, 0.26), (45, 1.0, 0.2))):
            d = Vector((0, -math.sin(R(ang)) * 0.6, side)).normalized()
            base = H + Vector((0, 0, 0.25 * side))
            rod(m, "icicle", base, base + d * length * 0.75, r, r * 0.95, seg=6)
            rod(m, "icicle", base + d * length * 0.75, base + d * length, r * 0.95, 0.0, seg=6)
            if k == 0:
                p.tips.append(base + d * length)
    faceted(m, "snow", (1.0, 1.0, 1.0), tuple(H), seg=6, rings=3)
    p.glow.blob("glow", (0.55, 0.55, 0.55), loc=tuple(H))
    p.glow.tube("glow", [H + Vector((0, 0, -1.9)), H + Vector((0, 0, 1.9))], 0.05, seg=6)


# ---- World 5: Chrome Dunes --------------------------------------------------------------
@design("SandyScoop", (255, 220, 140))
def _(p):
    handle(p, "wood", "sandstone")
    m = p.body
    for side in (1, -1):
        pts = arc(side, 2.2, 0.1, 1.05, 4)
        for k, q in enumerate(pts):
            m.box("sandstone" if k % 2 else "tan", (0.6 - k * 0.08, 0.62 - k * 0.09, 0.62 - k * 0.09), loc=tuple(q), rot=(k * 12 * side, 0, 0), bevel=0.06)
        p.tips.append(pts[-1])
    m.box("tan", (0.7, 0.8, 0.8), loc=tuple(H), bevel=0.1)


@design("CactusSpade", (255, 120, 170))
def _(p):
    handle(p, "wood", "cactus")
    m = p.body
    for side in (1, -1):
        pts = arc(side, 2.1, 0.05, 1.1, 10)
        m.tube("cactus", pts, lambda t: 0.3 - 0.12 * t, seg=10)
        for k in (2, 5, 8):
            q = pts[k]
            for dx in (-0.28, 0.28):
                rod(m, "cream", q + Vector((dx * 0.7, 0, 0)), q + Vector((dx * 1.3, 0.12, 0.05)), 0.02, 0.0, seg=4)
        m.blob("cactus", (0.42, 0.42, 0.42), loc=tuple(pts[-1]))
        p.tips.append(pts[-1])
    m.blob("cactus", (0.75, 0.9, 0.9), loc=tuple(H))
    flower(m, "hotpink", "yellow", (0.0, H.y + 0.5, 0), r=0.4)


@design("MirageShovel", (200, 230, 255))
def _(p):
    handle(p, "chrome", "lapis", style="square", accent="chrome")
    m = p.body
    for side in (1, -1):
        pts = [(H.y + 0.35 + 0.18 * math.sin(k * 0.9), side * k * 0.22) for k in range(10)]
        pts += [(H.y - 0.35 + 0.18 * math.sin(k * 0.9 + 0.6), side * k * 0.22) for k in range(9, -1, -1)]
        shape(m, "chrome", pts, 0.16, bevel=0.03, smooth=True)
        p.tips.append(at(H.y + 0.1, side * 2.0))
        p.glow.tube("glow", [at(H.y + 0.18 * math.sin(k * 0.9 + 0.3), side * k * 0.22, 0.1) for k in range(1, 10)], 0.03, seg=5)
    m.blob("chrome", (0.7, 0.8, 0.8), loc=tuple(H))


@design("PharaohSpade", (90, 160, 255))
def _(p):
    handle(p, "gold", "lapis", accent="gold")
    for y in (-1.5, -1.1, -0.7):
        p.body.torus("lapis", 0.19, 0.05, loc=(0, y, 0), rot=(90, 0, 0))
    m = p.body
    for side in (1, -1):
        arm(p, "gold", side, r0=0.32)
        for k in (3, 6, 9):
            arm_ring(m, "lapis", side, 2.3, 1.15, k, 14, 0.27 - k * 0.015, 0.05)
    # an ankh on the socket
    m.torus("gold", 0.3, 0.08, loc=(0.3, H.y + 0.45, 0), rot=(0, 90, 0), scale=(1, 0.8, 1.25))
    m.box("gold", (0.15, 0.95, 0.18), loc=(0.3, H.y - 0.25, 0), bevel=0.03)
    m.box("gold", (0.15, 0.18, 0.8), loc=(0.3, H.y + 0.05, 0), bevel=0.03)
    m.box("lapis", (0.6, 0.75, 0.75), loc=tuple(H), bevel=0.08)


@design("SolarSifter", (255, 220, 90))
def _(p):
    handle(p, "chrome", "solar")
    m = p.body
    for side in (1, -1):
        shape(m, "chrome", [(H.y + 0.45, 0.35 * side), (H.y + 0.3, 2.0 * side), (H.y - 0.45, 1.9 * side), (H.y - 0.35, 0.35 * side)], 0.1, bevel=0.02)
        for k in range(4):
            z = side * (0.55 + k * 0.36)
            for y in (H.y + 0.18, H.y - 0.18):
                m.box("solar", (0.14, 0.3, 0.3), loc=(0, y, z), bevel=0.01)
        p.tips.append(at(H.y, 2.0 * side))
    m.cyl("gold", 0.5, 0.3, loc=tuple(H), rot=(0, 90, 0))
    p.glow.cyl("glow", 0.38, 0.36, loc=tuple(H), rot=(0, 90, 0))


@design("SandstormDrill", (255, 210, 120))
def _(p):
    handle(p, "iron", "sandstone", accent="gold")
    m = p.body
    m.box("iron", (0.8, 1.1, 1.0), loc=tuple(H), bevel=0.12)
    for side in (1, -1):
        for k in range(5):
            r = 0.55 - k * 0.1
            m.cyl("sandstone" if k % 2 else "gold", r, 0.38, loc=(0, H.y, side * (0.65 + k * 0.34)), radius2=r * 0.8)
        m.cyl("gold", 0.1, 0.3, loc=(0, H.y, side * 2.4), radius2=0.0, rot=(0 if side > 0 else 180, 0, 0))
        pts = [at(H.y + 0.55 * math.cos(k * 0.7) * (1 - k / 22), side * (0.6 + k * 0.08), 0.55 * math.sin(k * 0.7) * (1 - k / 22)) for k in range(22)]
        m.tube("tan", pts, 0.05, seg=5)
        p.tips.append(at(H.y, side * 2.55))


@design("SunKingShovel", (255, 200, 60))
def _(p):
    handle(p, "gold", "lapis", accent="gold")
    m = p.body
    for side in (1, -1):
        arm(p, "chrome", side, r0=0.3, R_=2.4)
    shape(m, "gold", star_pts(H.y, 0, 12, 1.25, 0.8), 0.26, bevel=0.04)
    m.cyl("orange", 0.65, 0.34, loc=tuple(H), rot=(0, 90, 0))
    p.glow.cyl("glow", 0.48, 0.4, loc=tuple(H), rot=(0, 90, 0))


# ---- World 6: Coral Circuit -------------------------------------------------------------
@design("SeashellScoop", (255, 200, 210))
def _(p):
    handle(p, "wood", "shell")
    m = p.body
    # a scallop shell fan up top, a pointed conch down below
    for k in range(7):
        a = R(-60 + k * 20)
        rod(m, "shell" if k % 2 else "coral", H + Vector((0, 0, 0.2)), H + Vector((0, math.sin(a) * 1.3, 0.2 + math.cos(a) * 1.5)), 0.17, 0.26, seg=8)
    m.cyl("coral", 0.4, 1.6, loc=(0, H.y, -0.9), radius2=0.02)
    for k in range(4):
        m.torus("shell", 0.4 - k * 0.09, 0.06, loc=(0, H.y, -0.3 - k * 0.4))
    p.tips += [at(H.y, 1.75), at(H.y, -1.75)]


@design("AnchorSpade", (120, 200, 255))
def _(p):
    handle(p, "iron", "wave", accent="iron")
    m = p.body
    m.torus("iron", 0.35, 0.09, loc=(0, H.y + 0.55, 0), rot=(0, 90, 0))
    for side in (1, -1):
        pts = arc(side, 1.7, 0.1, 1.35, 10)
        m.tube("iron", pts, 0.16, seg=10)
        tip = pts[-1]
        d = (pts[-1] - pts[-2]).normalized()
        shape(m, "iron", [(tip.y + 0.35, tip.z - 0.1 * side), (tip.y - d.y * 0.55, tip.z + d.z * 0.55), (tip.y - 0.25, tip.z - 0.25 * side)], 0.14)
        p.tips.append(tip + d * 0.5)
    m.box("iron", (0.3, 0.3, 1.1), loc=(0, H.y + 0.05, 0), bevel=0.06)


@design("PearlShovel", (255, 245, 255))
def _(p):
    handle(p, "wood", "shell")
    m = p.body
    for side in (1, -1):
        arm(p, "shell", side, r0=0.3)
    # an open clam on the socket with a big pearl in it
    m.blob("coral", (0.25, 1.3, 1.3), loc=(-0.35, H.y, 0), rot=(0, 0, 0))
    m.blob("shell", (0.25, 1.3, 1.3), loc=(0.35, H.y + 0.1, 0), rot=(0, 25, 0))
    m.blob("pearl", (0.7, 0.7, 0.7), loc=(0, H.y, 0))
    p.glow.blob("glow", (0.3, 0.3, 0.3), loc=(0.2, H.y, 0.12))


@design("TridentTrowel", (255, 220, 120))
def _(p):
    handle(p, "gold", "wave", accent="gold")
    m = p.body
    # three prongs up (the pick), a heavy counterweight spike down
    m.box("gold", (0.3, 0.3, 1.5), loc=(0, H.y, 0.4), bevel=0.06)
    for dz, length in ((-0.6, 1.4), (0, 1.9), (0.6, 1.4)):
        base = Vector((0, H.y, 0.9 + abs(dz) * 0.0)) + Vector((0, 0, dz * 0))
        start = Vector((0, H.y + dz, 0.9))
        rod(m, "gold", start, start + Vector((0, 0, length)), 0.12)
        shape(m, "gold", [(start.y - 0.25, start.z + length), (start.y, start.z + length + 0.5), (start.y + 0.25, start.z + length)], 0.12)
        p.tips.append(start + Vector((0, 0, length + 0.5)))
    rod(m, "gold", at(H.y - 0.6, 0.9), at(H.y + 0.6, 0.9), 0.13)
    rod(m, "gold", at(H.y, -0.2), at(H.y, -1.5), 0.24, 0.0, seg=8)
    p.glow.blob("glow", (0.3, 0.3, 0.3), loc=(0, H.y, 0.9))


@design("KrakenClaw", (220, 120, 255))
def _(p):
    handle(p, "kraken", "purple", accent="gold")
    m = p.body
    for side in (1, -1):
        for k in range(2):
            pts = []
            for i in range(16):
                t = i / 15
                pts.append(H + Vector(((k - 0.5) * 0.4, 0.3 - 0.8 * t ** 1.5 + 0.35 * math.sin(t * 5 + k), side * 2.1 * t)))
            m.tube("kraken", pts, lambda t: 0.27 * (1 - t) + 0.03, seg=10)
            for i in (3, 6, 9, 12):
                q = pts[i]
                m.cyl("lilac", 0.07, 0.04, loc=tuple(q + Vector((0, -0.18, 0))), rot=(90, 0, 0))
            if k == 0:
                p.tips.append(pts[-1])
    m.blob("kraken", (1.0, 1.1, 1.1), loc=tuple(H))
    for x in (-0.3, 0.3):
        m.blob("yellow", (0.2, 0.28, 0.28), loc=(x * 1.5, H.y + 0.35, 0.15))


@design("TidalExcavator", (80, 200, 255))
def _(p):
    handle(p, "wave", "white", accent="sky")
    m = p.body
    for side in (1, -1):
        # a breaking wave: a curling blade with white foam on its crest
        outer = arc(side, 2.4, 0.05, 1.15, 12)
        inner = arc(side, 1.85, 0.15, 0.95, 12)
        shape(m, "wave", [(q.y, q.z) for q in outer] + [(q.y, q.z) for q in reversed(inner)], 0.24, bevel=0.05, smooth=True)
        for k in (2, 5, 8, 11):
            m.blob("white", (0.3, 0.28, 0.28), loc=tuple(outer[k] + Vector((0, 0.05, 0))))
        p.tips.append(outer[-1])
        p.glow.tube("glow", arc(side, 2.15, 0.1, 1.05, 10), 0.04, seg=6)
    m.blob("water", (0.8, 0.9, 0.9), loc=tuple(H))


@design("AtlantisSpade", (90, 255, 230))
def _(p):
    handle(p, "marble", "gold", accent="gold")
    m = p.body
    for side in (1, -1):
        arm(p, "marble", side, r0=0.34, R_=2.4)
        for k in (3, 7, 11):
            arm_ring(m, "gold", side, 2.4, 1.15, k, 14, 0.3 - k * 0.014, 0.05)
        p.glow.tube("glow", arc(side, 2.58, 0.15, 1.05, 10), 0.035, seg=6)
    m.cyl("marble", 0.5, 0.9, loc=tuple(H), rot=(0, 90, 0))
    for k in range(8):
        a = 2 * math.pi * k / 8
        m.box("marble", (0.95, 0.1, 0.1), loc=(0, H.y + math.cos(a) * 0.5, math.sin(a) * 0.5), bevel=0.02)
    p.glow.blob("glow", (0.45, 0.45, 0.45), loc=(0.5, H.y, 0))


# ---- World 7: Candy Mainframe -----------------------------------------------------------
def candy_tube(m, pts, r, a="canered", b="white"):
    for i in range(len(pts) - 1):
        rod(m, a if i % 2 == 0 else b, pts[i], pts[i + 1], r, seg=10)
        m.blob(a if i % 2 == 0 else b, (r * 2, r * 2, r * 2), loc=tuple(pts[i + 1]))


@design("LollipopScoop", (255, 150, 220))
def _(p):
    handle(p, "white", "lolly", accent="lolly")
    m = p.body
    # a big swirly lollipop on one side, a stick-candy pick on the other
    m.cyl("lolly", 1.0, 0.3, loc=(0, H.y, 0.9), rot=(0, 90, 0))
    pts = [Vector((0.17, H.y + math.cos(t) * (0.08 + t * 0.07), 0.9 + math.sin(t) * (0.08 + t * 0.07))) for t in [k * 0.3 for k in range(40)]]
    m.tube("white", pts, 0.05, seg=5)
    rod(m, "white", at(H.y, 0), at(H.y, -0.4), 0.12)
    candy_tube(m, arc(-1, 2.1, 0.15, 1.05, 6), 0.2, "lolly", "white")
    p.tips += [at(H.y, 1.9), arc(-1, 2.1, 0.15, 1.05, 6)[-1]]


@design("CandyCaneSpade", (255, 120, 140))
def _(p):
    handle(p, "white", "canered", style="candy", accent="canered")
    m = p.body
    for side in (1, -1):
        pts = arc(side, 2.2, 0.05, 1.3, 10)
        candy_tube(m, pts, 0.22)
        p.tips.append(pts[-1])
    m.blob("canered", (0.6, 0.6, 0.6), loc=tuple(H))


@design("GummyShovel", (255, 120, 140))
def _(p):
    handle(p, "white", "gummygreen", accent="gummy")
    m = p.body
    # a gummy bear sitting on the socket, gummy worms for arms
    m.blob("gummy", (0.75, 0.8, 0.95), loc=(0, H.y, 0.35))
    m.blob("gummy", (0.7, 0.7, 0.62), loc=(0, H.y, 1.0))
    for dy in (-0.25, 0.25):
        m.blob("gummy", (0.25, 0.25, 0.25), loc=(0, H.y + dy, 1.32))
        m.blob("gummy", (0.3, 0.32, 0.45), loc=(0, H.y + dy * 1.6, 0.25))
    for x in (-0.15, 0.15):
        m.blob("black", (0.08, 0.08, 0.08), loc=(0.33, H.y + x, 1.05))
    for k, c in enumerate(("gummygreen", "yellow")):
        pts = [H + Vector(((k - 0.5) * 0.3, 0.25 * math.sin(i * 0.8), -0.2 - i * 0.16)) for i in range(12)]
        m.tube(c, pts, lambda t: 0.16 * (1 - t * 0.6), seg=8)
    p.tips += [at(H.y, 1.45), H + Vector((0, 0, -2.0))]


@design("SprinkleSpade", (255, 160, 220))
def _(p):
    handle(p, "lightwood", "frosting", accent="frosting")
    m = p.body
    # a frosted donut ring around the socket, a wafer-cone pick out of each side
    m.torus("waffle", 0.65, 0.35, loc=tuple(H), rot=(0, 90, 0))
    m.torus("frosting", 0.65, 0.33, loc=(0.06, H.y, 0), rot=(0, 90, 0), scale=(1, 1, 0.75))
    for k in range(14):
        a = 2 * math.pi * k / 14
        m.box(("yellow", "sky", "white", "lime")[k % 4], (0.06, 0.18, 0.05), loc=(0.32, H.y + math.cos(a) * 0.65, math.sin(a) * 0.65), rot=(k * 47, 0, 0), bevel=0.01)
    for side in (1, -1):
        m.cyl("waffle", 0.32, 1.3, loc=(0, H.y, side * 1.55), radius2=0.0, rot=(0 if side > 0 else 180, 0, 0))
        p.tips.append(at(H.y, side * 2.2))


@design("ChocoCrusher", (255, 200, 140))
def _(p):
    handle(p, "chocolate", "milkchoc", accent="gold")
    m = p.body
    for side in (1, -1):
        for k in range(3):
            for j in (-1, 1):
                m.box("milkchoc" if (k + j) % 2 else "chocolate", (0.55, 0.42, 0.5), loc=(0, H.y + j * 0.22, side * (0.45 + k * 0.52)), bevel=0.07)
        p.tips.append(at(H.y, side * 1.7))
    m.box("gold", (0.6, 0.95, 0.4), loc=tuple(H), bevel=0.05)


@design("JawbreakerAuger", (255, 230, 120))
def _(p):
    handle(p, "white", "jaw3", accent="jaw2")
    m = p.body
    for k, c in enumerate(("jaw1", "jaw2", "jaw3", "lolly")):
        m.blob(c, (1.5 - k * 0.12, 1.5 - k * 0.12, 1.5 - k * 0.12), loc=tuple(H + Vector((0.0 + k * 0.05, 0, 0))))
    for side in (1, -1):
        rod(m, "white", H + Vector((0, 0, side * 0.6)), H + Vector((0, 0, side * 1.9)), 0.3, 0.0, seg=8)
        p.tips.append(H + Vector((0, 0, side * 1.9)))
    for k in range(6):
        a = 2 * math.pi * k / 6 + 0.5
        m.blob(("jaw1", "jaw2", "jaw3")[k % 3], (0.3, 0.3, 0.3), loc=(0.62, H.y + math.cos(a) * 0.4, math.sin(a) * 0.4))


@design("SugarRushSpade", (255, 120, 255))
def _(p):
    handle(p, "white", "lolly", style="candy", accent="sky")
    m = p.body
    for side in (1, -1):
        for k, c in enumerate(("lolly", "jaw2", "sky")):
            pts = arc(side, 2.15 + k * 0.17, 0.05, 1.2 - k * 0.1, 12)
            o = m.tube(c, pts, lambda t, k=k: (0.2 - k * 0.03) * (1 - 0.75 * t), seg=8)
            for v in o.data.vertices:
                v.co.x = v.co.x * 0.4 + (k - 1) * 0.15
        p.tips.append(arc(side, 2.15, 0.05, 1.2, 1)[-1])
        p.glow.tube("glow", arc(side, 2.6, 0.1, 1.05, 10), 0.035, seg=6)
    m.cyl("lolly", 0.7, 0.24, loc=tuple(H), rot=(0, 90, 0))
    m.torus("white", 0.45, 0.07, loc=(0.13, H.y, 0), rot=(0, 90, 0))
    p.glow.blob("glow", (0.3, 0.3, 0.3), loc=(0.2, H.y, 0))


# ---- World 8: Volcano Forge -------------------------------------------------------------
@design("EmberSpade", (255, 140, 40))
def _(p):
    handle(p, "darkbrown", "ember", accent="iron")
    m = p.body
    for side in (1, -1):
        arm(p, "ember", side, r0=0.32)
        for k in (3, 6, 9, 12):
            q = arc(side, 2.3, 0.05, 1.15, 14)[k]
            p.glow.blob("glow", (0.36 - k * 0.015, 0.1, 0.12), loc=tuple(q + Vector((0, 0.08, 0))), rot=(k * 33, 0, 0))
    m.box("iron", (0.7, 0.8, 0.8), loc=tuple(H), bevel=0.08)


@design("AnvilShovel", (255, 170, 80))
def _(p):
    handle(p, "darkbrown", "iron", accent="iron")
    m = p.body
    # the head IS an anvil: a flat-topped block with a horn on one side and a heel on the other
    m.box("anvil", (0.9, 1.0, 1.6), loc=(0, H.y + 0.15, 0), bevel=0.08)
    m.box("anvil", (0.75, 0.6, 1.0), loc=(0, H.y - 0.35, 0), bevel=0.06)
    m.cyl("anvil", 0.42, 1.3, loc=(0, H.y + 0.3, 1.45), radius2=0.03)
    m.box("anvil", (0.9, 0.6, 0.6), loc=(0, H.y + 0.35, -1.05), bevel=0.06)
    m.box("gray", (0.92, 0.12, 1.62), loc=(0, H.y + 0.66, 0), bevel=0.03)
    p.glow.box("glow", (0.3, 0.06, 0.6), loc=(0, H.y + 0.73, 0.2), bevel=0.02)
    p.tips += [at(H.y + 0.3, 2.1), at(H.y + 0.35, -1.35)]


@design("MagmaScoop", (255, 120, 30))
def _(p):
    handle(p, "darkgray", "magma", accent="iron")
    m = p.body
    for side in (1, -1):
        pts = arc(side, 2.2, 0.1, 1.05, 4)
        for k, q in enumerate(pts):
            faceted(m, "magma", (0.78 - k * 0.12, 0.8 - k * 0.13, 0.8 - k * 0.13), tuple(q), rot=(k * 25, k * 15, 0))
            # lava dripping off the bottom of each rock
            p.glow.blob("glow", (0.12, 0.12, 0.3), loc=tuple(q + Vector((0, -0.35 + k * 0.05, 0))))
        p.tips.append(pts[-1])
    faceted(m, "magma", (0.9, 1.0, 1.0), tuple(H), seg=7, rings=5)
    p.glow.blob("glow", (0.92, 0.3, 0.4), loc=tuple(H))


@design("ObsidianBlade", (180, 110, 255))
def _(p):
    handle(p, "obsidian", "purple", accent="lilac")
    m = p.body
    for side in (1, -1):
        for k, (dy, length, w) in enumerate(((0.0, 2.2, 0.55), (0.32, 1.4, 0.35), (-0.3, 1.2, 0.3))):
            b = H.y + dy
            shape(m, "obsidian", [(b - w / 2, 0.2 * side), (b + w / 2, 0.2 * side), (b + w * 0.1, side * length), (b - w * 0.3, side * length * 0.9)], 0.22 - k * 0.04, bevel=0.0)
            if k == 0:
                p.tips.append(at(b, side * length))
                p.glow.tube("glow", [at(b + w * 0.35, 0.3 * side), at(b + w * 0.05, side * (length - 0.1))], 0.025, seg=5)
    faceted(m, "obsidian", (0.75, 0.85, 0.85), tuple(H), seg=5, rings=3)


@design("DragonboneSpade", (255, 120, 60))
def _(p):
    handle(p, "dragonbone", "darkred", accent="dragonbone")
    m = p.body
    # two curved dragon fangs, and a little dragon skull with horns holding them
    for side in (1, -1):
        pts = arc(side, 2.3, 0.15, 1.2, 12)
        m.tube("dragonbone", pts, lambda t: 0.36 * (1 - t) ** 0.9 + 0.02, seg=12)
        p.tips.append(pts[-1])
    m.blob("dragonbone", (0.9, 1.1, 1.0), loc=tuple(H))
    m.blob("dragonbone", (0.65, 0.6, 0.55), loc=(0, H.y + 0.55, 0))
    for x in (-0.3, 0.3):
        m.blob("void", (0.18, 0.22, 0.2), loc=(x * 1.15, H.y + 0.35, 0.2))
        rod(m, "darkbrown", Vector((x, H.y - 0.2, 0.35)), Vector((x * 2.2, H.y - 0.85, 0.7)), 0.1, 0.0, seg=6)
        p.glow.blob("glow", (0.1, 0.1, 0.1), loc=(x * 1.35, H.y + 0.38, 0.22))


@design("InfernoAuger", (255, 150, 30))
def _(p):
    handle(p, "iron", "orange", accent="gold")
    m = p.body
    for side in (1, -1):
        # flame-shaped blades: wavy tongues of fire
        pts = [(H.y + 0.45, 0.25 * side)]
        for k in range(1, 8):
            pts.append((H.y + 0.45 - k * 0.05 + (0.22 if k % 2 else 0.0), side * (0.25 + k * 0.27)))
        pts.append((H.y - 0.2, side * 2.4))
        for k in range(7, 0, -1):
            pts.append((H.y - 0.45 + k * 0.03 - (0.18 if k % 2 else 0.0), side * (0.25 + k * 0.24)))
        pts.append((H.y - 0.45, 0.25 * side))
        shape(m, "fire", pts, 0.2, bevel=0.04, smooth=True)
        p.tips.append(at(H.y - 0.2, side * 2.4))
        p.glow.tube("glow", [at(H.y + 0.05 - k * 0.02, side * (0.3 + k * 0.22), 0.11) for k in range(9)], 0.06, seg=6)
    m.box("iron", (0.75, 0.9, 0.8), loc=tuple(H), bevel=0.1)


@design("CoreBreaker", (255, 170, 40))
def _(p):
    handle(p, "obsidian", "lava", accent="gold")
    m = p.body
    for side in (1, -1):
        arm(p, "obsidian", side, r0=0.4, R_=2.4, reach=1.2)
        for k in (4, 8, 12):
            q = arc(side, 2.4, 0.05, 1.2, 14)[k]
            rod(m, "obsidian", q, q + Vector((0, 0.5, 0.2 * side)), 0.14, 0.0, seg=6)
        p.glow.tube("glow", arc(side, 2.4, 0.1, 1.1, 10), 0.07, seg=6)
    # the molten core in a cage of dark plates
    p.glow.blob("glow", (1.05, 1.05, 1.05), loc=tuple(H))
    for k in range(4):
        a = R(45 + k * 90)
        m.box("obsidian", (1.15, 0.22, 0.6), loc=(0, H.y + math.cos(a) * 0.5, math.sin(a) * 0.5), rot=(math.degrees(a) + 90, 0, 0), bevel=0.05)


# ---- World 9: Glitch Nexus --------------------------------------------------------------
@design("PlaceholderSpade", (255, 0, 220))
def _(p):
    handle(p, "placeholder", "placeholder", style="square", accent="placeholder")
    m = p.body
    # an untextured grey pick with a magenta "missing texture" checker block for a socket
    for side in (1, -1):
        m.box("placeholder", (0.4, 0.4, 1.8), loc=(0, H.y, side * 1.05), bevel=0.0)
        p.tips.append(at(H.y, side * 1.95))
    for i in range(2):
        for j in range(2):
            for k in range(2):
                m.box("missing" if (i + j + k) % 2 else "black", (0.35, 0.35, 0.35), loc=(-0.175 + i * 0.35, H.y - 0.175 + j * 0.35, -0.175 + k * 0.35), bevel=0.0)


@design("PixelShovel", (110, 220, 255))
def _(p):
    handle(p, "darkbrown", "brown", style="pixel")
    m = p.body
    # an 8-bit pickaxe made of cubes
    for side in (1, -1):
        cells = [(0, 1), (0, 2), (-1, 3), (-1, 4), (-2, 5), (-3, 6)]
        for k, (dy, dz) in enumerate(cells):
            m.box("pixel1" if k % 2 else "pixel2", (0.34, 0.34, 0.34), loc=(0, H.y + dy * 0.34, side * dz * 0.34), bevel=0.0)
        p.tips.append(at(H.y - 3 * 0.34, side * 6 * 0.34))
    m.box("pixel2", (0.36, 0.36, 0.36), loc=tuple(H), bevel=0.0)
    m.box("pixel1", (0.36, 0.36, 0.36), loc=(0, H.y + 0.34, 0), bevel=0.0)


@design("LagSpade", (90, 255, 230))
def _(p):
    handle(p, "darkgray", "wire")
    m = p.body
    for side in (1, -1):
        arm(p, "steel", side, r0=0.3)
    # two laggy afterimages of the head trailing behind it
    for k, (dy, c) in enumerate(((-0.35, "wire"), (-0.7, "pixel1"))):
        for side in (1, -1):
            pts = [q + Vector((0.35 * (k + 1), dy, 0)) for q in arc(side, 2.3, 0.05, 1.1, 8)]
            o = m.tube(c, pts, lambda t, k=k: (0.2 - k * 0.05) * (1 - t * 0.8), seg=6)
            for v in o.data.vertices:
                v.co.x = 0.35 * (k + 1) + (v.co.x - 0.35 * (k + 1)) * 0.3
    m.box("steel", (0.6, 0.7, 0.7), loc=tuple(H), bevel=0.06)
    p.glow.box("glow", (0.08, 0.5, 0.5), loc=(0.35, H.y, 0), bevel=0.0)


@design("WireframeShovel", (60, 255, 140))
def _(p):
    handle(p, "terminal", "terminal", accent="wire")
    # only the edges of a pick, drawn in glowing green lines
    for side in (1, -1):
        outer = arc(side, 2.45, 0.05, 1.15, 8)
        inner = arc(side, 2.05, 0.08, 1.05, 8)
        for a, b in zip(outer, outer[1:]):
            rod(p.glow, "glow", a, b, 0.045, seg=5)
        for a, b in zip(inner, inner[1:]):
            rod(p.glow, "glow", a, b, 0.045, seg=5)
        for a, b in zip(outer, inner):
            rod(p.glow, "glow", a, b, 0.035, seg=5)
        p.tips.append(outer[-1])
    for dy in (-0.35, 0.35):
        for dz in (-0.35, 0.35):
            rod(p.glow, "glow", H + Vector((-0.35, dy, dz)), H + Vector((0.35, dy, dz)), 0.04, seg=5)
            rod(p.glow, "glow", H + Vector((0, dy, -0.35)), H + Vector((0, dy, 0.35)), 0.04, seg=5)
    p.body.box("terminal", (0.3, 0.6, 0.6), loc=tuple(H), bevel=0.03)


@design("Error404Scoop", (255, 80, 90))
def _(p):
    handle(p, "darkgray", "error", accent="gray")
    m = p.body
    # a red error box with a broken, jagged arm on each side
    m.box("error", (0.6, 1.2, 1.2), loc=tuple(H), bevel=0.08)
    m.box("white", (0.62, 0.9, 0.18), loc=(0, H.y, 0.1), bevel=0.03)
    for side in (1, -1):
        pts = arc(side, 2.3, 0.3, 1.1, 6)
        for k, (a, b) in enumerate(zip(pts, pts[1:])):
            jitter = Vector((0, 0.12 if k % 2 else -0.12, 0))
            rod(m, "gray" if k % 2 else "darkgray", a + jitter, b - jitter, 0.22 - k * 0.025, seg=4)
        p.tips.append(pts[-1])
    p.glow.box("glow", (0.08, 0.95, 1.0), loc=(0.33, H.y, 0), bevel=0.0)


@design("DebugDrill", (70, 255, 120))
def _(p):
    handle(p, "terminal", "wire", style="square", accent="wire")
    m = p.body
    # a console box with a green screen, a drill bit out of each side
    m.box("terminal", (0.9, 1.1, 1.0), loc=tuple(H), bevel=0.1)
    p.glow.box("glow", (0.06, 0.75, 0.7), loc=(0.46, H.y + 0.05, 0), bevel=0.0)
    for side in (1, -1):
        for k in range(4):
            r = 0.42 - k * 0.09
            m.cyl("steel" if k % 2 else "gray", r, 0.42, loc=(0, H.y, side * (0.7 + k * 0.4)), radius2=r * 0.8)
        m.cyl("wire", 0.1, 0.35, loc=(0, H.y, side * 2.4), radius2=0.0, rot=(0 if side > 0 else 180, 0, 0))
        p.tips.append(at(H.y, side * 2.55))


@design("TheFinalPatch", (255, 240, 170))
def _(p):
    handle(p, "white", "patch", accent="gold")
    m = p.body
    # a holy bandage patch on the socket, halo-gold pick arms, pixels flaking off
    for side in (1, -1):
        arm(p, "gold", side, r0=0.34, R_=2.4)
        p.glow.tube("glow", arc(side, 2.55, 0.1, 1.08, 10), 0.04, seg=6)
        for k in (5, 9, 13):
            q = arc(side, 2.4, 0.05, 1.15, 14)[k]
            p.glow.box("glow", (0.12, 0.12, 0.12), loc=tuple(q + Vector((0.3, 0.25, 0))), bevel=0.0)
    m.box("patch", (0.5, 1.1, 1.6), loc=tuple(H), rot=(35, 0, 0), bevel=0.15)
    m.box("white", (0.52, 0.55, 0.55), loc=tuple(H), rot=(35, 0, 0), bevel=0.08)
    p.glow.torus("glow", 0.75, 0.05, loc=(0, H.y + 1.0, 0), rot=(90, 0, 0))


# ------------------------------------------------------------------------------------------
# finishing, export, previews
# ------------------------------------------------------------------------------------------
def to_roblox(v):
    return (v[0], v[2], -v[1])


def finish_piece(m, max_tris=5000):
    """Joins a piece's parts, records where its center sits (Roblox tool space) and centers it."""
    if not m.parts:
        return None, None
    bpy.ops.object.select_all(action="DESELECT")
    for o in m.parts:
        o.select_set(True)
    bpy.context.view_layer.objects.active = m.parts[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = m.name
    obj.data.name = m.name
    me = obj.data
    lo = Vector([min(v.co[i] for v in me.vertices) for i in range(3)])
    hi = Vector([max(v.co[i] for v in me.vertices) for i in range(3)])
    center = (lo + hi) / 2
    size = hi - lo
    me.transform(Matrix.Translation(-center))
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    if tris > max_tris:
        mod = obj.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = max_tris / tris
        bpy.ops.object.modifier_apply(modifier=mod.name)
    mod = obj.modifiers.new("Tri", "TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.materials.clear()
    obj.data.materials.append(memekit.palette_material())
    info = {"Size": (size.x, size.z, size.y), "Center": to_roblox(center)}
    return obj, info


def build(pid):
    fn, glow = D[pid]
    p = Pick(pid, glow)
    fn(p)
    body, body_info = finish_piece(p.body)
    glow_obj, glow_info = finish_piece(p.glow, max_tris=2500)
    data = {"Body": body_info, "Glow": glow_info, "GlowColor": glow, "Tips": [to_roblox(t) for t in p.tips]}
    return [o for o in (body, glow_obj) if o], data


def glow_material(color):
    mat = bpy.data.materials.new("Glow")
    mat.use_nodes = True
    bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    c = [x / 255 for x in color] + [1]
    bsdf.inputs["Base Color"].default_value = c
    for key in ("Emission Color", "Emission"):
        if key in bsdf.inputs:
            bsdf.inputs[key].default_value = c
            break
    bsdf.inputs["Emission Strength"].default_value = 2.0
    return mat


def preview(ids, path):
    """All of a world's pickaxes side by side, seen from the side (+x), glow lit up."""
    memekit.reset()
    objs = []
    for i, pid in enumerate(ids):
        pieces, data = build(pid)
        for o in pieces:
            c = data["Glow" if o.name.endswith("Glow") else "Body"]["Center"]
            home = Matrix.Translation(Vector((c[0], -c[2], c[1])))  # back where it was built
            o.matrix_world = Matrix.Translation((0, i * 5.6, 0)) @ Matrix.Rotation(R(90), 4, "X") @ home
            if o.name.endswith("Glow"):
                o.data.materials.clear()
                o.data.materials.append(glow_material(data["GlowColor"]))
            objs.append(o)
    scene = bpy.context.scene
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 5.6 * len(ids)
    mid_y = (len(ids) - 1) * 5.6 / 2
    cam.location = (14, mid_y, 0.9)
    cam.rotation_euler = (R(90), 0, R(90))
    scene.camera = cam
    for i, (rot, energy) in enumerate([((50, 0, 60), 3.5), ((70, 0, -100), 1.4)]):
        sun = bpy.data.objects.new("Sun%d" % i, bpy.data.lights.new("Sun%d" % i, "SUN"))
        sun.data.energy = energy
        sun.rotation_euler = [R(a) for a in rot]
        scene.collection.objects.link(sun)
    world = bpy.data.worlds.new("W")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.75, 0.82, 0.92, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.9
    scene.world = world
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 24
    scene.cycles.use_denoising = False
    scene.render.resolution_x, scene.render.resolution_y = 240 * len(ids), 300
    scene.render.filepath = path
    scene.view_settings.view_transform = "Standard"
    bpy.ops.render.render(write_still=True)


def write_lua(all_data):
    def v3(t):
        return "Vector3.new(%.3f, %.3f, %.3f)" % tuple(t)
    lines = [
        "-- PickaxeMeshData (ModuleScript in ReplicatedStorage)",
        "-- Written by tools/blender/pickaxes.py: the Blender pickaxes of worlds 2-9. Studio's",
        "-- File > Import 3D of assets/models/PickaxeMeshes.fbx + the installer put the meshes in",
        "-- ReplicatedStorage > PickaxeMeshes (<Id> and <Id>Glow). Data = each mesh's size and where",
        "-- its center sits in tool space (head at -Z, arms along Y), the glow color, and the tips the",
        "-- spark trails come off. PickaxeModels builds from these when the meshes are there.",
        "return {",
    ]
    for pid, d in all_data.items():
        body, glow = d["Body"], d["Glow"]
        parts = ["Size = %s" % v3(body["Size"]), "Center = %s" % v3(body["Center"])]
        if glow:
            parts += ["GlowSize = %s" % v3(glow["Size"]), "GlowCenter = %s" % v3(glow["Center"])]
        parts.append("GlowColor = Color3.fromRGB(%d, %d, %d)" % tuple(d["GlowColor"]))
        parts.append("Tips = {%s}" % ", ".join(v3(t) for t in d["Tips"]))
        lines.append("\t%s = {%s}," % (pid, ", ".join(parts)))
    lines.append("}")
    with open(LUA_OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


WORLDS = [
    ["BlossomTrowel", "BambooSpade", "KoiScoop", "LanternSpade", "KatanaShovel", "PetalExcavator", "HanamiHarvester"],
    ["MeteorScoop", "RocketSpade", "OrbitShovel", "NebulaTrowel", "CometCrusher", "SupernovaSpade", "EventHorizon"],
    ["SnowballScoop", "IcicleSpade", "PenguinPaddle", "FrostbiteShovel", "BlizzardBreaker", "AuroraAuger", "AbsoluteZeroSpade"],
    ["SandyScoop", "CactusSpade", "MirageShovel", "PharaohSpade", "SolarSifter", "SandstormDrill", "SunKingShovel"],
    ["SeashellScoop", "AnchorSpade", "PearlShovel", "TridentTrowel", "KrakenClaw", "TidalExcavator", "AtlantisSpade"],
    ["LollipopScoop", "CandyCaneSpade", "GummyShovel", "SprinkleSpade", "ChocoCrusher", "JawbreakerAuger", "SugarRushSpade"],
    ["EmberSpade", "AnvilShovel", "MagmaScoop", "ObsidianBlade", "DragonboneSpade", "InfernoAuger", "CoreBreaker"],
    ["PlaceholderSpade", "PixelShovel", "LagSpade", "WireframeShovel", "Error404Scoop", "DebugDrill", "TheFinalPatch"],
]


def export_all():
    memekit.reset()
    all_data, objs = {}, []
    for w, ids in enumerate(WORLDS):
        for i, pid in enumerate(ids):
            pieces, data = build(pid)
            all_data[pid] = data
            for o in pieces:
                o.location = (i * 7, w * 7, 0)
                objs.append(o)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    path = os.path.join(memekit.OUT, "PickaxeMeshes.fbx")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="COPY", embed_textures=True,
                             bake_space_transform=True)
    write_lua(all_data)
    print("wrote", path, "with", len(objs), "meshes")


def main(args):
    os.makedirs(PREVIEW, exist_ok=True)
    if args and args[0] == "preview":
        for w, ids in enumerate(WORLDS):
            if len(args) == 1 or str(w + 2) in args[1:]:
                preview(ids, os.path.join(PREVIEW, "Pickaxes_World%d.png" % (w + 2)))
        return
    export_all()


if __name__ == "__main__":
    main(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:])
