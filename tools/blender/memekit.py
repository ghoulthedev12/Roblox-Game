"""memekit: a small modeling kit for building the meme sculptures in Blender (run with bpy).

Every meme is built from shaped primitives (smooth blobs, rounded boxes, cylinders, cones,
tori), each painted one flat color. At the end everything is joined into ONE mesh whose
colors come from a shared palette texture (assets/models/meme_palette.png): every color
is a 32x32 cell, and each part's UVs point at the middle of its cell. One mesh + one
texture = one Roblox MeshPart, which keeps imports simple and draw calls low.

Units: 1 Blender unit = 1 stud. Models stand on z = 0, centered, facing -Y (Blender's
front), which the exporter turns into Roblox's -Z front.
"""
import math
import os

import bmesh
import bpy
from mathutils import Euler, Matrix, Vector

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "assets", "models")
PALETTE_PNG = os.path.join(OUT, "meme_palette.png")
CELL, GRID = 32, 16  # 16 x 16 cells of 32 px = a 512 x 512 palette

# The palette: name -> (r, g, b) 0-255. New colors are added at the end so old models
# keep their UVs.
PALETTE = {}


def rgb(name, r, g, b):
    PALETTE[name] = (r, g, b)
    return name


for _name, _c in [
    ("white", (245, 245, 245)), ("black", (24, 22, 26)), ("ink", (50, 44, 56)), ("gray", (150, 152, 158)),
    ("darkgray", (90, 92, 98)), ("lightgray", (210, 212, 216)), ("red", (210, 40, 46)), ("darkred", (120, 24, 30)),
    ("pink", (255, 160, 190)), ("hotpink", (255, 90, 160)), ("orange", (255, 140, 40)), ("yellow", (250, 214, 48)),
    ("cream", (245, 232, 205)), ("tan", (214, 160, 100)), ("brown", (140, 90, 50)), ("darkbrown", (80, 50, 30)),
    ("wood", (170, 120, 70)), ("lightwood", (215, 170, 115)), ("green", (80, 170, 80)), ("darkgreen", (40, 100, 50)),
    ("lime", (170, 230, 60)), ("pistachio", (150, 200, 90)), ("blue", (50, 110, 220)), ("navy", (30, 40, 90)),
    ("sky", (120, 190, 240)), ("purple", (130, 70, 190)), ("lilac", (190, 160, 240)), ("gold", (225, 180, 70)),
    ("skin", (236, 196, 160)), ("skin2", (200, 150, 110)), ("jeans", (72, 104, 156)), ("sweater", (150, 152, 158)),
    ("chocolate", (90, 50, 30)), ("milkchoc", (130, 80, 45)), ("hippo", (130, 110, 115)), ("hippopink", (235, 150, 150)),
    ("shark", (110, 140, 170)), ("coffee", (150, 100, 60)), ("foam", (240, 225, 200)), ("teeth", (250, 248, 235)),
    ("redbrown", (160, 70, 50)), ("orangutan", (205, 110, 45)), ("macaque", (175, 145, 115)), ("macaqueface", (230, 165, 150)),
    # batch 2 (new colors only ever go at the end, so earlier models keep their UVs)
    ("visor", (150, 210, 235)), ("gorilla", (48, 45, 52)), ("silverback", (125, 125, 132)), ("gorillaface", (85, 78, 80)),
    ("raccoon", (125, 120, 118)), ("raccoondark", (50, 46, 48)), ("mememan", (215, 220, 235)), ("crocgreen", (70, 135, 65)),
    ("zombie", (95, 165, 95)), ("zombieshirt", (40, 170, 190)), ("chicken", (248, 248, 242)), ("beak", (245, 160, 40)),
    ("cowpink", (245, 170, 175)), ("pillyellow", (255, 215, 50)), ("rock", (120, 112, 104)), ("turntable", (35, 35, 40)),
    # batch 3
    ("ice", (200, 235, 250)), ("mint", (150, 230, 190)), ("waffle", (215, 160, 90)), ("corn", (250, 205, 60)),
    ("husk", (140, 175, 80)), ("smurf", (70, 140, 230)), ("khaki", (190, 170, 130)), ("dreampink", (255, 130, 190)),
    ("smoke", (170, 165, 160)), ("fire", (255, 120, 40)), ("mitten", (150, 95, 70)), ("envelope", (225, 195, 130)),
]:
    rgb(_name, *_c)


def cell_uv(name):
    i = list(PALETTE).index(name)
    cx, cy = i % GRID, i // GRID
    return ((cx + 0.5) / GRID, 1 - (cy + 0.5) / GRID)


def write_palette():
    """Writes the palette PNG (Blender's own image API, no extra libraries)."""
    size = CELL * GRID
    img = bpy.data.images.new("meme_palette", size, size, alpha=False)
    px = [0.0] * (size * size * 4)
    for i, name in enumerate(PALETTE):
        r, g, b = [c / 255 for c in PALETTE[name]]
        # Blender images store linear values; convert so the PNG holds the exact sRGB color
        lin = [((c + 0.055) / 1.055) ** 2.4 if c > 0.04045 else c / 12.92 for c in (r, g, b)]
        cx, cy = i % GRID, i // GRID
        for y in range(CELL):
            row = (size - 1 - (cy * CELL + y)) * size
            for x in range(CELL):
                k = (row + cx * CELL + x) * 4
                px[k:k + 4] = [*lin, 1.0]
    img.pixels = px
    img.filepath_raw = PALETTE_PNG
    img.file_format = "PNG"
    img.save()
    return img


# ------------------------------------------------------------------------------------------
# Building
# ------------------------------------------------------------------------------------------
class Meme:
    """Collects parts for one meme; finish() joins them into a single textured mesh."""

    def __init__(self, name):
        self.name = name
        self.parts = []

    def _add(self, obj, color, smooth=True):
        me = obj.data
        if not me.uv_layers:
            me.uv_layers.new(name="UVMap")
        u, v = cell_uv(color)
        for loop in me.uv_layers.active.data:
            loop.uv = (u, v)
        for poly in me.polygons:
            poly.use_smooth = smooth
        self.parts.append(obj)
        return obj

    def _place(self, obj, loc, rot, scale):
        obj.location = loc
        obj.rotation_euler = Euler([math.radians(a) for a in rot])
        obj.scale = scale
        bpy.context.view_layer.update()
        obj.data.transform(obj.matrix_world)
        obj.matrix_world = Matrix.Identity(4)

    # --- primitives ---------------------------------------------------------------------
    def blob(self, color, size, loc=(0, 0, 0), rot=(0, 0, 0), seg=24):
        """Smooth ellipsoid. size = full width/depth/height (x, y, z)."""
        bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=max(8, seg // 2), radius=0.5)
        o = bpy.context.object
        self._place(o, loc, rot, size)
        return self._add(o, color)

    def squircle(self, color, size, loc=(0, 0, 0), rot=(0, 0, 0), power=4.0, seg=32):
        """A smooth rounded box (superellipsoid): power 2 = ellipsoid, higher = squarer.
        Good for sculpted forms with flat-ish sides: jaws, heads, bodies, cushions."""
        bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=seg // 2, radius=1)
        o = bpy.context.object
        for v in o.data.vertices:
            c = v.co
            k = (abs(c.x) ** power + abs(c.y) ** power + abs(c.z) ** power) ** (1 / power)
            if k > 0:
                v.co = c / k * 0.5
        self._place(o, loc, rot, size)
        return self._add(o, color)

    def box(self, color, size, loc=(0, 0, 0), rot=(0, 0, 0), bevel=0.06):
        """Box with rounded edges. size = full x, y, z."""
        bpy.ops.mesh.primitive_cube_add(size=1)
        o = bpy.context.object
        self._place(o, loc, rot, size)
        if bevel > 0:
            bm = bmesh.new()
            bm.from_mesh(o.data)
            bmesh.ops.bevel(bm, geom=bm.edges[:] + bm.verts[:], offset=min(bevel, min(size) * 0.45), segments=3, affect="EDGES")
            bm.to_mesh(o.data)
            bm.free()
        self._add(o, color, smooth=True)
        o.data.shade_auto_smooth(angle=math.radians(40)) if hasattr(o.data, "shade_auto_smooth") else None
        return o

    def cyl(self, color, radius, depth, loc=(0, 0, 0), rot=(0, 0, 0), seg=28, radius2=None, scale=(1, 1, 1)):
        """Cylinder (or cone/frustum when radius2 is given) along local Z."""
        if radius2 is None:
            bpy.ops.mesh.primitive_cylinder_add(vertices=seg, radius=radius, depth=depth)
        else:
            bpy.ops.mesh.primitive_cone_add(vertices=seg, radius1=radius, radius2=radius2, depth=depth)
        o = bpy.context.object
        self._place(o, loc, rot, scale)
        return self._add(o, color, smooth=True)

    def torus(self, color, major, minor, loc=(0, 0, 0), rot=(0, 0, 0), scale=(1, 1, 1)):
        bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=32, minor_segments=12)
        o = bpy.context.object
        self._place(o, loc, rot, scale)
        return self._add(o, color)

    def tube(self, color, points, radius, seg=10):
        """A smooth tube through a list of 3D points (arms, tails, straws, hair strands)."""
        bm = bmesh.new()
        pts = [Vector(p) for p in points]
        rings = []
        for i, p in enumerate(pts):
            d = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
            side = d.cross(Vector((0, 0, 1)))
            if side.length < 0.01:
                side = d.cross(Vector((1, 0, 0)))
            side.normalize()
            up = side.cross(d).normalized()
            r = radius(i / max(1, len(pts) - 1)) if callable(radius) else radius
            ring = [bm.verts.new(p + (side * math.cos(a) + up * math.sin(a)) * r)
                    for a in [2 * math.pi * k / seg for k in range(seg)]]
            rings.append(ring)
        for a, b in zip(rings, rings[1:]):
            for k in range(seg):
                bm.faces.new((a[k], a[(k + 1) % seg], b[(k + 1) % seg], b[k]))
        bm.faces.new(list(reversed(rings[0])))
        bm.faces.new(rings[-1])
        me = bpy.data.meshes.new("tube")
        bm.to_mesh(me)
        bm.free()
        o = bpy.data.objects.new("tube", me)
        bpy.context.scene.collection.objects.link(o)
        return self._add(o, color)

    # --- finishing ------------------------------------------------------------------------
    def finish(self, max_tris=9000):
        bpy.ops.object.select_all(action="DESELECT")
        for o in self.parts:
            o.select_set(True)
        bpy.context.view_layer.objects.active = self.parts[0]
        bpy.ops.object.join()
        obj = bpy.context.object
        obj.name = self.name
        obj.data.name = self.name
        me = obj.data
        # stand it on z = 0, centered on x/y
        xs = [v.co.x for v in me.vertices]
        ys = [v.co.y for v in me.vertices]
        zs = [v.co.z for v in me.vertices]
        me.transform(Matrix.Translation((-(min(xs) + max(xs)) / 2, -(min(ys) + max(ys)) / 2, -min(zs))))
        # keep the triangle count Roblox-friendly
        tris = sum(len(p.vertices) - 2 for p in me.polygons)
        if tris > max_tris:
            mod = obj.modifiers.new("Decimate", "DECIMATE")
            mod.ratio = max_tris / tris
            bpy.ops.object.modifier_apply(modifier=mod.name)
        mod = obj.modifiers.new("Tri", "TRIANGULATE")
        bpy.ops.object.modifier_apply(modifier=mod.name)
        obj.data.materials.clear()
        obj.data.materials.append(palette_material())
        return obj


_material = None


def palette_material():
    global _material
    if _material and _material.name in bpy.data.materials:
        return _material
    img = bpy.data.images.get("meme_palette") or write_palette()
    mat = bpy.data.materials.new("MemePalette")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Closest"
    bsdf = nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = 0.6
    mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    _material = mat
    return mat


def reset():
    global _material
    bpy.ops.wm.read_factory_settings(use_empty=True)
    _material = None
    write_palette()


def export(obj, name):
    os.makedirs(OUT, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    path = os.path.join(OUT, name + ".fbx")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="COPY", embed_textures=True,
                             bake_space_transform=True)
    return path


def render(objs, path, size=(512, 512), angle=25):
    """A quick preview render: three-quarter front view with soft lighting."""
    scene = bpy.context.scene
    for o in objs:
        o.hide_render = False
    xs, ys, zs = [], [], []
    for o in objs:
        for v in o.data.vertices:
            w = o.matrix_world @ v.co
            xs.append(w.x); ys.append(w.y); zs.append(w.z)
    center = Vector(((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2, (min(zs) + max(zs)) / 2))
    extent = max(max(xs) - min(xs), max(zs) - min(zs), max(ys) - min(ys))
    cam = bpy.data.objects.get("PreviewCam")
    if not cam:
        cam = bpy.data.objects.new("PreviewCam", bpy.data.cameras.new("PreviewCam"))
        scene.collection.objects.link(cam)
        for i, (rot, energy) in enumerate([((50, 0, 35), 3.5), ((60, 0, -120), 1.2)]):
            sun = bpy.data.objects.new("Sun%d" % i, bpy.data.lights.new("Sun%d" % i, "SUN"))
            sun.data.energy = energy
            sun.rotation_euler = Euler([math.radians(a) for a in rot])
            scene.collection.objects.link(sun)
        world = bpy.data.worlds.new("W")
        world.use_nodes = True
        world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.75, 0.82, 0.92, 1)
        world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.8
        scene.world = world
    a = math.radians(angle)
    dist = extent * 2.2 + 1
    cam.location = center + Vector((math.sin(a) * dist, -math.cos(a) * dist, extent * 0.35))
    cam.rotation_euler = (center - cam.location).to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = 50
    scene.camera = cam
    scene.render.engine = "CYCLES"  # CPU path tracer: works on machines without a GPU
    scene.cycles.device = "CPU"
    scene.cycles.samples = 24
    scene.cycles.use_denoising = False
    scene.render.resolution_x, scene.render.resolution_y = size
    scene.render.filepath = path
    scene.view_settings.view_transform = "Standard"
    bpy.ops.render.render(write_still=True)
