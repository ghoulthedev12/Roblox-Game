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
    for name, thickness in (("Main", 17), ("Mid", 10), ("Detail", 6)):
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


MID = ("Bill",)
DETAIL = ("Strap", "Buckle", "Tie", "BedrollEnd", "BedrollStripe", "PocketFlap", "Hole", "Print", "Band")


def link(o):
    """Puts an object in the Main or Detail collection (which sets its outline weight)."""
    for c in list(o.users_collection):
        c.objects.unlink(o)
    name = "Detail" if o.name.startswith(DETAIL) else ("Mid" if o.name.startswith(MID) else "Main")
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
    leather = material("Leather", rgb(190, 110, 48), rough=0.38, coat=0.45)
    dark = material("LeatherDark", rgb(136, 72, 32), rough=0.4, coat=0.4)
    light = material("LeatherLight", rgb(214, 138, 70), rough=0.38, coat=0.45)
    strap = material("Strap", rgb(96, 50, 22), rough=0.5, coat=0.2)
    gold = material("Buckle", rgb(255, 204, 64), rough=0.15, coat=0.7, metal=0.75)
    blue = material("Bedroll", rgb(64, 138, 232), rough=0.32, coat=0.6)
    blueEnd = material("BedrollEnd", rgb(150, 206, 255), rough=0.32, coat=0.6)
    blueDark = material("BedrollSpiral", rgb(36, 92, 180), rough=0.35, coat=0.5)
    cream = material("BedrollStripe", rgb(246, 238, 214), rough=0.35, coat=0.5)
    # a round, puffy body with a big flap over the top
    rounded_box("Body", (2.4, 1.4, 2.6), leather, loc=(0, 0, -0.2), bevel=0.62)
    rounded_box("Flap", (2.5, 1.54, 1.0), dark, loc=(0, -0.02, 0.98), bevel=0.46)
    # the flap's tongue hangs down the front and closes with a gold buckle
    rounded_box("StrapTongue", (0.62, 0.22, 0.9), dark, loc=(0, -0.76, 0.48), bevel=0.2)
    rounded_box("Buckle", (0.62, 0.18, 0.4), gold, loc=(0, -0.88, 0.1), bevel=0.09)
    # a big front pocket with its own seam, and two side pockets
    rounded_box("Pocket", (1.86, 0.62, 1.24), light, loc=(0, -0.7, -0.66), bevel=0.32)
    rounded_box("PocketFlap", (1.92, 0.68, 0.34), dark, loc=(0, -0.72, -0.12), bevel=0.15)
    for x in (-1.3, 1.3):
        rounded_box("SidePocket", (0.44, 1.02, 1.32), light, loc=(x, 0, -0.62), bevel=0.2)
    # a carry handle behind the blanket roll
    torus("StrapHandle", 0.42, 0.1, strap, loc=(0, 0.42, 1.62), rot=(R(90), 0, 0))
    # a rolled blue blanket on top: cream stripes, tied with two straps, a spiral on each end
    cylinder("Bedroll", 0.52, 2.8, blue, loc=(0, 0.02, 1.76), rot=(0, R(90), 0), bevel=0.16)
    for x in (-0.98, 0.98):
        cylinder("BedrollStripe", 0.525, 0.2, cream, loc=(x, 0.02, 1.76), rot=(0, R(90), 0), bevel=0.0)
    for x in (-1.41, 1.41):
        cylinder("BedrollEnd", 0.44, 0.04, blueEnd, loc=(x, 0.02, 1.76), rot=(0, R(90), 0), bevel=0.0)
        cylinder("BedrollEnd", 0.22, 0.06, blueDark, loc=(x * 1.004, 0.02, 1.76), rot=(0, R(90), 0), bevel=0.0)
    for x in (-0.48, 0.48):
        torus("Tie", 0.54, 0.075, strap, loc=(x, 0.02, 1.76), rot=(0, R(90), 0))
    return 4.4, (12, -22), 0.4


def build_gem():
    """A cartoon purple diamond (brilliant cut): an octagonal table on top, triangle facets
    around the crown, a pointed base; the facets come in three shades of lavender."""
    light = material("GemLight", rgb(190, 128, 255), rough=0.5, coat=0.25)
    mid = material("GemMid", rgb(160, 92, 246), rough=0.5, coat=0.25)
    dark = material("GemDark", rgb(118, 54, 210), rough=0.5, coat=0.25)
    table_r, girdle_r, crown_h, tip = 0.62, 1.25, 0.5, -1.3
    bm = bmesh.new()
    t = [bm.verts.new((math.cos(R(45 * i + 22.5)) * table_r, math.sin(R(45 * i + 22.5)) * table_r, crown_h)) for i in range(8)]
    g = [bm.verts.new((math.cos(R(22.5 * k)) * girdle_r, math.sin(R(22.5 * k)) * girdle_r, 0)) for k in range(16)]
    bottom = bm.verts.new((0, 0, tip))
    faces = []  # (face, shade)
    faces.append((bm.faces.new(t), 0))
    for i in range(8):
        j = (i + 1) % 8
        faces.append((bm.faces.new((t[i], t[j], g[(2 * i + 2) % 16])), 0))           # star facets
        faces.append((bm.faces.new((t[i], g[(2 * i + 1) % 16], g[(2 * i + 2) % 16])), 1))
        faces.append((bm.faces.new((t[j], g[(2 * i + 2) % 16], g[(2 * i + 3) % 16])), 1))
    for k in range(16):
        faces.append((bm.faces.new((g[(k + 1) % 16], g[k], bottom)), 1 if k % 2 == 0 else 2))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("Gem")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("Gem", me)
    bpy.context.scene.collection.objects.link(o)
    link(o)
    for m in (light, mid, dark):
        o.data.materials.append(m)
    shades = [shade for _, shade in faces]
    for poly, shade in zip(o.data.polygons, shades):
        poly.material_index = shade
    # point down, the table tipped toward the camera and the whole gem leaning to one side
    o.rotation_euler = (R(14), R(-20), R(8))
    o.location = (0, 0, 0.2)
    finish(o, light, bevel=0, smooth=False)
    o.data.materials.pop(index=3)  # finish() appended `light` again
    return 3.6, (8, -10), -0.1


def build_cash():
    """A thick stack of green bills tied with a yellow band with a $ on it."""
    side = material("BillSide", rgb(38, 132, 58), rough=0.45, coat=0.3)
    sideLight = material("BillSideLight", rgb(62, 160, 74), rough=0.45, coat=0.3)
    face = material("BillFace", rgb(124, 204, 112), rough=0.45, coat=0.35)
    frame = material("PrintFrame", rgb(46, 146, 66), rough=0.5, coat=0.2)
    oval = material("PrintOval", rgb(38, 128, 56), rough=0.5, coat=0.2)
    band = material("Band", rgb(255, 228, 92), rough=0.3, coat=0.5)
    bandEdge = material("BandEdge", rgb(244, 166, 50), rough=0.3, coat=0.5)
    dollar = material("Dollar", rgb(34, 140, 60), rough=0.35, coat=0.4)
    n, h = 5, 0.2
    for k in range(n):
        dx, turn = ((0.08, -2), (-0.06, 1.5), (0.05, -1), (-0.03, 1), (0, 0))[k]
        rounded_box("Bill", (3.2, 1.62, h), sideLight if k % 2 else side, loc=(dx, 0, -0.5 + k * (h + 0.02)),
                    rot=(0, 0, R(turn)), bevel=0.07)
    top = -0.5 + (n - 1) * (h + 0.02) + h / 2
    rounded_box("PrintFrame", (2.95, 1.38, 0.03), frame, loc=(0, 0, top + 0.005), bevel=0.012)
    rounded_box("PrintFace", (2.75, 1.2, 0.04), face, loc=(0, 0, top + 0.012), bevel=0.012)
    for x in (-0.95, 0.95):
        o = cylinder("PrintOval", 0.3, 0.05, oval, loc=(x, 0, top + 0.03), bevel=0.0)
        o.scale = (1.25, 0.95, 1)
    # the band wraps the middle of the stack, with orange edges and a green $ on top
    stack_h = n * (h + 0.02) + 0.06
    mid_z = -0.5 + (n - 1) * (h + 0.02) / 2
    rounded_box("Band", (0.92, 1.74, stack_h), band, loc=(0, 0, mid_z), bevel=0.06)
    for x in (-0.48, 0.48):
        rounded_box("BandEdge", (0.07, 1.76, stack_h + 0.02), bandEdge, loc=(x, 0, mid_z), bevel=0.02)
    curve = bpy.data.curves.new("Dollar", "FONT")
    curve.body = "$"
    curve.size = 1.05
    curve.extrude = 0.035
    curve.align_x = "CENTER"
    curve.align_y = "CENTER"
    text = bpy.data.objects.new("PrintDollar", curve)
    bpy.context.scene.collection.objects.link(text)
    text.location = (0, 0, mid_z + stack_h / 2 + 0.02)
    bpy.context.view_layer.objects.active = text
    for other in bpy.context.selected_objects:
        other.select_set(False)
    text.select_set(True)
    bpy.ops.object.convert(target="MESH")
    text = bpy.context.active_object
    link(text)
    text.data.materials.append(dollar)
    return 4.6, (40, -20), -0.15


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


ICONS = {"Rebirth": build_rebirth, "Bag": build_bag, "Settings": build_settings, "Gem": build_gem, "Cash": build_cash}


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
