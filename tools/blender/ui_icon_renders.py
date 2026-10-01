"""Renders the HUD's big menu icons as glossy pictures (like the icons in top Roblox games):
smooth rounded models with shiny materials, soft studio lighting and a thick dark outline,
rendered on a transparent background. These replace the live low-poly 3D icons for the
icons listed here (UIKit.icon shows a picture when src/shared/UIIconImages.lua has one).

Writes assets/ui/rendered/<Name>.png (512 x 512). Upload them to Roblox and put the asset
ids in src/shared/UIIconImages.lua.

Run inside Blender (Scripting tab, or the Blender MCP), or headless:
    blender --background --python tools/blender/ui_icon_renders.py -- [names...]
Coordinates: z is up, the icon faces -y (Blender's front).
"""
import math
import os
import sys

import bpy
import bmesh

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
OUT = os.path.join(ROOT, "assets", "ui", "rendered")
R = math.radians
SIZE = 512


def rgb(r, g, b):
    # sRGB 0-255 -> linear, which is what Blender's color inputs expect
    def lin(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return (lin(r), lin(g), lin(b), 1)


# ------------------------------------------------------------------------------------------
# scene
# ------------------------------------------------------------------------------------------
def reset():
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    for block in (bpy.data.meshes, bpy.data.materials, bpy.data.lights, bpy.data.cameras, bpy.data.curves):
        for item in list(block):
            if item.users == 0:
                block.remove(item)


def setup_render():
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 96
    scene.cycles.use_denoising = True
    scene.render.resolution_x = SIZE
    scene.render.resolution_y = SIZE
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    world = scene.world or bpy.data.worlds.new("World")
    scene.world = world
    world.use_nodes = True
    bg = next(n for n in world.node_tree.nodes if n.type == "BACKGROUND")
    bg.inputs[0].default_value = rgb(205, 220, 255)
    bg.inputs[1].default_value = 0.45
    # a thick dark outline around the silhouette (and around each separate part)
    scene.render.use_freestyle = True
    scene.render.line_thickness_mode = "ABSOLUTE"
    scene.render.line_thickness = 1
    layer = bpy.context.view_layer
    layer.use_freestyle = True
    fs = layer.freestyle_settings
    while fs.linesets:
        fs.linesets.remove(fs.linesets[0])
    # thick outline around the main shapes, a thin one around small details (straps, buckles)
    for name, thickness in (("Main", 17), ("Detail", 6)):
        collection = bpy.data.collections.get(name) or bpy.data.collections.new(name)
        if collection.name not in bpy.context.scene.collection.children:
            bpy.context.scene.collection.children.link(collection)
        lineset = fs.linesets.new(name)
        lineset.select_by_visibility = True
        lineset.select_by_edge_types = True
        lineset.select_by_collection = True
        lineset.collection = collection
        for attr in ("select_silhouette", "select_border", "select_external_contour"):
            setattr(lineset, attr, True)
        for attr in ("select_crease", "select_material_boundary", "select_contour", "select_suggestive_contour",
                     "select_ridge_valley", "select_edge_mark"):
            if hasattr(lineset, attr):
                setattr(lineset, attr, False)
        style = lineset.linestyle or bpy.data.linestyles.new(name)
        lineset.linestyle = style
        style.color = (0.02, 0.015, 0.05)
        style.thickness = thickness
        style.thickness_position = "CENTER"


def lights_and_camera(ortho=5.0, view=(18, -14), center=0.0):
    cam_data = bpy.data.cameras.new("Cam")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = ortho
    cam = bpy.data.objects.new("Cam", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    tilt, turn = R(view[0]), R(view[1])
    d = 20
    cam.location = (math.sin(turn) * math.cos(tilt) * d, -math.cos(turn) * math.cos(tilt) * d, math.sin(tilt) * d)
    cam.location.z += center
    cam.rotation_euler = (R(90) - tilt, 0, turn)
    bpy.context.scene.camera = cam

    def area(name, loc, power, size, color=(1, 1, 1)):
        data = bpy.data.lights.new(name, "AREA")
        data.energy = power
        data.size = size
        data.color = color
        o = bpy.data.objects.new(name, data)
        o.location = loc
        bpy.context.scene.collection.objects.link(o)
        # aim at the origin
        v = -o.location
        o.rotation_euler = v.to_track_quat("-Z", "Y").to_euler()
        return o

    from mathutils import Vector
    for name, loc, power, size, color in (
        ("Key", Vector((-3, -5, 7)), 1400, 2.5, (1, 0.98, 0.94)),
        ("Fill", Vector((6, -4, 0)), 220, 6, (0.8, 0.88, 1)),
        ("Rim", Vector((1, 6, 4)), 1100, 3, (1, 1, 1)),
    ):
        area(name, loc, power, size, color)


def material(name, color, rough=0.28, coat=0.6, metal=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    for key in ("Coat Weight", "Clearcoat"):
        if key in bsdf.inputs:
            bsdf.inputs[key].default_value = coat
            break
    if "Coat Roughness" in bsdf.inputs:
        bsdf.inputs["Coat Roughness"].default_value = 0.08
    return m


def finish(o, mat, bevel=0.08, segments=4, smooth=True):
    o.data.materials.append(mat)
    if bevel > 0:
        mod = o.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = segments
        mod.limit_method = "ANGLE"
        mod.angle_limit = R(35)
        mod.harden_normals = False
    if smooth:
        for poly in o.data.polygons:
            poly.use_smooth = True
        mod = o.modifiers.new("Smooth", "WEIGHTED_NORMAL") if bevel > 0 else None
        if mod:
            mod.keep_sharp = True
    return o


DETAIL = ("Strap", "Buckle", "Tie", "BedrollEnd", "PocketFlap", "Hole")


def link(o):
    """Puts an object in the Main or Detail collection (which sets its outline weight)."""
    for c in list(o.users_collection):
        c.objects.unlink(o)
    name = "Detail" if o.name.startswith(DETAIL) else "Main"
    bpy.data.collections[name].objects.link(o)
    return o


def flat_shape(name, pts, depth, mat, loc=(0, 0, 0), rot=(0, 0, 0), bevel=0.12):
    """A flat shape drawn in the x-z plane (seen from the front), pushed out along y."""
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
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(o)
    link(o)
    o.location = loc
    o.rotation_euler = rot
    return finish(o, mat, bevel=bevel, segments=5)


def rounded_box(name, size, mat, loc=(0, 0, 0), rot=(0, 0, 0), bevel=0.25):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc, rotation=rot)
    o = bpy.context.active_object
    o.name = name
    o.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    link(o)
    return finish(o, mat, bevel=min(bevel, min(size) * 0.48), segments=6)


def cylinder(name, radius, depth, mat, loc=(0, 0, 0), rot=(0, 0, 0), bevel=0.1, verts=64):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=rot)
    o = bpy.context.active_object
    o.name = name
    link(o)
    return finish(o, mat, bevel=bevel, segments=5)


def torus(name, major, minor, mat, loc=(0, 0, 0), rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, location=loc, rotation=rot,
                                     major_segments=64, minor_segments=16)
    o = bpy.context.active_object
    o.name = name
    link(o)
    return finish(o, mat, bevel=0)


# ------------------------------------------------------------------------------------------
# icons
# ------------------------------------------------------------------------------------------
def arrow_points(a0, a1, outer, inner, head=0.5, tip_angle=34, steps=40):
    """A thick curved arrow along a circle, from angle a0 to a1 (degrees), head at a1."""
    mid = (outer + inner) / 2
    pts = []
    for i in range(steps + 1):
        a = R(a0 + (a1 - a0) * i / steps)
        pts.append((math.cos(a) * outer, math.sin(a) * outer))
    a = R(a1)
    pts.append((math.cos(a) * (outer + head), math.sin(a) * (outer + head)))
    t = R(a1 + tip_angle)
    pts.append((math.cos(t) * mid, math.sin(t) * mid))
    pts.append((math.cos(a) * (inner - head), math.sin(a) * (inner - head)))
    for i in range(steps, -1, -1):
        a = R(a0 + (a1 - a0) * i / steps)
        pts.append((math.cos(a) * inner, math.sin(a) * inner))
    return pts


def build_rebirth():
    pink = material("RebirthPink", rgb(244, 70, 108), rough=0.14, coat=1.0)
    white = material("RebirthWhite", rgb(214, 238, 255), rough=0.14, coat=1.0)
    flat_shape("ArrowTop", arrow_points(22, 134, 1.85, 0.9, head=0.6, tip_angle=36), 1.0, pink, bevel=0.22)
    flat_shape("ArrowBottom", arrow_points(202, 314, 1.85, 0.9, head=0.6, tip_angle=36), 1.0, white, bevel=0.22)
    return 4.55, (14, -16)


def build_bag():
    leather = material("Leather", rgb(168, 98, 44), rough=0.42, coat=0.35)
    dark = material("LeatherDark", rgb(118, 64, 28), rough=0.45, coat=0.3)
    light = material("LeatherLight", rgb(196, 124, 62), rough=0.42, coat=0.35)
    strap = material("Strap", rgb(92, 50, 24), rough=0.5, coat=0.2)
    gold = material("Buckle", rgb(250, 200, 70), rough=0.18, coat=0.6, metal=0.7)
    blue = material("Bedroll", rgb(58, 132, 226), rough=0.35, coat=0.5)
    blueLight = material("BedrollEnd", rgb(150, 205, 255), rough=0.35, coat=0.5)
    # body, flap, pockets
    rounded_box("Body", (2.3, 1.3, 2.5), leather, loc=(0, 0, -0.15), bevel=0.42)
    rounded_box("Flap", (2.36, 1.42, 0.9), dark, loc=(0, -0.02, 0.95), bevel=0.36)
    rounded_box("Pocket", (1.62, 0.5, 1.15), light, loc=(0, -0.72, -0.62), bevel=0.24)
    rounded_box("PocketFlap", (1.72, 0.56, 0.42), dark, loc=(0, -0.78, -0.08), bevel=0.18)
    for x in (-1.24, 1.24):
        rounded_box("SidePocket", (0.38, 0.9, 1.15), light, loc=(x, 0, -0.62), bevel=0.16)
    # straps with gold buckles down the front
    for x in (-0.52, 0.52):
        rounded_box("Strap", (0.3, 0.12, 1.3), strap, loc=(x, -0.98, -0.2), bevel=0.05)
        rounded_box("Buckle", (0.46, 0.16, 0.36), gold, loc=(x, -1.06, -0.55), bevel=0.07)
    # a rolled blue blanket on top, tied with two straps
    cylinder("Bedroll", 0.48, 2.7, blue, loc=(0, 0.05, 1.68), rot=(0, R(90), 0), bevel=0.14)
    for x in (-1.36, 1.36):
        cylinder("BedrollEnd", 0.42, 0.04, blueLight, loc=(x, 0.05, 1.68), rot=(0, R(90), 0), bevel=0.0)
    for x in (-0.7, 0.7):
        torus("Tie", 0.5, 0.07, strap, loc=(x, 0.05, 1.68), rot=(0, R(90), 0))
    return 4.35, (14, -24), 0.42


def build_settings():
    steel = material("GearSteel", rgb(214, 228, 246), rough=0.2, coat=0.7, metal=0.35)
    hub = material("GearHub", rgb(52, 140, 236), rough=0.2, coat=0.8)
    hole = material("GearHole", rgb(30, 44, 92), rough=0.4, coat=0.3)
    teeth, outer, root = 9, 1.95, 1.5
    pts = []
    for i in range(teeth):
        base = 360 / teeth * i
        for a, r in ((base - 13, root), (base - 8, outer), (base + 8, outer), (base + 13, root)):
            # little arcs along the root between the teeth
            pts.append((math.cos(R(a)) * r, math.sin(R(a)) * r))
        for k in (1, 2, 3):
            a = base + 13 + (360 / teeth - 26) * k / 4
            pts.append((math.cos(R(a)) * root, math.sin(R(a)) * root))
    flat_shape("Gear", pts, 0.7, steel, bevel=0.14)
    cylinder("Hub", 0.95, 0.86, hub, loc=(0, 0, 0), rot=(R(90), 0, 0), bevel=0.14)
    cylinder("Hole", 0.42, 0.9, hole, loc=(0, -0.01, 0), rot=(R(90), 0, 0), bevel=0.08)
    return 4.5, (12, -14)


ICONS = {"Rebirth": build_rebirth, "Bag": build_bag, "Settings": build_settings}


def render(name):
    reset()
    setup_render()
    ortho, view, *rest = ICONS[name]()
    lights_and_camera(ortho, view, rest[0] if rest else 0.0)
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name + ".png")
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("wrote", path)
    return path


def main(names=None):
    for name in names or ICONS:
        render(name)


if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    main(args or None)
