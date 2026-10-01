"""Builds every meme sculpture, exports one .fbx per meme plus MemeMeshes.fbx (all of them,
for one Import 3D in Studio), and renders preview PNGs.
Run:  python tools/blender/build_memes.py      (with the bpy package installed)"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy  # noqa: E402
import memekit  # noqa: E402
import memes_batch1  # noqa: E402
import memes_batch2  # noqa: E402
import memes_batch3  # noqa: E402

BUILDERS = memes_batch1.ALL + memes_batch2.ALL + memes_batch3.ALL
PREVIEW = os.path.join(memekit.ROOT, "assets", "models", "previews")


def main():
    only = sys.argv[1:]
    os.makedirs(PREVIEW, exist_ok=True)
    built = []
    for build in BUILDERS:
        memekit.reset()
        obj = build().finish()
        if only and obj.name not in only:
            continue
        memekit.export(obj, obj.name)
        memekit.render([obj], os.path.join(PREVIEW, obj.name + ".png"))
        tris = len(obj.data.polygons)
        print("built", obj.name, tris, "tris")
        built.append(obj.name)
    # one combined file for a single Import 3D in Studio
    memekit.reset()
    objs = []
    for i, build in enumerate(BUILDERS):
        obj = build().finish()
        obj.location.x = i * 6
        objs.append(obj)
    bpy.ops.object.select_all(action="SELECT")
    path = os.path.join(memekit.OUT, "MemeMeshes.fbx")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
                             axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE", path_mode="COPY", embed_textures=True,
                             bake_space_transform=True)
    print("wrote", path, "with", len(objs), "memes")


main()
