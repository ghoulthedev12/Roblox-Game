"""Writes src/shared/MemeList.lua from meme_list_data.py (no emoji icons: the UI uses 3D models).
Run: python3 tools/memes/gen_meme_list.py"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from meme_list_data import W
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))) + "/"
REG = ["Basic", "Common", "Uncommon", "Rare", "Epic", "Legendary"]
WORLD_NAMES = {1: "Grassland Dig Pit", 2: "Frozen Ice Age", 3: "Volcanic Lava Trench", 4: "Ancient Egyptian Catacombs",
               5: "Cyber Glitch Grid", 6: "Deep Ocean Trench", 7: "Haunted Cemetery", 8: "Multiverse Glitch Void",
               9: "Quantum Dimension"}
# secret tiers in order of first appearance, with their position inside that world
secrets, pos = [], {}
for k in range(1, 10):
    n = 0
    for e in W[k]:
        if e[0] not in REG:
            n += 1
            if e[0] not in pos:
                pos[e[0]] = n
                secrets.append(e[0])
INCOME = [5000, 12000, 30000, 70000, 150000, 350000, 800000, 2000000]
CHANCE = [0.08, 0.04, 0.02, 0.01, 0.005, 0.0025, 0.0012, 0.0006]
COLORS = [(255, 90, 200), (255, 60, 90), (255, 215, 60), (120, 255, 200), (230, 40, 60), (255, 250, 200), (180, 120, 255),
          (255, 140, 40), (90, 200, 255), (200, 255, 90), (255, 0, 120), (120, 255, 255), (255, 120, 255), (150, 0, 255),
          (0, 200, 255), (255, 80, 0), (100, 255, 140), (0, 140, 255), (40, 220, 200), (0, 90, 200), (220, 255, 255),
          (160, 255, 60), (140, 60, 200), (255, 255, 255), (255, 170, 230), (80, 255, 80), (255, 200, 120), (255, 220, 0),
          (60, 0, 120), (255, 60, 160), (255, 245, 150), (0, 255, 170), (255, 255, 255)]
def lua(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'
out = ["-- MemeList (ModuleScript in ReplicatedStorage)",
       "-- Every meme in the game: 9 worlds x 20 memes, with the rarity each one has on the master list.",
       "-- Written by the asset spec (Meme Archaeologist: 3D Meme Parody Asset Spec). All names are parodies.",
       "-- Format per meme: {rarity, id, name, form, museum description}",
       "--   form = Statue | Painting | Coin | Tablet | Relic (famous memes with a built 3D figure use MemeFigures instead)",
       "", "local MemeList = {}", "",
       "-- the named secret rarities, rarest last; Income = money per second in World 1, Chance = roll weight",
       "MemeList.SecretTiers = {"]
for i, t in enumerate(secrets):
    c = COLORS[i % len(COLORS)]
    p = pos[t] - 1
    out.append('\t{Name = %s, Income = %d, Chance = %s, Color = Color3.fromRGB(%d, %d, %d)},' % (lua(t), INCOME[p], CHANCE[p], *c))
out += ["}", "", "MemeList.Worlds = {"]
for k in range(1, 10):
    out.append("\t-- WORLD %d: %s" % (k, WORLD_NAMES[k].upper()))
    out.append("\t{Name = %s, Memes = {" % lua(WORLD_NAMES[k]))
    for e in W[k]:
        out.append("\t\t{%s, %s, %s, %s, %s}," % (lua(e[0]), lua(e[1]), lua(e[2]), lua(e[3]), lua(e[5])))
    out.append("\t}},")
out += ["}", "", "return MemeList", ""]
open(ROOT + "src/shared/MemeList.lua", "w").write("\n".join(out))
print(len(secrets), secrets)
