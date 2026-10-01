"""Builds the two portals as real Blender meshes (run with bpy):

  World Gate:   GatePortalFrame  - a heavy machined ring: 16 bevelled gunmetal segments, a steel
                                   inner band, brass trim, emitter housings, bolts, brass conduits
                                   with clamps, and a cradle + buttresses it stands in (textured)
                GatePortalGlow   - the glowing bits: inner lips, light strips in the segment gaps,
                                   emitter lenses and tips (Neon in the game)
                GateHorizon      - the event horizon: a dish that sinks back into the ring
                GateVortexA / B  - two sets of spiral arms that spin opposite ways over it
  Alien portal: AlienPortalRim    - a lumpy oval of goo with drips hanging off the bottom
                AlienPortalFunnel - a deep rippled oval funnel (the tunnel)
                AlienPortalSwirl  - spiral arms that spin down into the funnel

Writes assets/models/PortalMeshes.fbx (one Import 3D in Studio), one .fbx per piece,
preview renders, and src/shared/PortalMeshes.lua (each piece's size and where its center sits
relative to the portal's center, so the game can place them exactly).

Every point here is written in ROBLOX space (x right, y up, -z = the front, facing the
players) and turned into Blender space only when the mesh is made, so the FBX file comes out
in Roblox's axes (checked by reading the exported vertex data back).
Run:  python tools/blender/portals.py   (with the bpy package installed)
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402  (bpy first: it makes bmesh importable)
import bmesh  # noqa: E402
from mathutils import Vector  # noqa: E402

import memekit  # noqa: E402
from memekit import cell_uv  # noqa: E402

TAU = math.pi * 2
LUA_OUT = os.path.join(memekit.ROOT, "src", "shared", "PortalMeshes.lua")
PREVIEW = os.path.join(memekit.OUT, "previews")


def B(p):
    """Roblox (x, y, z) -> Blender. The exporter writes Blender (x, y, z) as (x, z, -y)."""
    return Vector((p[0], -p[2], p[1]))


def ring_pt(r, a, z):
    return (r * math.cos(a), r * math.sin(a), z)


class Piece:
    """One mesh, built from lofted loops of Roblox-space points, each face painted a palette color."""

    def __init__(self, name, textured=True):
        self.name = name
        self.textured = textured
        self.bm = bmesh.new()
        self.uv = self.bm.loops.layers.uv.new("UVMap")
        self.lo = [1e9] * 3
        self.hi = [-1e9] * 3

    def _vert(self, p):
        for i in range(3):
            self.lo[i] = min(self.lo[i], p[i])
            self.hi[i] = max(self.hi[i], p[i])
        return self.bm.verts.new(B(p))

    def _face(self, vs, color, smooth):
        f = self.bm.faces.new(vs)
        uv = cell_uv(color)
        for loop in f.loops:
            loop[self.uv].uv = uv
        f.smooth = smooth
        return f

    def loft(self, loops, color, wrap=True, close=False, cap=True, smooth=True):
        """loops: lists of points with the same count. wrap = each loop is a closed ring;
        close = the last loop joins back to the first (a torus); cap = fill both open ends."""
        vs = [[self._vert(p) for p in loop] for loop in loops]
        n, m = len(vs[0]), len(vs)
        for i in range(m if close else m - 1):
            a, b = vs[i], vs[(i + 1) % m]
            for j in range(n if wrap else n - 1):
                k = (j + 1) % n
                self._face((a[j], a[k], b[k], b[j]), color, smooth)
        if cap and wrap and not close:
            self._face(vs[0][::-1], color, smooth)
            self._face(vs[-1], color, smooth)

    # --- shapes -------------------------------------------------------------------------
    def sector(self, a0, a1, ri, ro, z0, z1, color, ch=0.2, steps=6, cx=0.0, cy=0.0):
        """A bevelled block bent around the ring: angles a0..a1, radius ri..ro, depth z0..z1."""
        prof = [(ri + ch, z0), (ro - ch, z0), (ro, z0 + ch), (ro, z1 - ch),
                (ro - ch, z1), (ri + ch, z1), (ri, z1 - ch), (ri, z0 + ch)]
        loops = []
        for s in range(steps + 1):
            a = a0 + (a1 - a0) * s / steps
            loops.append([(cx + r * math.cos(a), cy + r * math.sin(a), z) for r, z in prof])
        self.loft(loops, color, smooth=False)

    def lathe(self, prof, color, steps=72, smooth=True):
        """Spins a closed (r, z) outline all the way around the z axis (rings, bands)."""
        loops = [[ring_pt(r, TAU * s / steps, z) for r, z in prof] for s in range(steps)]
        self.loft(loops, color, close=True, smooth=smooth)

    def box(self, c, ax, ay, az, color):
        """A box at c with half-extent vectors ax, ay, az."""
        c, ax, ay, az = Vector(c), Vector(ax), Vector(ay), Vector(az)
        corner = lambda i, j, k: tuple(c + ax * i + ay * j + az * k)  # noqa: E731
        loops = [[corner(-1, -1, k), corner(1, -1, k), corner(1, 1, k), corner(-1, 1, k)] for k in (-1, 1)]
        self.loft(loops, color, smooth=False)

    def ring_box(self, r, a, z, size, color):
        """A box sitting on the ring at radius r / angle a: size = (radial, along the ring, depth)."""
        out = Vector((math.cos(a), math.sin(a), 0))
        along = Vector((-math.sin(a), math.cos(a), 0))
        self.box(ring_pt(r, a, z), out * size[0] / 2, along * size[1] / 2, Vector((0, 0, size[2] / 2)), color)

    def cyl(self, c, axis, radius, length, color, seg=12):
        c, axis = Vector(c), Vector(axis).normalized()
        u = axis.cross(Vector((0, 0, 1)) if abs(axis.z) < 0.9 else Vector((1, 0, 0))).normalized()
        v = axis.cross(u)
        loops = [[tuple(c + axis * h + (u * math.cos(TAU * k / seg) + v * math.sin(TAU * k / seg)) * radius)
                  for k in range(seg)] for h in (-length / 2, length / 2)]
        self.loft(loops, color, smooth=False)

    def blob(self, c, radii, color, seg=16):
        """An ellipsoid (radii in x, y, z)."""
        loops = []
        for i in range(1, seg // 2):
            t = math.pi * i / (seg // 2)
            loops.append([(c[0] + radii[0] * math.sin(t) * math.cos(TAU * k / seg),
                           c[1] - radii[1] * math.cos(t),
                           c[2] + radii[2] * math.sin(t) * math.sin(TAU * k / seg)) for k in range(seg)])
        self.loft(loops, color)

    def tube(self, pts, radius, color, seg=10, ref=(0, 0, 1)):
        pts = [Vector(p) for p in pts]
        loops = []
        for i, p in enumerate(pts):
            d = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
            u = d.cross(Vector(ref))
            if u.length < 0.01:
                u = d.cross(Vector((1, 0, 0)))
            u.normalize()
            v = u.cross(d)
            r = radius(i / (len(pts) - 1)) if callable(radius) else radius
            loops.append([tuple(p + (u * math.cos(TAU * k / seg) + v * math.sin(TAU * k / seg)) * r) for k in range(seg)])
        self.loft(loops, color)

    def lathe_open(self, prof, color, steps=64, fx=1.0, fy=1.0, zfn=None):
        """Spins an OPEN (r, z) outline (from the middle out and back) into a dish; fx / fy squash it into
        an oval, zfn(r, angle, z) can ripple the depth. Both ends are tiny circles that get capped."""
        loops = []
        for r, z in prof:
            loop = []
            for s in range(steps):
                a = TAU * s / steps
                zz = zfn(r, a, z) if zfn else z
                loop.append((r * fx * math.cos(a), r * fy * math.sin(a), zz))
            loops.append(loop)
        self.loft(loops, color)

    # --- finishing ------------------------------------------------------------------------
    def finish(self, max_tris=14000):
        bmesh.ops.recalc_face_normals(self.bm, faces=self.bm.faces)
        me = bpy.data.meshes.new(self.name)
        self.bm.to_mesh(me)
        self.bm.free()
        obj = bpy.data.objects.new(self.name, me)
        bpy.context.scene.collection.objects.link(obj)
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        tris = sum(len(p.vertices) - 2 for p in me.polygons)
        if tris > max_tris:
            mod = obj.modifiers.new("Decimate", "DECIMATE")
            mod.ratio = max_tris / tris
            bpy.ops.object.modifier_apply(modifier=mod.name)
        mod = obj.modifiers.new("Tri", "TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=mod.name)
        me.materials.append(memekit.palette_material())
        obj["size"] = [self.hi[i] - self.lo[i] for i in range(3)]
        obj["center"] = [(self.hi[i] + self.lo[i]) / 2 for i in range(3)]
        obj["textured"] = self.textured
        return obj


def spiral_arms(piece, color, count, radius, twist, width, depth_at, thick=0.07, steps=44, fx=1.0, fy=1.0):
    """Spiral arms from the middle out to radius; depth_at(r) gives how far back (+z) they sit."""
    for k in range(count):
        base = TAU * k / count
        loops = []
        for i in range(steps + 1):
            t = 0.05 + 0.95 * i / steps
            r = radius * t
            a = base + twist * (1 - t) ** 1.3
            half = (width * math.sin(math.pi * t) ** 0.7 + 0.04) / 2
            da = half / max(r, 0.2)
            z = depth_at(r)
            e1 = (r * fx * math.cos(a - da), r * fy * math.sin(a - da))
            e2 = (r * fx * math.cos(a + da), r * fy * math.sin(a + da))
            loops.append([(e1[0], e1[1], z - thick / 2), (e2[0], e2[1], z - thick / 2),
                          (e2[0], e2[1], z + thick / 2), (e1[0], e1[1], z + thick / 2)])
        piece.loft(loops, color)


# ------------------------------------------------------------------------------------------
# World Gate (ring center at the origin; the floor is 9.5 below it)
# ------------------------------------------------------------------------------------------
RI, RO, HALF_D = 7.2, 9.0, 1.2
HORIZON_R = 6.95


def horizon_depth(r):
    """The event horizon dips back into the ring: z at the rim -0.55, in the middle +1.1."""
    s = min(r / HORIZON_R, 1)
    return -0.55 + 1.65 * (1 - s) ** 2


def gate_frame():
    p = Piece("GatePortalFrame")
    gap = 0.14 / ((RI + RO) / 2)
    for k in range(16):
        a0 = TAU * k / 16 + gap / 2
        p.sector(a0, a0 + TAU / 16 - gap, RI, RO, -HALF_D, HALF_D, "gunmetal", ch=0.24)
    # steel inner band and brass trim rings front and back
    p.lathe([(6.85, -1.0), (7.3, -1.0), (7.3, 1.0), (6.85, 1.0), (6.75, 0.9), (6.75, -0.9)], "steel", steps=96)
    for z0 in (-1.45, 1.15):
        p.lathe([(8.72, z0), (9.22, z0), (9.3, z0 + 0.15), (9.22, z0 + 0.3), (8.72, z0 + 0.3), (8.64, z0 + 0.15)], "brass", steps=96)
    # bolts: two per segment on the front face
    for k in range(16):
        a = TAU * (k + 0.5) / 16
        for r in (7.62, 8.5):
            p.cyl(ring_pt(r, a, -HALF_D - 0.06), (0, 0, 1), 0.13, 0.2, "steel", seg=6)
    # emitter housings on the front and fins on the inner edge
    for k in range(8):
        a = TAU * (k + 0.5) / 8
        p.ring_box(8.05, a, -HALF_D - 0.22, (1.3, 0.95, 0.5), "steel")
        p.ring_box(8.05, a, -HALF_D - 0.5, (0.9, 0.6, 0.12), "gunmetal")
        p.ring_box(6.72, a, 0, (0.55, 0.7, 1.6), "steel")
    # brass conduits running over the top of the ring, held by clamps
    for z in (-0.55, 0.55):
        pts = [ring_pt(9.38, math.radians(-38 + 256 * i / 70), z) for i in range(71)]
        p.tube(pts, 0.19, "brass", seg=10)
    for i in range(14):
        a = math.radians(-30 + 240 * i / 13)
        p.ring_box(9.3, a, 0, (0.55, 0.32, 1.75), "gunmetal")
    for a in (math.radians(-40), math.radians(220)):
        p.ring_box(9.45, a, 0, (1.1, 1.0, 1.9), "gunmetal")
    # the cradle it stands in, a plinth and two buttresses
    p.sector(math.radians(246), math.radians(294), 8.7, 9.55, -1.7, 1.7, "gunmetal", ch=0.25, steps=8)
    p.box((0, -9.0, 0), (4.9, 0, 0), (0, 0.5, 0), (0, 0, 1.95), "gunmetal")
    p.box((0, -8.72, -1.97), (4.6, 0, 0), (0, 0.11, 0), (0, 0, 0.04), "brass")
    for s in (-1, 1):
        p.box((s * 5.7, -8.0, 0), (0.85, 0, 0), (0, 1.25, 0), (0, 0, 1.5), "gunmetal")
        p.box((s * 5.7, -6.82, 0), (0.95, 0, 0), (0, 0.08, 0), (0, 0, 1.6), "brass")
    return p.finish()


def gate_glow():
    p = Piece("GatePortalGlow", textured=False)
    for z in (-1.05, 1.05):
        p.lathe([(6.92 + 0.09 * math.cos(TAU * i / 6), z + 0.09 * math.sin(TAU * i / 6)) for i in range(6)], "glow", steps=96)
    gap = TAU / 16
    for k in range(16):
        p.ring_box(8.1, gap * k, -HALF_D - 0.03, (1.3, 0.1, 0.1), "glow")
    for k in range(8):
        a = TAU * (k + 0.5) / 8
        x, y, _ = ring_pt(8.05, a, 0)
        p.blob((x, y, -HALF_D - 0.6), (0.3, 0.3, 0.14), "glow", seg=12)
        x, y, _ = ring_pt(6.42, a, 0)
        p.blob((x, y, 0), (0.18, 0.18, 0.6), "glow", seg=10)
    return p.finish()


def gate_horizon():
    p = Piece("GateHorizon", textured=False)
    n = 24
    front = [(HORIZON_R * (0.02 + 0.98 * i / n), None) for i in range(n + 1)]
    prof = [(r, horizon_depth(r)) for r, _ in front] + [(r, horizon_depth(r) + 0.08) for r, _ in reversed(front)]
    p.lathe_open(prof, "glow", steps=72)
    return p.finish()


def gate_vortex(name, count, twist, width, lift, radius):
    p = Piece(name, textured=False)
    spiral_arms(p, "glow", count, radius, twist, width, lambda r: horizon_depth(r) - lift)
    return p.finish()


# ------------------------------------------------------------------------------------------
# Alien portal (oval center at the origin, 4.75 + 0.3 above the ground)
# ------------------------------------------------------------------------------------------
AX, AY = 2.95, 4.3   # rim oval half-width / half-height
FX, FY = 2.8, 4.15   # funnel oval


def funnel_depth(s):
    return -0.25 + 1.6 * (1 - min(s, 1)) ** 1.6


def alien_rim():
    p = Piece("AlienPortalRim", textured=False)
    loops = []
    for i in range(110):
        a = TAU * i / 110
        pos = Vector((AX * math.cos(a), AY * math.sin(a), 0))
        n = Vector((math.cos(a) / AX, math.sin(a) / AY, 0)).normalized()
        m = 0.46 + 0.09 * math.sin(5 * a + 1) + 0.05 * math.sin(11 * a + 2) + 0.035 * math.sin(19 * a)
        loop = []
        for j in range(14):
            b = TAU * j / 14
            k = m * (1 + 0.07 * math.sin(3 * b + 4 * a))
            loop.append(tuple(pos + (n * math.cos(b) + Vector((0, 0, 1)) * math.sin(b)) * k))
        loops.append(loop)
    p.loft(loops, "glow", close=True)
    # goo drips hanging off the lower half, and a few bulges
    for deg, length, r0 in [(200, 0.9, 0.24), (222, 1.5, 0.3), (246, 0.7, 0.22), (262, 1.9, 0.32), (281, 1.1, 0.26),
                            (304, 1.6, 0.28), (333, 0.8, 0.22)]:
        a = math.radians(deg)
        x, y = AX * math.cos(a) * 1.06, AY * math.sin(a) * 1.04
        prof = [(0, 0.5), (0.25, 0.55), (0.5, 0.66), (0.7, 0.88), (0.82, 1.0), (0.9, 0.95), (0.96, 0.7), (1.0, 0.2)]
        loops = [[(x + r0 * f * math.cos(TAU * k / 10), y + 0.15 - s * length, r0 * f * math.sin(TAU * k / 10) - 0.05)
                  for k in range(10)] for s, f in prof]
        p.loft(loops, "glow")
    for deg, size in [(20, 0.42), (75, 0.36), (130, 0.45), (165, 0.34), (350, 0.38)]:
        a = math.radians(deg)
        n = Vector((math.cos(a) / AX, math.sin(a) / AY, 0)).normalized()
        c = Vector((AX * math.cos(a), AY * math.sin(a), 0)) + n * 0.28
        p.blob(tuple(c), (size, size * 1.1, size * 0.9), "glow", seg=12)
    return p.finish()


def alien_funnel():
    p = Piece("AlienPortalFunnel", textured=False)
    n = 26
    ss = [0.03 + 0.97 * i / n for i in range(n + 1)]
    ripple = lambda r, a, z: z + 0.1 * math.sin(5 * a - 9 * r) * r if z < 1.4 else z  # noqa: E731  (r = the 0-1 fraction)
    # concave front (the tunnel), flat back so it doesn't poke out behind the rim
    prof = [(s, funnel_depth(s)) for s in ss] + [(s, 1.48) for s in reversed(ss)]
    p.lathe_open(prof, "glow", steps=80, fx=FX, fy=FY, zfn=ripple)
    return p.finish()


def alien_swirl():
    p = Piece("AlienPortalSwirl", textured=False)
    spiral_arms(p, "glow", 4, 2.7, 3.6, 0.55, lambda r: funnel_depth(r / FX) - 0.2, thick=0.06)
    return p.finish()


GATE = [gate_frame, gate_glow, gate_horizon,
        lambda: gate_vortex("GateVortexA", 5, 3.4, 0.75, 0.1, HORIZON_R - 0.1),
        lambda: gate_vortex("GateVortexB", 3, -2.2, 1.25, 0.22, HORIZON_R - 0.4)]
ALIEN = [alien_rim, alien_funnel, alien_swirl]

# preview colors for the glowing pieces (the game sets its own colors and materials)
PREVIEW_GLOW = {
    "GatePortalGlow": (0.55, 0.95, 1.0, 6), "GateHorizon": (0.25, 0.12, 0.6, 1.5),
    "GateVortexA": (0.55, 0.85, 1.0, 4), "GateVortexB": (0.75, 0.55, 1.0, 3),
    "AlienPortalRim": (0.35, 0.9, 0.1, 0.6), "AlienPortalFunnel": (0.05, 0.35, 0.05, 0.5), "AlienPortalSwirl": (0.7, 1.0, 0.5, 1.2),
}


def glow_material(name, rgba):
    mat = bpy.data.materials.new(name + "Glow")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*rgba[:3], 1)
    bsdf.inputs["Emission Color"].default_value = (*rgba[:3], 1)
    bsdf.inputs["Emission Strength"].default_value = rgba[3]
    return mat


def export_fbx(objs, path):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="COPY", embed_textures=True,
                             bake_space_transform=True)


def write_lua(info):
    lines = [
        "-- PortalMeshes (ModuleScript in ReplicatedStorage)",
        "-- Written by tools/blender/portals.py: the Blender portal pieces (World Gate and alien portal).",
        "-- Studio's File > Import 3D of assets/models/PortalMeshes.fbx + the installer put them in",
        "-- ReplicatedStorage > PortalModels. Data = each piece's size and where its center sits from",
        "-- the portal's center (front = -Z). Until they're imported the portals use their old parts.",
        "",
        'local ReplicatedStorage = game:GetService("ReplicatedStorage")',
        "",
        "local PortalMeshes = {}",
        "",
        "PortalMeshes.Data = {",
    ]
    for name, (size, center, textured) in info.items():
        lines.append("\t%s = {Size = Vector3.new(%.3f, %.3f, %.3f), Center = Vector3.new(%.3f, %.3f, %.3f), Textured = %s}," % (
            name, *size, *center, "true" if textured else "false"))
    lines += [
        "}",
        "",
        "local function source(name)",
        '\tlocal folder = ReplicatedStorage:FindFirstChild("PortalModels")',
        "\tlocal item = folder and folder:FindFirstChild(name)",
        '\tif item and not item:IsA("MeshPart") then item = item:FindFirstChildWhichIsA("MeshPart", true) end',
        "\treturn item",
        "end",
        "",
        "-- true when every named piece has been imported",
        "function PortalMeshes.has(...)",
        "\tfor _, name in ipairs({...}) do",
        "\t\tif not PortalMeshes.Data[name] or not source(name) then return false end",
        "\tend",
        "\treturn true",
        "end",
        "",
        "-- a copy of the piece placed around the portal center (a CFrame); props = Color, Material, ...",
        "-- scale shrinks it (and its offset) for pop-open animations",
        "function PortalMeshes.place(parent, name, center, props, scale)",
        "\tlocal data, src = PortalMeshes.Data[name], source(name)",
        "\tif not data or not src then return nil end",
        "\tscale = scale or 1",
        "\tlocal part = src:Clone()",
        "\tpart.Name = name",
        "\tfor _, child in ipairs(part:GetChildren()) do",
        '\t\tif not data.Textured and child:IsA("SurfaceAppearance") then child:Destroy() end',
        "\tend",
        '\tif not data.Textured then pcall(function() part.TextureID = "" end) end',
        "\tpart.Anchored = true",
        "\tpart.CanCollide = false",
        "\tpart.CanQuery = false",
        "\tpart.CanTouch = false",
        "\tpart.CastShadow = data.Textured",
        "\tpart.Size = data.Size * scale",
        "\tpart.CFrame = center * CFrame.new(data.Center * scale)",
        "\tfor key, value in pairs(props or {}) do part[key] = value end",
        "\tif not data.Textured then part:SetAttribute(\"KeepGlow\", true) end -- Architecture.calm leaves it glowing",
        "\tpart.Parent = parent",
        "\treturn part",
        "end",
        "",
        "return PortalMeshes",
    ]
    with open(LUA_OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main():
    os.makedirs(PREVIEW, exist_ok=True)
    info = {}
    everything = []
    for group, title in ((GATE, "WorldGatePortal"), (ALIEN, "AlienPortal")):
        memekit.reset()
        objs = [build() for build in group]
        for o in objs:
            info[o.name] = (list(o["size"]), list(o["center"]), bool(o["textured"]))
            tris = len(o.data.polygons)
            print("built", o.name, tris, "tris")
            export_fbx([o], os.path.join(memekit.OUT, o.name + ".fbx"))
            if o.name in PREVIEW_GLOW:
                o.data.materials.clear()
                o.data.materials.append(glow_material(o.name, PREVIEW_GLOW[o.name]))
        memekit.render(objs, os.path.join(PREVIEW, title + ".png"), size=(640, 640), angle=200)
        memekit.render(objs, os.path.join(PREVIEW, title + "_side.png"), size=(640, 640), angle=245)
        everything.append(group)
    # one combined file for a single Import 3D in Studio
    memekit.reset()
    objs = []
    for group in everything:
        for build in group:
            o = build()
            o.location.x = len(objs) * 24
            objs.append(o)
    export_fbx(objs, os.path.join(memekit.OUT, "PortalMeshes.fbx"))
    print("wrote PortalMeshes.fbx with", len(objs), "pieces")
    write_lua(info)
    print("wrote", os.path.relpath(LUA_OUT, memekit.ROOT))


main()
