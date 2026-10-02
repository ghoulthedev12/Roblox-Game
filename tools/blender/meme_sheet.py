"""Renders a contact sheet of one meme batch, to review a batch at a glance.
Run:  blender -b --factory-startup --python tools/blender/meme_sheet.py -- memes_batch5 [Id ...]
Writes assets/models/previews/Sheet_<batch>.png"""
import importlib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import memekit  # noqa: E402

args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
# load every batch in order first: batches share (and append) palette colors
here = os.path.dirname(os.path.abspath(__file__))
for k in range(1, 100):
    if os.path.exists(os.path.join(here, "memes_batch%d.py" % k)):
        importlib.import_module("memes_batch%d" % k)
batch = importlib.import_module(args[0])
only = set(args[1:])
builders = [b for b in batch.ALL if not only or b().name in only] if only else batch.ALL
if only:
    memekit.reset()
out = os.path.join(memekit.ROOT, "assets", "models", "previews", "Sheet_%s.png" % args[0])
memekit.sheet(builders, out, per_row=6, cell=400)
print("built sheet", out)
