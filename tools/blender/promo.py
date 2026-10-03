"""Renders the game's store pictures for the Roblox page: the experience icon and the
thumbnails, staged with the real game models (memes from the meme batches, pets from
pets.py, the Relic Pickaxe from pickaxes.py) plus a blocky avatar, a dig pit and a 2050
skyline, in the same cartoon style with thick outlines.

Writes assets/promo/Icon.png (512 x 512) and assets/promo/Thumbnail_<Name>.png (1920 x 1080).
Run:  blender -b --factory-startup --python tools/blender/promo.py -- [Icon] [Dig] [Pets] [Museum]
Coordinates: z is up, models face -y (Blender's front), the camera looks from -y.
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402
from mathutils import Euler, Matrix, Vector  # noqa: E402

import memekit  # noqa: E402
import memes_batch1  # noqa: E402,F401  (the batches share and append palette colors, in order)
import memes_batch2  # noqa: E402,F401
import importlib  # noqa: E402

_here = os.path.dirname(os.path.abspath(__file__))
for _k in range(3, 100):
    if os.path.exists(os.path.join(_here, "memes_batch%d.py" % _k)):
        importlib.import_module("memes_batch%d" % _k)
import pickaxes  # noqa: E402
import pets  # noqa: E402  (last: its colors win where names are shared)

R = math.radians
OUT = os.path.join(memekit.ROOT, "assets", "promo")
FONT = "C:/Windows/Fonts/seguibl.ttf"


def rgb(r, g, b):
    def lin(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return (lin(r), lin(g), lin(b), 1)


# ------------------------------------------------------------------------------------------
# scene
# ------------------------------------------------------------------------------------------
def collection(name):
    c = bpy.data.collections.get(name)
    if not c:
        c = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(c)
    return c


def put(o, coll="Main"):
    for c in list(o.users_collection):
        c.objects.unlink(o)
    collection(coll).objects.link(o)
    return o


def setup(width, height, samples=64):
    # a clean scene (not memekit.reset(): reloading the empty factory file loses the outlines)
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    for block in (bpy.data.meshes, bpy.data.materials, bpy.data.lights, bpy.data.cameras, bpy.data.curves, bpy.data.images):
        for item in list(block):
            if item.users == 0:
                block.remove(item)
    memekit._material = None
    memekit.write_palette()  # the palette with every color (memes, pickaxes, pets)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    try:
        prefs = bpy.context.preferences.addons["cycles"].preferences
        for kind in ("OPTIX", "CUDA"):
            try:
                prefs.compute_device_type = kind
                prefs.get_devices()
                if any(d.type == kind for d in prefs.devices):
                    for d in prefs.devices:
                        d.use = True
                    scene.cycles.device = "GPU"
                    break
            except TypeError:
                continue
    except Exception:
        pass
    scene.cycles.samples = samples
    scene.cycles.use_denoising = True
    scene.render.resolution_x = width
    scene.render.resolution_y = height
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    # outlines: thick around the title, medium around the models; the ground and sky get none
    scene.render.use_freestyle = True
    scene.render.line_thickness_mode = "ABSOLUTE"
    layer = bpy.context.view_layer
    layer.use_freestyle = True
    fs = layer.freestyle_settings
    while fs.linesets:
        fs.linesets.remove(fs.linesets[0])
    scale = max(0.85, max(width, height) / 1920)
    for name, thickness in (("Main", 7.5), ("Title", 15), ("Detail", 4)):
        lineset = fs.linesets.new(name)
        lineset.select_by_visibility = True
        lineset.select_by_edge_types = True
        lineset.select_by_collection = True
        lineset.collection = collection(name)
        for attr in ("select_silhouette", "select_border", "select_external_contour"):
            setattr(lineset, attr, True)
        for attr in ("select_crease", "select_material_boundary", "select_contour", "select_suggestive_contour",
                     "select_ridge_valley", "select_edge_mark"):
            if hasattr(lineset, attr):
                setattr(lineset, attr, False)
        style = lineset.linestyle
        style.color = (0.03, 0.02, 0.07)
        style.thickness = max(1.5, thickness * scale)
        style.thickness_position = "CENTER"
    collection("Ground")


def sky(bottom, top, strength=1.0):
    """A screen-space vertical gradient for the background (and soft ambient light)."""
    world = bpy.data.worlds.new("Sky")
    bpy.context.scene.world = world
    world.use_nodes = True
    nt = world.node_tree
    nodes, links = nt.nodes, nt.links
    bg = next(n for n in nodes if n.type == "BACKGROUND")
    coord = nodes.new("ShaderNodeTexCoord")
    sep = nodes.new("ShaderNodeSeparateXYZ")
    ramp = nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = rgb(*bottom)
    ramp.color_ramp.elements[1].color = rgb(*top)
    links.new(coord.outputs["Window"], sep.inputs[0])
    links.new(sep.outputs["Y"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bg.inputs["Color"])
    bg.inputs["Strength"].default_value = strength


def light(kind, name, loc, energy, rot=None, size=1.0, color=(1, 1, 1)):
    data = bpy.data.lights.new(name, kind)
    data.energy = energy
    data.color = color
    if kind == "AREA":
        data.size = size
    if kind == "SUN":
        data.angle = R(8)
    o = bpy.data.objects.new(name, data)
    bpy.context.scene.collection.objects.link(o)
    o.location = loc
    if rot:
        o.rotation_euler = Euler([R(a) for a in rot])
    else:
        o.rotation_euler = (-Vector(loc)).to_track_quat("-Z", "Y").to_euler()
    return o


class Cam:
    def __init__(self, loc, target, lens=40):
        data = bpy.data.cameras.new("Cam")
        data.lens = lens
        self.obj = bpy.data.objects.new("Cam", data)
        bpy.context.scene.collection.objects.link(self.obj)
        self.obj.location = loc
        d = Vector(target) - Vector(loc)
        self.obj.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
        bpy.context.scene.camera = self.obj
        bpy.context.view_layer.update()

    def at(self, x, y, dist):
        """A point x right, y up (in units at that distance) in front of the camera."""
        m = self.obj.matrix_world
        right = m.to_3x3() @ Vector((1, 0, 0))
        up = m.to_3x3() @ Vector((0, 1, 0))
        fwd = m.to_3x3() @ Vector((0, 0, -1))
        return m.translation + fwd * dist + right * x + up * y

    def facing(self):
        return self.obj.rotation_euler.copy()


def mat(name, color, rough=0.35, emission=0.0, metal=0.0, coat=0.3):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = rgb(*color)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    for key in ("Coat Weight", "Clearcoat"):
        if key in bsdf.inputs:
            bsdf.inputs[key].default_value = coat
            break
    if emission:
        for key in ("Emission Color", "Emission"):
            if key in bsdf.inputs:
                bsdf.inputs[key].default_value = rgb(*color)
                break
        bsdf.inputs["Emission Strength"].default_value = emission
    return m


def shade(o, material, smooth=True, bevel=0.0):
    o.data.materials.clear()
    o.data.materials.append(material)
    if smooth:
        for p in o.data.polygons:
            p.use_smooth = True
    if bevel:
        mod = o.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 4
        mod.limit_method = "ANGLE"
    return o


def box(name, size, material, loc=(0, 0, 0), rot=(0, 0, 0), bevel=0.12, coll="Main", pivot=(0, 0, 0)):
    """A rounded box; pivot = where its origin sits, as a fraction of its size from the center."""
    bpy.ops.mesh.primitive_cube_add(size=1)
    o = bpy.context.active_object
    o.name = name
    o.data.transform(Matrix.Diagonal((*size, 1)) @ Matrix.Translation(Vector(pivot) * -1))
    o.location = loc
    o.rotation_euler = Euler([R(a) for a in rot])
    put(o, coll)
    return shade(o, material, smooth=False, bevel=min(bevel, min(size) * 0.45))


def cyl(name, radius, depth, material, loc=(0, 0, 0), rot=(0, 0, 0), coll="Main", verts=64, bevel=0.0):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=[R(a) for a in rot])
    o = bpy.context.active_object
    o.name = name
    put(o, coll)
    return shade(o, material, bevel=bevel)


def ball(name, radius, material, loc=(0, 0, 0), scale=(1, 1, 1), coll="Main"):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=radius, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = scale
    put(o, coll)
    return shade(o, material)


def ring(name, major, minor, material, loc=(0, 0, 0), rot=(0, 0, 0), coll="Main"):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, location=loc, rotation=[R(a) for a in rot],
                                     major_segments=64, minor_segments=16)
    o = bpy.context.active_object
    o.name = name
    put(o, coll)
    return shade(o, material)


def text(body, size, material, loc, rot, extrude=0.25, coll="Title"):
    curve = bpy.data.curves.new("Text", "FONT")
    curve.body = body
    curve.size = size
    curve.extrude = extrude
    curve.align_x = "CENTER"
    curve.align_y = "CENTER"
    if os.path.exists(FONT):
        curve.font = bpy.data.fonts.load(FONT, check_existing=True)
    o = bpy.data.objects.new("Text", curve)
    bpy.context.scene.collection.objects.link(o)
    o.location = loc
    o.rotation_euler = rot
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = o
    o.select_set(True)
    bpy.ops.object.convert(target="MESH")
    o = bpy.context.active_object
    put(o, coll)
    return shade(o, material)


def star_shape(name, size, material, loc, rot, coll="Detail"):
    pts = []
    for i in range(8):
        a = R(90 + i * 45)
        r = size if i % 2 == 0 else size * 0.3
        pts.append((math.cos(a) * r, math.sin(a) * r))
    import bmesh
    bm = bmesh.new()
    front = [bm.verts.new((x, z, 0.04)) for x, z in pts]
    back = [bm.verts.new((x, z, -0.04)) for x, z in pts]
    bm.faces.new(front)
    bm.faces.new(back[::-1])
    for i in range(8):
        j = (i + 1) % 8
        bm.faces.new((front[i], front[j], back[j], back[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    o = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(o)
    o.location = loc
    o.rotation_euler = rot
    put(o, coll)
    return shade(o, material, smooth=False)


# ------------------------------------------------------------------------------------------
# props
# ------------------------------------------------------------------------------------------
_memes = {}


def meme(fn, loc, turn=0.0, scale=1.0, tilt=(0, 0)):
    """A game model (a builder from the meme batches or pets.py), placed and turned."""
    o = fn().finish(max_tris=20000)
    put(o)
    o.location = loc
    o.rotation_euler = (R(tilt[0]), R(tilt[1]), R(turn))
    o.scale = (scale, scale, scale)
    return o


def relic_pickaxe():
    """The Relic Pickaxe as built in pickaxes.py, under an empty at its grip (build space:
    handle along +y, head at y = 2.6, arms along z). Returns the empty."""
    root = bpy.data.objects.new("PickaxeRoot", None)
    bpy.context.scene.collection.objects.link(root)
    pieces, data = pickaxes.build("RelicPickaxe")
    glow = mat("PickGlow", data["GlowColor"], emission=4.0)
    for o in pieces:
        put(o)
        info = data["Glow" if o.name.endswith("Glow") else "Body"]
        c = info["Center"]
        o.location = Vector((c[0], -c[2], c[1])) - Vector((0, -1.05, 0))  # the grip is the root
        o.parent = root
        if o.name.endswith("Glow"):
            o.data.materials.clear()
            o.data.materials.append(glow)
    return root


def avatar(loc, turn=0.0, shirt=(40, 170, 255), pants=(40, 44, 70), skin=(255, 214, 60), pose="swing"):
    """A blocky avatar (head, torso, arms, legs) holding the Relic Pickaxe up over its head."""
    root = bpy.data.objects.new("Avatar", None)
    bpy.context.scene.collection.objects.link(root)
    root.location = loc
    root.rotation_euler = (0, 0, R(turn))
    m_skin, m_shirt, m_pants = mat("Skin", skin, 0.4), mat("Shirt", shirt, 0.4), mat("Pants", pants, 0.5)
    m_shoe = mat("Shoes", (245, 245, 250), 0.4)
    ink = mat("Ink", (25, 20, 35), 0.3)
    parts = []
    for sx in (-1, 1):
        parts.append(box("Leg", (0.95, 1.0, 2.0), m_pants, loc=(sx * 0.5, 0, 2.0), pivot=(0, 0, 0.5), rot=(sx * 8, 0, 0)))
        parts.append(box("Shoe", (1.0, 1.15, 0.35), m_shoe, loc=(sx * 0.5 + 0.0, -0.06 - sx * 0.14, 0.17), rot=(0, 0, 0)))
    parts.append(box("Torso", (2.0, 1.0, 2.0), m_shirt, loc=(0, 0, 3.0)))
    parts.append(box("Belt", (2.04, 1.04, 0.22), ink, loc=(0, 0, 2.08), bevel=0.05))
    head = box("Head", (1.3, 1.2, 1.2), m_skin, loc=(0, 0, 4.62), bevel=0.32)
    parts.append(head)
    # a happy face on the front of the head
    for sx in (-1, 1):
        parts.append(ball("Eye", 0.12, ink, loc=(sx * 0.26, -0.6, 4.72), scale=(1, 0.5, 1.5), coll="Ground"))
        parts.append(ball("EyeShine", 0.04, mat("White", (255, 255, 255), 0.2), loc=(sx * 0.26 + 0.04, -0.66, 4.8), coll="Ground"))
    for k in range(13):
        a = R(205 + k * 130 / 12)
        parts.append(ball("Smile", 0.055, ink, loc=(math.cos(a) * 0.3, -0.61, 4.58 + math.sin(a) * 0.18), coll="Ground"))
    # arms: up over the head, both hands on the pickaxe
    up = pose == "swing"
    for sx in (-1, 1):
        rot = ((0, -135, 0) if sx > 0 else (-10, 15, 0)) if up else (0, sx * 10, 0)
        parts.append(box("Arm", (0.95, 1.0, 2.0), m_shirt, loc=(sx * 1.5, 0, 3.95), pivot=(0, 0, 0.5), rot=rot))
        parts.append(box("Hand", (0.9, 0.95, 0.5), m_skin, loc=(sx * 1.5, 0, 3.95), pivot=(0, 0, 0.5), rot=rot))
        parts[-1].data.transform(Matrix.Translation((0, 0, -1.75)))
    for p in parts:
        p.parent = root
    pick = None
    if up:
        pick = relic_pickaxe()
        pick.parent = root
        # build space -> avatar space: handle (y) up, the pick's arms (z) to the sides; the grip in
        # the raised right hand (shoulder + 2.25 along the arm), leaning in over the head
        turn_m = Matrix(((0, 0, 1), (1, 0, 0), (0, 1, 0))).to_4x4()
        hand = Vector((1.5, 0, 3.95)) + Vector((math.sin(R(45)), 0, math.cos(R(45)))) * 2.2
        pick.matrix_parent_inverse = Matrix.Identity(4)
        pick.matrix_basis = Matrix.Translation(hand) @ Matrix.Rotation(R(-28), 4, "Y") @ turn_m
    return root, pick


def ground(radius=140, color=(110, 205, 80)):
    cyl("Ground", radius, 1.0, mat("Grass", color, 0.8, coat=0.0), loc=(0, 0, -0.5), coll="Ground", verts=128)


def pit(center, radius=4.5, glow_color=(255, 220, 90)):
    """A dug hole with a dirt rim, light pouring out of it."""
    cx, cy = center
    cyl("Hole", radius, 0.2, mat("HoleDark", (45, 26, 18), 1.0, coat=0.0), loc=(cx, cy, 0.02), coll="Ground")
    ring("Rim", radius + 0.15, 0.55, mat("Dirt", (160, 100, 55), 0.8, coat=0.0), loc=(cx, cy, 0.05))
    rnd = random.Random(4)
    for k in range(14):
        a = R(k * 360 / 14 + rnd.uniform(-8, 8))
        r = radius + 1.0 + rnd.uniform(0, 1.6)
        ball("Clod", rnd.uniform(0.25, 0.5), mat("Dirt2", (140, 86, 46), 0.8, coat=0.0), loc=(cx + math.cos(a) * r, cy + math.sin(a) * r, 0.15),
             scale=(1.2, 1, 0.7), coll="Detail")
    # a glowing beam of light out of the hole
    beam = cyl("Beam", radius * 0.55, 14, mat("Beam", glow_color, 0.5, emission=2.0), loc=(cx, cy, 7), coll="Ground", verts=48)
    m = beam.data.materials[0]
    nodes = m.node_tree.nodes
    bsdf = next(n for n in nodes if n.type == "BSDF_PRINCIPLED")
    out = next(n for n in nodes if n.type == "OUTPUT_MATERIAL")
    mix = nodes.new("ShaderNodeMixShader")
    transparent = nodes.new("ShaderNodeBsdfTransparent")
    mix.inputs[0].default_value = 0.13
    m.node_tree.links.new(transparent.outputs[0], mix.inputs[1])
    m.node_tree.links.new(bsdf.outputs[0], mix.inputs[2])
    m.node_tree.links.new(mix.outputs[0], out.inputs[0])
    beam.visible_shadow = False
    pl = light("POINT", "PitLight", (cx, cy, 1.5), 2500, color=tuple(c / 255 for c in glow_color))
    pl.data.shadow_soft_size = 2.0


def skyline(rng_seed=2, count=26, dist=(70, 110), spread=140):
    """Pastel futuristic towers far behind, with glowing rings (the 2050 skyline)."""
    rnd = random.Random(rng_seed)
    colors = [(150, 120, 255), (90, 200, 255), (255, 140, 200), (120, 230, 210), (255, 200, 120)]
    for _ in range(count):
        x = rnd.uniform(-spread / 2, spread / 2)
        y = rnd.uniform(*dist)
        h = rnd.uniform(18, 55)
        r = rnd.uniform(2.5, 5.5)
        c = rnd.choice(colors)
        cyl("Tower", r, h, mat("Tower", c, 0.5), loc=(x, y, h / 2), coll="Ground", verts=32)
        for k in range(rnd.randint(1, 3)):
            ring("TowerRing", r + 0.5, 0.35, mat("TowerGlow", (255, 255, 255), 0.3, emission=1.5), loc=(x, y, h * rnd.uniform(0.3, 0.95)),
                 coll="Ground")
        cyl("TowerTop", r * 1.4, 1.2, mat("TowerTop", c, 0.4), loc=(x, y, h), coll="Ground", verts=32)


def coin(loc, rot, size=0.55):
    cyl("Coin", size, 0.16, mat("CoinGold", (255, 205, 50), 0.15, metal=0.4, coat=0.8), loc=loc, rot=rot, coll="Detail", bevel=0.04)


def sparkles(cam, spots, color=(255, 232, 90)):
    m = mat("Sparkle", color, 0.3, emission=1.2)
    for x, y, d, s in spots:
        star_shape("Sparkle", s * 1.7, m, cam.at(x, y, d), cam.facing())


def title(cam, lines, dist=9, top=4.6, sizes=(3.0, 2.0), colors=((255, 225, 60), (255, 255, 255)), tilt=-4):
    """The game's name in big chunky letters, facing the camera, close to it so nothing in the
    scene covers it (top and sizes are given as if it were 22 units away)."""
    rot = cam.facing()
    rot.rotate_axis("Z", R(tilt))
    k = dist / 22
    y = top
    for i, line in enumerate(lines):
        size = sizes[min(i, len(sizes) - 1)]
        text(line, size * k, mat("Title%d" % i, colors[min(i, len(colors) - 1)], 0.25, coat=0.8), cam.at(0, y * k, dist), rot, extrude=0.3 * k)
        y -= size * 0.95


def render(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("wrote", path)


# ------------------------------------------------------------------------------------------
# the pictures
# ------------------------------------------------------------------------------------------
def scene_dig(width=1920, height=1080, with_title=True, out="Thumbnail_Dig.png"):
    """Digging up memes: the avatar swinging the Relic Pickaxe at a glowing pit, memes bursting
    out, a Relic Dragon and a Pixel Pup alongside, the 2050 skyline behind."""
    setup(width, height)
    sky((170, 235, 255), (110, 90, 245))
    ground()
    pit((2.5, 3.0))
    skyline()
    av, _ = avatar((-4.6, 0.5, 0), turn=-15)
    meme(memes_batch1.sneaker_shark, (2.2, 0.4, 3.6), turn=-30, scale=1.15, tilt=(10, -20))
    meme(memes_batch2.sus_bean, (6.6, 1.0, 1.8), turn=-50, scale=1.1, tilt=(0, 18))
    meme(memes_batch2.stonks_head, (-0.6, 1.6, 6.4), turn=-10, scale=0.9, tilt=(-12, 10))
    meme(memes_batch1.cappuccino_ballerina, (4.8, 1.4, 6.0), turn=-20, scale=0.95, tilt=(8, 14))
    meme(pets.relic_dragon, (-8.6, 3.0, 4.2), turn=25, scale=1.1)
    meme(pets.pixel_pup, (8.6, 2.0, 0), turn=-40, scale=0.85)
    rnd = random.Random(7)
    for _ in range(14):
        coin((2.5 + rnd.uniform(-4.5, 4.5), 2 + rnd.uniform(-2, 2), rnd.uniform(1.5, 7.5)), (R(rnd.uniform(0, 180)), R(rnd.uniform(0, 180)), 0))
    cam = Cam((1.2, -21, 6.5), (0.6, 2.5, 5.8), lens=34)
    light("SUN", "Sun", (0, 0, 10), 3.2, rot=(50, 10, -35), color=(1, 0.97, 0.9))
    light("AREA", "Fill", (-12, -12, 10), 1500, size=10, color=(0.85, 0.9, 1))
    sparkles(cam, [(-9, 5.5, 18, 0.5), (8.5, 6, 18, 0.45), (7, -1.5, 18, 0.35), (-6.5, 1, 18, 0.3)])
    if with_title:
        title(cam, ["MEME ARCHEOLOGIST"], top=5.0, sizes=(1.95,))
    render(os.path.join(OUT, out))


def scene_icon():
    """The experience icon: the avatar close up swinging the Relic Pickaxe, a meme bursting out
    of the glowing pit beside it, coins and sparkles. No words: icons are shown tiny."""
    setup(512, 512, samples=96)
    sky((150, 235, 255), (120, 80, 250))
    ground()
    pit((3.6, 3.0), radius=3.6)
    av, _ = avatar((-2.2, 0.0, 0), turn=-15)
    meme(memes_batch1.sneaker_shark, (3.6, 0.6, 3.6), turn=-40, scale=1.3, tilt=(10, -25))
    skyline(rng_seed=4, count=18)
    rnd = random.Random(3)
    for _ in range(8):
        coin((3.6 + rnd.uniform(-3, 3), 3 + rnd.uniform(-1.5, 1.5), rnd.uniform(1.5, 9.5)), (R(rnd.uniform(0, 180)), R(rnd.uniform(0, 180)), 0), 0.5)
    cam = Cam((0.8, -16.5, 5.2), (1.0, 1.5, 5.0), lens=40)
    light("SUN", "Sun", (0, 0, 10), 3.4, rot=(50, 10, -35), color=(1, 0.97, 0.9))
    light("AREA", "Fill", (-10, -10, 8), 1200, size=8, color=(0.85, 0.9, 1))
    sparkles(cam, [(-4.8, 4.6, 16, 0.42), (4.9, 4.9, 16, 0.36), (-4.6, -2.2, 16, 0.3)])
    render(os.path.join(OUT, "Icon.png"))


def scene_pets():
    """Hatch pets: the Relic Egg on a gold stand with the five Relic pets and a few world pets."""
    setup(1920, 1080)
    sky((255, 210, 240), (120, 90, 245))
    ground(color=(120, 210, 90))
    skyline(rng_seed=5)
    gold = mat("StandGold", (255, 205, 60), 0.2, metal=0.3, coat=0.8)
    cyl("Stand", 3.4, 1.0, mat("StandCream", (255, 236, 170), 0.4), loc=(0, 3, 0.5), verts=64, bevel=0.1)
    cyl("StandTop", 2.8, 0.4, gold, loc=(0, 3, 1.15), verts=64, bevel=0.08)
    ring("StandGlow", 3.45, 0.18, mat("StandTeal", (40, 230, 210), 0.3, emission=2.0), loc=(0, 3, 0.4))
    meme(pets.relic_egg, (0, 3, 1.35), turn=-15, scale=1.6)
    light("POINT", "EggGlow", (0, 1.5, 4), 900, color=(1, 0.85, 0.5))
    for fn, loc, turn, s in ((pets.relic_dragon, (-6.3, 4.5, 4.5), 30, 1.15), (pets.idol_monkey, (5.6, 2.5, 0), -35, 1.0),
                             (pets.totem_owl, (6.8, 6.0, 4.6), -25, 1.0), (pets.fossil_rex, (-5.2, 0.6, 0), 35, 1.0),
                             (pets.mummy_cat, (2.8, -0.6, 0), -20, 0.85), (pets.phoenix, (-1.5, 8.5, 6.5), 10, 1.0),
                             (pets.pixel_pup, (-2.6, -1.0, 0), 25, 0.8), (pets.cupcake_cat, (8.8, 1.0, 0), -40, 0.85)):
        meme(fn, loc, turn=turn, scale=s)
    cam = Cam((0, -21, 6.0), (0, 3, 4.6), lens=34)
    light("SUN", "Sun", (0, 0, 10), 3.2, rot=(50, 10, -30), color=(1, 0.97, 0.9))
    light("AREA", "Fill", (-12, -12, 10), 1500, size=10, color=(0.9, 0.9, 1))
    sparkles(cam, [(-8.5, 5.5, 18, 0.5), (8.8, 5.2, 18, 0.45), (0.0, 4.6, 18, 0.35), (-3.5, 2.5, 18, 0.3), (4.2, 3.4, 18, 0.32)])
    title(cam, ["HATCH PETS!"], top=4.9, sizes=(2.8,), colors=((255, 225, 60),))
    render(os.path.join(OUT, "Thumbnail_Pets.png"))


def scene_museum():
    """Your meme museum: memes on glowing pedestals in a row, cash flying."""
    setup(1920, 1080)
    sky((200, 240, 255), (150, 110, 255))
    ground(color=(235, 235, 245))
    skyline(rng_seed=9)
    rows = [(memes_batch1.log_guy, -9.0), (memes_batch2.sus_bean, -4.5), (memes_batch1.sneaker_shark, 0.0),
            (memes_batch2.stonks_head, 4.5), (memes_batch1.baby_hippo, 9.0)]
    colors = [(255, 90, 160), (90, 200, 255), (255, 200, 60), (150, 110, 255), (90, 230, 150)]
    for (fn, x), c in zip(rows, colors):
        y = 5 + abs(x) * 0.25
        cyl("Pedestal", 1.6, 2.0, mat("Pedestal", (250, 250, 255), 0.3), loc=(x, y, 1.0), verts=48, bevel=0.1)
        ring("PedestalGlow", 1.62, 0.12, mat("PedGlow", c, 0.3, emission=2.5), loc=(x, y, 1.9))
        cyl("PedestalTop", 1.75, 0.25, mat("PedTop", c, 0.3), loc=(x, y, 2.1), verts=48, bevel=0.05)
        meme(fn, (x, y, 2.25), turn=-math.degrees(math.atan2(x, 26)) * 0.8, scale=1.0)
    cash = mat("Cash", (95, 200, 85), 0.4)
    rnd = random.Random(11)
    for _ in range(16):
        box("Bill", (1.0, 0.5, 0.05), cash, loc=(rnd.uniform(-10, 10), rnd.uniform(-1, 6), rnd.uniform(3, 10)),
            rot=(rnd.uniform(-50, 50), rnd.uniform(-50, 50), rnd.uniform(0, 180)), bevel=0.02, coll="Detail")
    cam = Cam((-0.5, -17, 4.6), (-0.5, 4, 4.3), lens=33)
    light("SUN", "Sun", (0, 0, 10), 3.0, rot=(50, 10, -30), color=(1, 0.97, 0.92))
    light("AREA", "Fill", (-12, -12, 10), 1400, size=10, color=(0.9, 0.9, 1))
    title(cam, ["BUILD YOUR MEME MUSEUM"], top=5.0, sizes=(1.75,), colors=((255, 225, 60),))
    render(os.path.join(OUT, "Thumbnail_Museum.png"))


SCENES = {"Icon": scene_icon, "Dig": scene_dig, "Pets": scene_pets, "Museum": scene_museum}

if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    for name in args or SCENES:
        SCENES[name]()
