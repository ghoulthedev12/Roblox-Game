"""Renders the icons of the Robux store (src/shared/StoreData.lua): one per game pass and one
per developer product, in the same glossy outlined style as the HUD icons
(ui_icon_renders.py, whose scene, lights and shape helpers this reuses).

Writes two pictures of each (512 x 512):
  assets/ui/store/<Name>.png         transparent, for the in-game Store window (upload them and
                                     put the ids in src/shared/UIIconImages.lua)
  assets/ui/store/roblox/<Name>.png  on a round colored background with some room around it,
                                     to upload as the pass / product icon on the Creator Hub
                                     (Roblox shows those as a circle)

Run:  blender -b --factory-startup --python tools/blender/store_icons.py -- [names...]
Coordinates: z is up, the icon faces -y (Blender's front).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402
import numpy as np  # noqa: E402
from mathutils import Vector  # noqa: E402

import ui_icon_renders as K  # noqa: E402
from ui_icon_renders import R, cylinder, flat_shape, link, material, rgb, rounded_box, sphere, star_points, torus  # noqa: E402

OUT = os.path.join(K.ROOT, "assets", "ui", "store")
OUT_ROBLOX = os.path.join(OUT, "roblox")
FONT = "C:/Windows/Fonts/seguibl.ttf"  # Segoe UI Black: thick and round (Blender's own font if missing)

# the background of the Creator Hub version: (center, edge) colors
BACKGROUNDS = {
    "PassMoney": ((140, 235, 120), (30, 130, 60)),
    "PassSpeed": ((140, 215, 255), (30, 100, 210)),
    "PassHoles": ((255, 205, 130), (190, 95, 40)),
    "PassPickaxe": ((255, 230, 130), (205, 120, 20)),
    "PassEgg": ((150, 245, 230), (20, 140, 150)),
    "PassEgg3": ((150, 245, 230), (20, 140, 150)),
}


# ------------------------------------------------------------------------------------------
# helpers
# ------------------------------------------------------------------------------------------
class View:
    """Where the camera looks from (same math as ui_icon_renders.lights_and_camera)."""

    def __init__(self, ortho, tilt, turn, center=0.0):
        self.ortho, self.tilt, self.turn, self.center = ortho, tilt, turn, center
        t, u = R(tilt), R(turn)
        self.back = Vector((math.sin(u) * math.cos(t), -math.cos(u) * math.cos(t), math.sin(t)))  # toward the camera
        self.right = Vector((math.cos(u), math.sin(u), 0))
        self.up = self.back.cross(self.right)

    def facing(self):
        """The rotation that turns a shape drawn in the x-z plane (facing -y) to face the camera."""
        return (R(-self.tilt), 0, R(self.turn))

    def at(self, x, y, toward=3.0):
        """A point x right and y up from the middle of the picture, `toward` the camera."""
        return Vector((0, 0, self.center)) + self.right * x + self.up * y + self.back * toward


def text(name, body, size, mat, loc, rot, extrude=0.2, bevel=0.0):
    curve = bpy.data.curves.new(name, "FONT")
    curve.body = body
    curve.size = size
    curve.extrude = extrude
    curve.bevel_depth = bevel
    curve.bevel_resolution = 3
    curve.align_x = "CENTER"
    curve.align_y = "CENTER"
    if os.path.exists(FONT):
        curve.font = bpy.data.fonts.load(FONT, check_existing=True)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.scene.collection.objects.link(obj)
    obj.location = loc
    obj.rotation_euler = rot
    for other in bpy.context.selected_objects:
        other.select_set(False)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    obj = bpy.context.active_object
    link(obj)
    obj.data.materials.append(mat)
    for poly in obj.data.polygons:
        poly.use_smooth = True
    return obj


def badge(view, body, x=0.95, y=-1.05, size=1.9):
    """A big yellow "2x" in front of everything, bottom right, on a red rounded tag."""
    yellow = material("BadgeYellow", rgb(255, 232, 70), rough=0.2, coat=0.8)
    red = material("BadgeRed", rgb(235, 50, 70), rough=0.2, coat=0.8)
    rot = (R(90 - view.tilt), 0, R(view.turn))
    rounded_box("Tag", (size * 1.15, 0.3, size * 0.72), red, loc=view.at(x, y, 3.6), rot=view.facing(), bevel=0.14)
    return text("Print" + body, body, size, yellow, view.at(x, y - size * 0.02, 3.9), rot, extrude=0.12)


def sparkle(view, x, y, size, color=(255, 250, 220)):
    """A four-point twinkle star facing the camera."""
    mat = material("Sparkle", rgb(*color), rough=0.2, coat=0.6)
    pts = star_points(size, size * 0.3, n=4, turn=90)
    return flat_shape("PrintSparkle", pts, 0.12, mat, loc=view.at(x, y, 3.5), rot=view.facing(), bevel=0.03)


# ------------------------------------------------------------------------------------------
# icons: each builds its objects and returns its View
# ------------------------------------------------------------------------------------------
def build_money():
    K.build_cash()
    view = View(5.2, 40, -20, -0.15)
    # a few gold coins tumbling off the stack
    gold = material("Coin", rgb(255, 205, 50), rough=0.18, coat=1.0, metal=0.3)
    edge = material("CoinEdge", rgb(230, 150, 30), rough=0.2, coat=0.8, metal=0.3)
    for k, (x, y, s) in enumerate(((-1.55, 0.95, 0.42), (-0.85, 1.35, 0.34), (1.55, 0.85, 0.3))):
        loc = view.at(x, y, 1.0)
        cylinder("Coin", s, 0.14, edge, loc=loc, rot=(R(90 - view.tilt + 25 * (k - 1)), R(20 * k), R(view.turn)), bevel=0.04)
        cylinder("Coin", s * 0.78, 0.16, gold, loc=loc, rot=(R(90 - view.tilt + 25 * (k - 1)), R(20 * k), R(view.turn)), bevel=0.03)
    badge(view, "2x")
    return view


def build_speed():
    K.build_pickaxe()
    view = View(5.3, 10, -12, -0.1)
    yellow = material("Bolt", rgb(255, 214, 40), rough=0.15, coat=1.0)
    bolt = [(0.25, 1.0), (-0.55, -0.1), (-0.05, -0.1), (-0.4, -1.0), (0.6, 0.2), (0.1, 0.2), (0.55, 1.0)]
    flat_shape("Bolt", [(x * 1.1, z * 1.1) for x, z in bolt], 0.4, yellow, loc=view.at(-1.45, 0.95, 2.0), rot=view.facing(), bevel=0.08)
    badge(view, "2x")
    return view


def build_holes():
    view = View(5.4, 38, -12, -0.1)
    grass = material("Grass", rgb(90, 180, 60), rough=0.8, coat=0.05)
    grassSide = material("GrassSide", rgb(140, 90, 50), rough=0.8, coat=0.05)
    dirt = material("Dirt", rgb(150, 95, 50), rough=0.8, coat=0.05)
    hole = material("Hole", rgb(40, 24, 16), rough=1.0, coat=0.0)
    rock = material("Rock", rgb(150, 150, 160), rough=0.5, coat=0.2)
    red = material("Arrow", rgb(244, 70, 80), rough=0.7, coat=0.0)
    cylinder("Ground", 2.05, 0.7, grassSide, loc=(0, 0, -0.75), bevel=0.15)
    cylinder("Grass", 2.08, 0.25, grass, loc=(0, 0, -0.32), bevel=0.1)
    torus("Rim", 1.25, 0.32, dirt, loc=(0, 0, -0.18))
    cylinder("Hole", 1.12, 0.3, hole, loc=(0, 0, -0.26), bevel=0.05)
    for a, s in ((30, 0.22), (160, 0.18), (250, 0.25), (330, 0.16)):
        sphere("Rock", s, rock, loc=(math.cos(R(a)) * 1.7, math.sin(R(a)) * 1.7, -0.15), scale=(1.2, 1, 0.8))
    # arrows pointing out to both sides: the hole grows
    arrow = [(0, -0.22), (0.55, -0.22), (0.55, -0.5), (1.05, 0), (0.55, 0.5), (0.55, 0.22), (0, 0.22)]
    for side in (-1, 1):
        pts = [(x * side, z) for x, z in arrow]
        if side < 0:
            pts.reverse()
        flat_shape("Arrow", pts, 0.3, red, loc=view.at(side * 1.25, 0.95, 2.5), rot=view.facing(), bevel=0.06)
    badge(view, "2x", x=0.0, y=-1.45, size=1.6)
    return view


def build_relic_pickaxe():
    """The Relic Pickaxe: gold arms, a turquoise handle and a gold sun disc with a ruby."""
    view = View(5.2, 10, -12, -0.1)
    handle = material("RelicHandle", rgb(50, 44, 76), rough=0.35, coat=0.6)
    grip = material("RelicGrip", rgb(40, 205, 190), rough=0.3, coat=0.8)
    gold = material("RelicGold", rgb(255, 205, 60), rough=0.15, coat=1.0, metal=0.25)
    goldDark = material("RelicGoldDark", rgb(225, 150, 40), rough=0.2, coat=0.9, metal=0.25)
    ruby = material("RelicRuby", rgb(235, 40, 80), rough=0.08, coat=1.0)
    teal = material("RelicTeal", rgb(60, 235, 215), rough=0.12, coat=1.0)
    bottom, top = (-1.55, -1.75), (1.0, 1.1)
    dx, dz = top[0] - bottom[0], top[1] - bottom[1]
    length = math.hypot(dx, dz)
    ux, uz = dx / length, dz / length
    turn = math.atan2(dx, dz)
    mid = ((bottom[0] + top[0]) / 2, (bottom[1] + top[1]) / 2)
    rounded_box("Handle", (0.44, 0.44, length + 0.2), handle, loc=(mid[0], 0, mid[1]), rot=(0, turn, 0), bevel=0.2)
    rounded_box("Grip", (0.56, 0.56, 1.0), grip, loc=(bottom[0] + ux * 0.6, 0, bottom[1] + uz * 0.6), rot=(0, turn, 0), bevel=0.24)
    sphere("Pommel", 0.34, ruby, loc=(bottom[0] - ux * 0.1, 0, bottom[1] - uz * 0.1))
    # the head: a gold arc over the top of the handle, pointed at both ends
    cx, cz = top[0] - ux * 1.5, top[1] - uz * 1.5
    base = math.atan2(uz, ux)
    outer, pts, back = 2.15, [], []
    for i in range(31):
        f = i / 30
        a = base + R(-64 + 128 * f)
        thick = 0.14 + 0.75 * math.sin(math.pi * f)
        pts.append((cx + math.cos(a) * outer, cz + math.sin(a) * outer))
        back.append((cx + math.cos(a) * (outer - thick), cz + math.sin(a) * (outer - thick)))
    flat_shape("Head", pts + back[::-1], 0.6, gold, bevel=0.14)
    # the sun disc where the head meets the handle, a ruby in it and a turquoise ring
    hx, hz = top[0] - ux * 0.08, top[1] - uz * 0.08
    cylinder("Disc", 0.62, 0.62, goldDark, loc=(hx, -0.1, hz), rot=(R(90), 0, 0), bevel=0.12)
    torus("Band", 0.46, 0.06, teal, loc=(hx, -0.43, hz), rot=(R(90), 0, 0))
    sphere("Ruby", 0.32, ruby, loc=(hx, -0.48, hz), scale=(1, 0.7, 1))
    sparkle(view, -1.6, 1.4, 0.42)
    sparkle(view, 1.75, -0.7, 0.32)
    return view


def egg(name, loc, scale, gold, teal, ruby):
    """The Relic Egg: gold, two turquoise bands, a ruby on the front and one on top."""
    x, y, z = loc
    a, c = 1.25 * scale, 1.6 * scale
    sphere(name, 1.0, gold, loc=(x, y, z), scale=(a, a, c))
    for t in (-0.35, 0.42):
        r = a * math.sqrt(1 - t * t) + 0.02 * scale
        torus("Band", r, 0.09 * scale, teal, loc=(x, y, z + t * c))
    # (a "Print" name gives the gems a thin outline: a thick one smudged where they meet the shell)
    sphere("PrintRuby", 0.3 * scale, ruby, loc=(x, y - a * 1.0, z + 0.03 * c), scale=(1, 0.6, 1))
    sphere("PrintRuby", 0.2 * scale, ruby, loc=(x, y, z + c * 1.02))


def egg_materials():
    gold = material("EggGold", rgb(255, 205, 60), rough=0.14, coat=1.0, metal=0.2)
    teal = material("EggTeal", rgb(40, 210, 195), rough=0.15, coat=1.0)
    ruby = material("EggRuby", rgb(235, 40, 80), rough=0.08, coat=1.0)
    return gold, teal, ruby


def build_egg():
    view = View(4.6, 12, -14, 0.0)
    egg("Egg", (0, 0, -0.05), 1.0, *egg_materials())
    sparkle(view, -1.55, 1.25, 0.4)
    sparkle(view, 1.6, 0.9, 0.3)
    sparkle(view, 1.35, -1.45, 0.24)
    return view


def build_egg3():
    view = View(5.4, 12, -14, -0.1)
    mats = egg_materials()
    egg("Egg", (-1.3, 0.9, -0.15), 0.68, *mats)
    egg("Egg", (1.3, 0.9, -0.15), 0.68, *mats)
    egg("Egg", (0, -0.5, -0.05), 0.82, *mats)
    sparkle(view, -1.9, 1.5, 0.32)
    sparkle(view, 1.9, 1.45, 0.26)
    badge(view, "x3", x=1.4, y=-1.55, size=1.4)
    return view


ICONS = {
    "PassMoney": build_money,
    "PassSpeed": build_speed,
    "PassHoles": build_holes,
    "PassPickaxe": build_relic_pickaxe,
    "PassEgg": build_egg,
    "PassEgg3": build_egg3,
}


# ------------------------------------------------------------------------------------------
# rendering
# ------------------------------------------------------------------------------------------
def shoot(path, view, zoom=1.0):
    for o in [o for o in bpy.data.objects if o.type in ("CAMERA", "LIGHT")]:
        bpy.data.objects.remove(o, do_unlink=True)
    K.lights_and_camera(view.ortho * zoom, (view.tilt, view.turn), view.center)
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)


def put_on_background(path, colors):
    """Puts a transparent render on a round gradient background (with soft rays), in place."""
    img = bpy.data.images.load(path, check_existing=False)
    w, h = img.size
    px = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)
    ys, xs = np.mgrid[0:h, 0:w].astype(np.float32)
    dx, dy = (xs - w / 2) / (w / 2), (ys - h / 2) / (h / 2)
    r = np.sqrt(dx * dx + dy * dy)
    inner, outer = [np.array(c, dtype=np.float32) / 255 for c in colors]
    t = np.clip(r / 1.05, 0, 1)[..., None]
    bg = inner * (1 - t) + outer * t
    rays = (np.sin(np.arctan2(dy, dx) * 12) > 0.35).astype(np.float32) * np.clip(1 - r, 0, 1) * 0.12
    bg = np.clip(bg + rays[..., None], 0, 1)
    a = px[..., 3:4]
    out = np.empty_like(px)
    out[..., :3] = px[..., :3] * a + bg * (1 - a)
    out[..., 3] = 1
    result = bpy.data.images.new(os.path.basename(path), w, h, alpha=True)
    result.pixels[:] = out.ravel()
    result.filepath_raw = path
    result.file_format = "PNG"
    result.save()
    bpy.data.images.remove(img)
    bpy.data.images.remove(result)


def render(name):
    K.reset()
    K.setup_render()
    view = ICONS[name]()
    os.makedirs(OUT_ROBLOX, exist_ok=True)
    path = os.path.join(OUT, name + ".png")
    shoot(path, view)
    # the Creator Hub one: a bit of room around it, for Roblox's round crop
    roblox = os.path.join(OUT_ROBLOX, name + ".png")
    shoot(roblox, view, zoom=1.3)
    put_on_background(roblox, BACKGROUNDS[name])
    print("wrote", path, "and", roblox)


def main(names=None):
    for name in names or ICONS:
        render(name)


if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    main(args or None)
