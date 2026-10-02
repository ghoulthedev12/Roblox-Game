"""Builds every meme sculpture (all 180, from memes_batch1..13) and exports them for Studio.
Writes assets/models/MemeMeshes.fbx (every meme, for one File > Import 3D; the installer then
moves them into ReplicatedStorage > MemeMeshes) and a contact sheet per batch in
assets/models/previews (Sheet_memes_batchN.png).
Run:  blender -b --factory-startup --python tools/blender/build_memes.py [-- --no-sheets]"""
import importlib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402
import memekit  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
PREVIEW = os.path.join(memekit.ROOT, "assets", "models", "previews")
BATCHES = []
for k in range(1, 100):  # every batch, in order (batches append palette colors in this order)
    if os.path.exists(os.path.join(HERE, "memes_batch%d.py" % k)):
        BATCHES.append(importlib.import_module("memes_batch%d" % k))
BUILDERS = [b for batch in BATCHES for b in batch.ALL]


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(PREVIEW, exist_ok=True)
    if "--no-sheets" not in args:
        for batch in BATCHES:
            memekit.sheet(batch.ALL, os.path.join(PREVIEW, "Sheet_%s.png" % batch.__name__), per_row=6, cell=400)
    # one combined file for a single Import 3D in Studio
    memekit.reset()
    objs, names, tris = [], set(), 0
    for i, build in enumerate(BUILDERS):
        obj = build().finish()
        if obj.name in names:
            raise SystemExit("two memes are both called " + obj.name)
        names.add(obj.name)
        obj.location = ((i % 20) * 6, (i // 20) * 6, 0)
        tris += len(obj.data.polygons)
        objs.append(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    path = os.path.join(memekit.OUT, "MemeMeshes.fbx")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="COPY", embed_textures=True,
                             bake_space_transform=True)
    print("wrote", path, "with", len(objs), "memes,", tris, "triangles")


main()
