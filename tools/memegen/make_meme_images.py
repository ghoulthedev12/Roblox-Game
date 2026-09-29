"""Builds one 256x256 meme picture per artifact into assets/meme_images/<ArtifactId>.png.

Each picture is an original composition: an era-themed background, the artifact's emoji drawn
big as a "sticker" (Noto Color Emoji art, Apache 2.0), meme extras (deal-with-it shades, halos,
sparkles...) and classic white top/bottom captions in Anton (SIL OFL). See captions.py.

Needs: Python 3, Node.js with playwright-core, and a Chromium + the Noto Color Emoji font.
Run from the repo root:  python3 tools/memegen/make_meme_images.py [ArtifactId ...]
"""
import html, json, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "assets", "meme_images")
sys.path.insert(0, HERE)
from captions import CAPTIONS  # noqa: E402

art = open(os.path.join(ROOT, "src/shared/ArtifactData.lua"), encoding="utf-8").read()
icons = dict(re.findall(r'(\w+) = "([^"]+)"', open(os.path.join(ROOT, "src/shared/ArtifactIcons.lua"), encoding="utf-8").read()))
# (area index, rarity, id) in file order
area_blocks = re.split(r"\n\t-- (\d+)\. ", art)
items = []
for i in range(1, len(area_blocks), 2):
    area = int(area_blocks[i])
    for rarity, aid in re.findall(r'\{"(C|U|R|E|L|M|D|CE|T)", "(\w+)"', area_blocks[i + 1]):
        items.append((area, rarity, aid))

def era(area):
    if area <= 7: return "brainrot"
    if area <= 14: return "golden"
    if area <= 20: return "paleo"
    return "abyss"

RARITY_GLOW = {"C": "#bdbdbd", "U": "#55c855", "R": "#3c8cff", "E": "#aa50ff", "L": "#ffaa00",
               "M": "#ff3c5a", "D": "#fff096", "CE": "#78ffff", "T": "#ffffff"}

def extras_html(extras):
    out = []
    for e in extras:
        if e == "shades":
            out.append('<div class="shades"></div>')
        elif e == "crown":
            out.append('<div class="stk" style="left:150px;top:44px;font-size:58px;transform:rotate(22deg)">👑</div>')
        elif e == "sparkle":
            out.append('<div class="stk" style="left:18px;top:62px;font-size:34px">✨</div>'
                       '<div class="stk" style="left:200px;top:150px;font-size:30px">✨</div>')
        elif e == "fire":
            out.append('<div class="stk" style="left:6px;top:150px;font-size:52px">🔥</div>'
                       '<div class="stk" style="left:196px;top:150px;font-size:52px">🔥</div>')
        elif e == "tears":
            out.append('<div class="stk" style="left:52px;top:118px;font-size:34px;transform:rotate(-20deg)">💧</div>'
                       '<div class="stk" style="left:172px;top:122px;font-size:34px;transform:rotate(20deg)">💧</div>')
        elif e == "rainbow":
            out.append('<div class="stk back" style="left:-46px;top:76px;font-size:118px">🌈</div>')
        elif e == "hearts":
            out.append('<div class="stk" style="left:14px;top:60px;font-size:40px;transform:rotate(-15deg)">💕</div>'
                       '<div class="stk" style="left:196px;top:70px;font-size:34px;transform:rotate(15deg)">💖</div>')
        elif e == "halo":
            out.append('<div class="halo"></div>')
        elif e == "motion":
            out.append('<div class="motion"></div>')
        elif e.startswith("bubble:"):
            out.append('<div class="bubble">%s</div>' % html.escape(e[7:]))
        elif e == "stars":
            out.append('<div class="stk" style="left:22px;top:170px;font-size:26px">⭐</div>'
                       '<div class="stk" style="left:206px;top:64px;font-size:24px">⭐</div>'
                       '<div class="stk" style="left:190px;top:196px;font-size:18px">⭐</div>')
        elif e == "glitch":
            out.append('<div class="scan"></div>')
        elif e == "sweat":
            out.append('<div class="stk" style="left:176px;top:62px;font-size:38px">💦</div>')
        elif e == "zzz":
            out.append('<div class="stk" style="left:180px;top:58px;font-size:38px">💤</div>')
        elif e == "100":
            out.append('<div class="stk" style="left:184px;top:132px;font-size:44px;transform:rotate(12deg)">💯</div>')
    return "".join(out)

def card(area, rarity, aid):
    top, bottom, extras = CAPTIONS[aid]
    emoji = icons.get(aid, "❓")
    glitch = "glitch" in extras
    subject = '<div class="subject">%s</div>' % emoji
    if glitch:
        subject = ('<div class="subject ghost" style="left:-5px;filter:none;opacity:.55;color:transparent;text-shadow:0 0 0 #ff2d6b">%s</div>'
                   '<div class="subject ghost" style="left:5px;filter:none;opacity:.55;color:transparent;text-shadow:0 0 0 #2de0ff">%s</div>' % (emoji, emoji)) + subject
    return ('<div class="card %s" id="%s" style="--hue:%ddeg;--glow:%s">'
            '<div class="bg"></div><div class="rays"></div><div class="spot"></div>%s%s'
            '<div class="cap top">%s</div><div class="cap bottom">%s</div></div>') % (
        era(area), aid, (area * 37) % 360, RARITY_GLOW[rarity], subject, extras_html(extras),
        html.escape(top), html.escape(bottom))

CSS = r"""
@font-face { font-family: Anton; src: url(fonts/Anton-Regular.ttf); }
body { margin: 0; background: #222; display: flex; flex-wrap: wrap; gap: 4px; width: 2700px; }
.card { width: 256px; height: 256px; position: relative; overflow: hidden; font-family: Anton, Impact, sans-serif; }
.bg, .rays, .spot { position: absolute; inset: 0; }
.brainrot .bg { background: linear-gradient(140deg, #7b3cff, #ff4fb8 55%, #3fd6ff); filter: hue-rotate(var(--hue)); }
.brainrot .bg::after { content: ""; position: absolute; inset: 0; background: radial-gradient(circle, rgba(255,255,255,.35) 1.5px, transparent 2.5px) 0 0/22px 22px; }
.golden .bg { background: repeating-conic-gradient(from 0deg at 50% 55%, #ff6b6b 0 45deg, #ffd166 45deg 90deg, #6be38a 90deg 135deg, #4dabff 135deg 180deg); filter: hue-rotate(var(--hue)) saturate(.85); }
.paleo .bg { background: linear-gradient(#10124a, #3a1f7a 70%, #7b2cbf); }
.paleo .bg::before { content: ""; position: absolute; inset: 0; background: radial-gradient(circle, #fff 1px, transparent 1.6px) 0 0/28px 28px, radial-gradient(circle, rgba(255,255,255,.6) 1px, transparent 1.6px) 14px 14px/28px 28px; }
.paleo .bg::after { content: ""; position: absolute; left: -30%; right: -30%; bottom: -10px; height: 110px; transform: perspective(160px) rotateX(55deg);
  background: repeating-linear-gradient(90deg, rgba(0,255,220,.8) 0 2px, transparent 2px 26px), repeating-linear-gradient(0deg, rgba(0,255,220,.8) 0 2px, transparent 2px 22px); filter: hue-rotate(var(--hue)); }
.abyss .bg { background: radial-gradient(circle at 30% 30%, #7b3cff, transparent 55%), radial-gradient(circle at 75% 70%, #13c2c2, transparent 55%), #0b0620; }
.abyss .bg::after { content: ""; position: absolute; inset: 0; background: radial-gradient(circle, #fff 1px, transparent 1.7px) 0 0/19px 23px; opacity: .8; }
.rays { background: repeating-conic-gradient(from 0deg at 50% 56%, rgba(255,255,255,.16) 0 9deg, transparent 9deg 18deg); }
.golden .rays { display: none; }
.spot { background: radial-gradient(circle at 50% 56%, var(--glow) 0, rgba(255,255,255,0) 58%); opacity: .75; }
.subject { position: absolute; z-index: 2; left: 0; right: 0; top: 50px; text-align: center; font-family: "Noto Color Emoji"; font-size: 142px; line-height: 170px;
  filter: drop-shadow(4px 0 0 #fff) drop-shadow(-4px 0 0 #fff) drop-shadow(0 4px 0 #fff) drop-shadow(0 -4px 0 #fff) drop-shadow(0 8px 6px rgba(0,0,0,.45)); }
.stk { position: absolute; font-family: "Noto Color Emoji"; line-height: 1; filter: drop-shadow(0 2px 2px rgba(0,0,0,.4)); z-index: 3; }
.stk.back { z-index: 1; }
.cap { position: absolute; left: 6px; right: 6px; text-align: center; color: #fff; text-transform: uppercase; letter-spacing: .5px;
  -webkit-text-stroke: 6px #000; paint-order: stroke fill; line-height: 1.02; z-index: 5; font-size: 34px; white-space: nowrap; }
.cap.top { top: 6px; } .cap.bottom { bottom: 6px; }
.halo { position: absolute; left: 78px; top: 44px; width: 100px; height: 26px; border-radius: 50%; border: 7px solid #ffe066; box-shadow: 0 0 14px #ffe066; }
.motion { position: absolute; left: 0; top: 70px; width: 70px; height: 120px; background: repeating-linear-gradient(0deg, rgba(255,255,255,.85) 0 4px, transparent 4px 16px); -webkit-mask: linear-gradient(90deg, transparent, #000); }
.bubble { position: absolute; right: 10px; top: 58px; background: #fff; border: 4px solid #000; border-radius: 22px; padding: 2px 12px; font-size: 26px; color: #000; z-index: 6; }
.bubble::after { content: ""; position: absolute; left: 14px; bottom: -14px; border: 8px solid transparent; border-top: 10px solid #000; }
.scan { position: absolute; inset: 0; background: repeating-linear-gradient(0deg, rgba(0,0,0,.14) 0 2px, transparent 2px 5px); z-index: 4; }
.shades { position: absolute; left: 64px; top: 104px; width: 128px; height: 30px; z-index: 3; transform: rotate(-4deg);
  background:
    linear-gradient(#000,#000) 0 0/128px 8px no-repeat,
    linear-gradient(#000,#000) 8px 8px/44px 14px no-repeat, linear-gradient(#000,#000) 76px 8px/44px 14px no-repeat,
    linear-gradient(#000,#000) 16px 22px/28px 8px no-repeat, linear-gradient(#000,#000) 84px 22px/28px 8px no-repeat,
    linear-gradient(#fff,#fff) 14px 10px/8px 5px no-repeat, linear-gradient(#fff,#fff) 82px 10px/8px 5px no-repeat; }
"""

def main():
    only = set(sys.argv[1:])
    chosen = [i for i in items if not only or i[2] in only]
    os.makedirs(OUT, exist_ok=True)
    page = os.path.join(HERE, "_sheet.html")
    with open(page, "w", encoding="utf-8") as f:
        f.write('<!doctype html><meta charset="utf-8"><style>%s</style>%s' % (CSS, "".join(card(*i) for i in chosen)))
        f.write("""<script>
document.fonts.ready.then(() => {
  for (const cap of document.querySelectorAll('.cap')) {   // shrink long captions to fit
    let size = 34;
    while (cap.scrollWidth > cap.clientWidth && size > 12) { size -= 1; cap.style.fontSize = size + 'px'; }
  }
  document.title = 'ready';
});
</script>""")
    shoot = os.path.join(HERE, "_shoot.js")
    with open(shoot, "w", encoding="utf-8") as f:
        f.write("""const { chromium } = require('playwright-core');
(async () => {
  const b = await chromium.launch({executablePath: process.env.CHROMIUM || '/opt/pw-browsers/chromium'});
  const p = await b.newPage({viewport: {width: 2700, height: 1200}});
  await p.goto('file://' + %s);
  await p.waitForFunction(() => document.title === 'ready');
  const ids = %s;
  for (const id of ids) {
    await p.locator('#' + id).screenshot({path: %s + '/' + id + '.png'});
  }
  await b.close();
})();""" % (json.dumps(page), json.dumps([i[2] for i in chosen]), json.dumps(OUT)))
    env = dict(os.environ, NODE_PATH=os.environ.get("NODE_PATH", ""))
    subprocess.run(["node", shoot], check=True, env=env)
    os.remove(page)
    os.remove(shoot)
    print("wrote %d pictures to %s" % (len(chosen), OUT))

if __name__ == "__main__":
    main()
