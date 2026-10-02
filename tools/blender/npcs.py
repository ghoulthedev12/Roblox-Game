"""Builds the two shopkeeper characters as Blender meshes (they used to be a few primitives):
  ShopRobot   the pickaxe shop's robot: a friendly miner bot in a yellow hard hat with a
              headlamp, a TV-screen face, a hazard-striped chest, segmented arms (one waving,
              one resting a little pickaxe on the counter) and a hover thruster
  ArtDealer   the Alien Art Dealer: a tall, big-headed alien in a velvet tuxedo with a gold bow
              tie, a beret and a gold monocle on a chain, holding up a framed meme and a loupe
Each is two meshes: <Name> (palette colors) and <Name>Glow (one color, drawn as Neon).
Writes assets/models/NPCMeshes.fbx (Import 3D once; the installer moves them to
ReplicatedStorage > NPCModels), src/shared/NPCMeshData.lua (each piece's size and where its
center sits, in Roblox studs, relative to the point the character stands on, facing -Z) and a
preview in assets/models/previews/NPCs.png.
Run:  blender -b --factory-startup --python tools/blender/npcs.py"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

import memekit  # noqa: E402
from memekit import Meme, rgb  # noqa: E402

for _name, _c in [
    ("botyellow", (255, 196, 40)), ("botyellowdark", (210, 150, 20)), ("botwhite", (240, 242, 248)), ("botscreen", (22, 26, 40)),
    ("botsteel", (150, 158, 172)), ("botgun", (62, 66, 80)), ("hazard", (30, 30, 34)), ("botwood", (150, 100, 55)),
    ("velvet", (110, 40, 130)), ("velvetdark", (70, 22, 88)), ("dealerskin", (170, 225, 170)), ("dealerskindark", (110, 170, 120)),
    ("beret", (200, 40, 60)), ("goldtrim", (240, 190, 60)), ("shirt", (250, 250, 250)), ("eyeglass", (14, 12, 20)),
    ("canvas", (120, 200, 255)), ("loupe", (190, 230, 255)), ("botglow", (255, 255, 255)),
]:
    rgb(_name, *_c)

OUT_LUA = os.path.join(memekit.ROOT, "src", "shared", "NPCMeshData.lua")
GLOW = {"ShopRobot": (90, 235, 255), "ArtDealer": (255, 210, 90)}


def shop_robot():
    body, glow = Meme("ShopRobot"), Meme("ShopRobotGlow")
    # hover thruster and its glowing ring + flame
    body.lathe("botgun", [(0, 0.2), (0.7, 0.25), (1.1, 0.7), (1.2, 0.9), (0, 0.95)], (0, 0, 0), seg=32)
    glow.torus("botglow", 1.15, 0.12, (0, 0, 0.55))
    glow.lathe("botglow", [(0, -0.6), (0.55, 0.2), (0, 0.22)], (0, 0, 0), seg=20)
    # chassis: a rounded yellow pot with a hazard band
    body.lathe("botyellow", [(0, 0.9), (1.1, 0.95), (1.35, 1.6), (1.3, 2.45), (0, 2.5)], (0, 0, 0), seg=40)
    for k in range(16):
        a = k / 16 * math.tau
        body.box("hazard" if k % 2 else "botyellowdark", (0.5, 0.12, 0.3), (math.cos(a) * 1.33, math.sin(a) * 1.33, 1.75),
                 rot=(0, 25, math.degrees(a) + 90), bevel=0.02)
    # torso: a chunky rounded box with a chest screen and status lights
    body.squircle("botyellow", (2.7, 1.9, 2.0), (0, 0, 3.4), power=3.2)
    body.squircle("botscreen", (1.6, 0.12, 1.0), (0, -0.95, 3.5), power=5)
    for k, x in enumerate((-0.45, 0.0, 0.45)):
        glow.blob("botglow", (0.26, 0.1, 0.26), (x, -1.02, 3.5))
    body.box("botgun", (1.8, 0.1, 0.12), (0, -0.98, 2.85), bevel=0.02)
    for k in range(5):  # chest vents
        body.box("botgun", (0.12, 0.1, 0.45), (-0.55 + k * 0.275, -0.97, 2.62), bevel=0.02)
    body.cyl("botgun", 0.75, 0.5, (0, 0.95, 3.4), rot=(90, 0, 0), seg=24)  # battery pack
    glow.torus("botglow", 0.55, 0.06, (0, 1.22, 3.4), rot=(90, 0, 0))
    # neck and the TV head with a screen face
    body.cyl("botgun", 0.4, 0.5, (0, 0, 4.6), seg=16)
    body.squircle("botwhite", (2.7, 2.0, 2.1), (0, 0, 5.85), power=3.5)
    body.squircle("botscreen", (2.25, 0.14, 1.55), (0, -0.98, 5.8), power=6)
    for s in (-1, 1):  # big friendly screen eyes (rounded rectangles)
        glow.squircle("botglow", (0.5, 0.1, 0.62), (s * 0.48, -1.07, 5.95), power=3)
        body.cyl("botsteel", 0.32, 0.35, (s * 1.45, 0, 5.85), rot=(0, 90, 0), seg=20)  # ear bolts
        glow.torus("botglow", 0.25, 0.05, (s * 1.64, 0, 5.85), rot=(0, 90, 0))
    glow.tube("botglow", [(-0.38, -1.07, 5.42), (-0.15, -1.08, 5.3), (0.15, -1.08, 5.3), (0.38, -1.07, 5.42)], 0.06)  # smile
    # hard hat with a headlamp
    body.lathe("botyellow", [(1.55, 6.75), (1.55, 6.82), (1.15, 6.9), (1.12, 7.35), (0.75, 7.75), (0, 7.85)], (0, 0, 0), seg=40)
    body.box("botyellowdark", (0.18, 2.2, 0.85), (0, 0, 7.35), bevel=0.06)  # ridge
    body.cyl("botgun", 0.32, 0.3, (0, -1.15, 7.2), rot=(90, 0, 0), seg=20)
    glow.cyl("botglow", 0.24, 0.1, (0, -1.32, 7.2), rot=(90, 0, 0), seg=20)
    body.cyl("botsteel", 0.05, 0.6, (0.55, 0.2, 8.0), seg=8)  # antenna
    glow.blob("botglow", (0.28, 0.28, 0.28), (0.55, 0.2, 8.35))
    # arms: shoulder balls, segmented steel arms, clamp hands
    for s, (elbow, hand) in ((-1, ((-1.9, -0.9, 3.1), (-1.1, -2.4, 3.3))), (1, ((2.05, -0.4, 4.4), (2.2, -0.7, 5.7)))):
        sh = (s * 1.45, 0, 3.9)
        body.blob("botgun", (0.8, 0.8, 0.8), sh)
        body.tube("botsteel", [sh, elbow], 0.2)
        body.blob("botgun", (0.48, 0.48, 0.48), elbow)
        body.tube("botsteel", [elbow, hand], 0.18)
        for k in range(3):  # ribbed joints
            t = 0.25 + k * 0.25
            p = tuple(elbow[i] + (hand[i] - elbow[i]) * t for i in range(3))
            body.blob("botgun", (0.42, 0.42, 0.42), p)
        body.blob("botgun", (0.5, 0.5, 0.5), hand)
        for f in (-1, 1):  # clamp fingers
            body.box("botyellowdark", (0.16, 0.18, 0.5), (hand[0] + f * 0.16, hand[1] - 0.05, hand[2] + 0.35), rot=(0, f * 15, 0), bevel=0.05)
    # a little pickaxe resting under the left hand, on the counter
    body.cyl("botwood", 0.07, 1.6, (-0.9, -2.75, 3.3), rot=(0, 90, 15), seg=10)
    body.tube("botsteel", [(-1.6, -2.95, 3.0), (-1.75, -2.85, 3.3), (-1.65, -2.75, 3.65)], lambda t: 0.12 - 0.06 * abs(t - 0.5), seg=8)
    return body, glow


def art_dealer():
    body, glow = Meme("ArtDealer"), Meme("ArtDealerGlow")
    # a long velvet tuxedo coat, flared at the bottom
    body.lathe("velvet", [(0, 0), (1.5, 0), (1.45, 0.4), (1.15, 2.0), (1.05, 3.6), (1.35, 4.6), (1.0, 5.2), (0, 5.3)], (0, 0, 0), seg=40)
    body.relief("velvetdark", [(-0.75, 5.0), (0, 3.6), (0.75, 5.0), (0.45, 5.05), (0, 4.0), (-0.45, 5.05)], 0.12, (0, -1.18, 0), bevel=0.02)  # lapels
    body.relief("shirt", [(-0.42, 5.05), (0, 3.9), (0.42, 5.05)], 0.1, (0, -1.15, 0), bevel=0.0)  # shirt V
    for k in range(3):
        body.blob("goldtrim", (0.12, 0.08, 0.12), (0, -1.2, 3.4 - k * 0.45))  # buttons
    body.relief("goldtrim", [(-0.45, 0.2), (-0.05, 0), (-0.45, -0.2)], 0.12, (0, -1.22, 4.95), bevel=0.03)  # bow tie
    body.relief("goldtrim", [(0.45, 0.2), (0.05, 0), (0.45, -0.2)], 0.12, (0, -1.22, 4.95), bevel=0.03)
    glow.blob("botglow", (0.16, 0.1, 0.16), (0, -1.28, 4.95))  # the bow tie's gem
    # long neck and the big alien head
    body.cyl("dealerskin", 0.32, 1.0, (0, 0, 5.6), seg=16)
    body.blob("dealerskin", (3.2, 2.9, 2.8), (0, 0.15, 7.55))  # cranium
    body.blob("dealerskin", (1.9, 1.8, 1.8), (0, -0.25, 6.7))  # face
    body.blob("dealerskin", (1.0, 1.0, 1.0), (0, -0.45, 6.15))  # narrow chin
    for s in (-1, 1):
        body.blob("eyeglass", (0.75, 0.38, 1.05), (s * 0.48, -1.0, 7.0), rot=(0, s * 30, 0))  # big slanted eyes
        body.blob("white", (0.16, 0.08, 0.16), (s * 0.4, -1.18, 7.2))
        body.blob("dealerskindark", (0.06, 0.06, 0.06), (s * 0.08, -1.2, 6.55))
        body.cyl("dealerskin", 0.06, 0.9, (s * 0.7, 0.2, 9.0), rot=(0, s * 25, 0), seg=8)  # antennae
        glow.blob("botglow", (0.24, 0.24, 0.24), (s * 0.9, 0.2, 9.4))
    body.tube("dealerskindark", [(-0.25, -1.12, 6.22), (0, -1.16, 6.15), (0.25, -1.12, 6.24)], 0.035)  # a knowing smile
    body.torus("goldtrim", 0.42, 0.06, (0.48, -1.22, 7.0), rot=(90, 0, 0))  # the monocle
    body.cyl("loupe", 0.38, 0.03, (0.48, -1.22, 7.0), rot=(90, 0, 0), seg=24)
    body.tube("goldtrim", [(0.85, -1.15, 6.85), (1.0, -1.1, 6.0), (0.7, -1.2, 5.1)], 0.025, seg=6)  # monocle chain
    body.lathe("beret", [(0, 0), (1.4, 0.02), (1.5, 0.25), (0.9, 0.55), (0, 0.6)], (-0.2, 0.2, 8.75), rot=(-8, -14, 0), seg=32)  # beret
    body.cyl("beret", 0.06, 0.25, (-0.25, 0.25, 9.4), seg=8)
    # arms: one holds up a framed meme, the other a magnifying loupe
    for s, (elbow, hand) in ((-1, ((-1.7, -0.6, 4.0), (-1.35, -1.6, 5.2))), (1, ((1.75, -0.5, 3.9), (1.5, -1.6, 4.7)))):
        sh = (s * 1.05, 0, 4.7)
        body.tube("velvet", [sh, elbow], 0.26)
        body.tube("velvet", [elbow, hand], 0.22)
        body.blob("shirt", (0.38, 0.38, 0.3), tuple(hand[i] + (elbow[i] - hand[i]) * 0.15 for i in range(3)))  # cuff
        body.blob("dealerskin", (0.32, 0.3, 0.36), hand)
        for f in (-1, 0, 1):
            body.blob("dealerskin", (0.09, 0.09, 0.4), (hand[0] + f * 0.09, hand[1] - 0.05, hand[2] + 0.28))
    # the framed meme (left hand)
    body.box("goldtrim", (1.5, 0.12, 1.2), (-1.35, -1.85, 5.85), rot=(0, 8, 0), bevel=0.04)
    body.box("canvas", (1.2, 0.14, 0.92), (-1.35, -1.88, 5.85), rot=(0, 8, 0), bevel=0.0)
    body.blob("botyellow", (0.4, 0.06, 0.4), (-1.35, -1.97, 5.85))  # a little smiley on it
    # the loupe (right hand)
    body.cyl("velvetdark", 0.07, 0.6, (1.5, -1.7, 5.1), seg=8)
    body.torus("goldtrim", 0.3, 0.06, (1.5, -1.75, 5.55), rot=(90, 0, 0))
    body.cyl("loupe", 0.26, 0.04, (1.5, -1.75, 5.55), rot=(90, 0, 0), seg=20)
    return body, glow


def to_studs(v):
    """Blender (x, y, z) -> where it ends up in Roblox relative to the stand point, facing -Z."""
    return (-v[0], v[2], v[1])


def finish_piece(m):
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
    center, size = (lo + hi) / 2, hi - lo
    me.transform(Matrix.Translation(-center))
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    if tris > 18000:
        mod = obj.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = 18000 / tris
        bpy.ops.object.modifier_apply(modifier=mod.name)
    mod = obj.modifiers.new("Tri", "TRIANGULATE")
    bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.materials.clear()
    obj.data.materials.append(memekit.palette_material())
    return obj, {"Size": (size.x, size.z, size.y), "Center": to_studs(center), "Home": center}


def main():
    memekit.reset()
    data, objs = {}, []
    for i, build in enumerate((shop_robot, art_dealer)):
        body, glow = build()
        b_obj, b_info = finish_piece(body)
        g_obj, g_info = finish_piece(glow)
        data[body.name] = {"Body": b_info, "Glow": g_info, "GlowColor": GLOW[body.name]}
        for o in (b_obj, g_obj):
            if o:
                objs.append(o)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    path = os.path.join(memekit.OUT, "NPCMeshes.fbx")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="COPY", embed_textures=True,
                             bake_space_transform=True)
    # the lua data
    def v3(t):
        return "Vector3.new(%.3f, %.3f, %.3f)" % tuple(t)
    lines = ["-- NPCMeshData (ModuleScript in ReplicatedStorage)",
             "-- Written by tools/blender/npcs.py: the shopkeeper characters. File > Import 3D of",
             "-- assets/models/NPCMeshes.fbx + the installer put the meshes in ReplicatedStorage > NPCModels",
             "-- (<Name> and <Name>Glow). Size = each mesh's size; Center = where its center sits, in studs,",
             "-- from the point the character stands on (it faces -Z).",
             "return {"]
    for name, d in data.items():
        b, g = d["Body"], d["Glow"]
        parts = ["Size = %s" % v3(b["Size"]), "Center = %s" % v3(b["Center"])]
        if g:
            parts += ["GlowSize = %s" % v3(g["Size"]), "GlowCenter = %s" % v3(g["Center"])]
        parts.append("GlowColor = Color3.fromRGB(%d, %d, %d)" % d["GlowColor"])
        lines.append("\t%s = {%s}," % (name, ", ".join(parts)))
    lines.append("}")
    with open(OUT_LUA, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    # preview: put the pieces back where they were built, side by side, glow lit
    for o in objs:
        base = o.name.replace("Glow", "")
        info = data[base]["Glow" if o.name.endswith("Glow") else "Body"]
        o.location = info["Home"] + Vector((0 if base == "ShopRobot" else 5.5, 0, 0))
        if o.name.endswith("Glow"):
            mat = bpy.data.materials.new("GlowMat")
            mat.use_nodes = True
            bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
            c = [x / 255 for x in data[base]["GlowColor"]] + [1]
            bsdf.inputs["Base Color"].default_value = c
            for key in ("Emission Color", "Emission"):
                if key in bsdf.inputs:
                    bsdf.inputs[key].default_value = c
                    break
            bsdf.inputs["Emission Strength"].default_value = 2.5
            o.data.materials.clear()
            o.data.materials.append(mat)
    bpy.context.view_layer.update()
    memekit.render(objs, os.path.join(memekit.OUT, "previews", "NPCs.png"), size=(900, 700), angle=20)
    print("wrote", path, "and", OUT_LUA)


main()
