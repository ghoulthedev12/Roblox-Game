"""Batch 8 of the meme sculptures: World 4.
Conventions: z is up, the model faces -y, about 4-5 studs tall. All original parody designs."""
import math

from memekit import Meme, rgb
import memeparts as mp

for _name, _c in [
    ("labblack", (40, 36, 34)), ("labnose", (20, 18, 18)), ("phonered", (200, 40, 40)), ("assistblue", (70, 130, 230)),
    ("merchant", (230, 175, 120)), ("turban", (240, 200, 60)), ("rope", (190, 150, 90)), ("bomb", (40, 40, 60)),
    ("lampgold", (230, 180, 60)), ("bark", (110, 75, 45)), ("leaf", (70, 160, 70)), ("leaflight", (130, 210, 90)),
    ("panel1", (250, 220, 170)), ("panel2", (160, 130, 110)), ("panel3", (30, 26, 30)), ("speaker", (35, 35, 40)),
    ("cone", (255, 120, 30)), ("pipe", (170, 175, 185)), ("tracksuit", (240, 120, 40)), ("lawyertie", (230, 60, 140)),
    ("ohio", (120, 90, 140)), ("cornstalk", (200, 190, 80)), ("whistle", (220, 220, 230)), ("lanyard", (220, 40, 60)),
    ("film", (30, 30, 34)),
]:
    rgb(_name, *_c)


def yes_no_lab_dog():
    m = Meme("YesNoLabDog")
    # a black lab sitting at a side table, holding an old phone to its ear: yes, this is dog
    m.squircle("wood", (1.4, 1.2, 0.1), (-1.15, 0, 1.6), power=6)
    m.cyl("wood", 0.08, 1.6, (-1.15, 0, 0.8), seg=10)
    m.cyl("wood", 0.5, 0.06, (-1.15, 0, 0.03), seg=20)
    m.squircle("phonered", (0.8, 0.6, 0.35), (-1.2, 0, 1.82), power=3)  # rotary phone base
    m.cyl("white", 0.22, 0.04, (-1.2, -0.25, 1.95), rot=(70, 0, 0), seg=20)
    m.tube("black", [(-0.9, 0, 1.85), (-0.5, -0.3, 1.6), (0.2, -0.4, 2.3), (0.5, -0.2, 3.1)], 0.03, seg=6)  # cord
    # the dog
    m.squircle("labblack", (1.5, 1.4, 1.6), (0.4, 0.2, 1.1), power=2.2)  # sitting body
    m.blob("labblack", (0.85, 0.8, 0.7), (0.4, 0.2, 2.1))  # chest
    for s in (-1, 1):
        m.tube("labblack", [(0.4 + s * 0.35, -0.2, 1.4), (0.4 + s * 0.35, -0.45, 0.3)], 0.17)
        m.squircle("labblack", (0.35, 0.45, 0.2), (0.4 + s * 0.35, -0.55, 0.1), power=2.5)
    m.tube("labblack", [(0.4, 0.95, 0.5), (0.9, 1.2, 0.4), (1.3, 1.1, 0.6)], lambda t: 0.15 - 0.08 * t)  # tail
    m.squircle("labblack", (1.2, 1.15, 1.05), (0.4, -0.05, 3.05), power=2.3)  # head
    m.squircle("labblack", (0.7, 0.8, 0.55), (0.4, -0.6, 2.85), power=2.4)  # snout
    m.blob("labnose", (0.28, 0.18, 0.2), (0.4, -1.0, 2.95))
    m.tube("mouth", [(0.25, -0.95, 2.7), (0.4, -0.97, 2.68), (0.55, -0.95, 2.7)], 0.02)
    for s in (-1, 1):
        m.eye((0.4 + s * 0.25, -0.55, 3.25), (0.22, 0.12, 0.22), iris="hairbrown", pupil="black")
        m.blob("labblack", (0.3, 0.2, 0.75), (0.4 + s * 0.6, 0.0, 2.95), rot=(0, s * 10, 0))  # floppy ears
    # paw holding the handset to its ear
    m.tube("labblack", [(0.0, 0.0, 2.2), (-0.15, -0.35, 2.75), (-0.05, -0.3, 3.1)], 0.15)
    m.squircle("phonered", (0.2, 0.25, 0.9), (-0.1, -0.2, 3.15), rot=(0, -20, 0), power=2.6)
    m.text("white", "YES?", (1.3, -0.4, 4.0), size=0.36, depth=0.05)
    return m


def assistant_sam():
    m = Meme("AssistantSam")
    # a cheerful phone-assistant girl waving from a giant phone screen
    m.squircle("ink", (2.4, 0.3, 4.2), (0, 0.4, 2.2), power=8)  # the phone behind her
    m.squircle("assistblue", (2.15, 0.31, 3.8), (0, 0.38, 2.25), power=10)
    m.cyl("gray", 0.08, 0.32, (0, 0.2, 4.05), rot=(90, 0, 0), seg=10)
    mp.person(m, skin="skin", shirt="white", pants="navy", shoes="sneaker", hair="hairbrown", hair_style="long",
              expr="open", face_kw={"blush": True, "iris": "assistblue"}, y=-0.2,
              arms={"r": ((0.95, -0.35, 3.1), (1.0, -0.4, 3.75)), "l": ((-0.85, -0.2, 2.3), (-0.5, -0.5, 2.0))})
    m.squircle("assistblue", (1.1, 0.7, 0.4), (0, -0.2, 1.85), power=3)  # skirt
    for k in range(3):  # little chat bubbles
        m.squircle("white", (0.5, 0.08, 0.3), (-1.4, -0.3, 3.4 + k * 0.45), power=3)
    return m


def lamp_oil_merchant():
    m = Meme("LampOilMerchant")
    # a round merchant behind his counter with lamp oil, rope and bombs: it's yours, my friend
    m.squircle("wood", (3.2, 1.0, 1.4), (0, -0.4, 0.7), power=5)  # counter
    m.squircle("lightwood", (3.4, 1.15, 0.12), (0, -0.4, 1.45), power=5)
    # the merchant
    m.squircle("merchant", (2.0, 1.4, 1.8), (0, 0.5, 2.3), power=2.2)  # big round body
    m.squircle("red", (2.05, 1.42, 0.5), (0, 0.5, 1.6), power=2.6)  # sash
    m.blob("merchant", (1.4, 1.2, 1.15), (0, 0.4, 3.55))  # head
    m.lathe("turban", [(0, 0), (0.75, 0.0), (0.78, 0.3), (0.6, 0.55), (0, 0.65)], (0, 0.42, 3.85))
    m.blob("red", (0.22, 0.16, 0.22), (0, -0.2, 4.15))  # turban jewel
    for s in (-1, 1):
        m.eye((s * 0.25, -0.12, 3.7), (0.22, 0.12, 0.18), iris="black", lid="merchant", lid_drop=0.4)
        m.tube("hairblack", [(0, -0.2, 3.38), (s * 0.35, -0.2, 3.35), (s * 0.55, -0.1, 3.5)], 0.06)  # curly mustache
        m.tube("merchant", [(s * 0.9, 0.4, 2.8), (s * 1.0, -0.2, 2.0), (s * 0.6, -0.5, 1.7)], 0.2)  # arms on counter
        m.blob("merchant", (0.35, 0.3, 0.25), (s * 0.55, -0.55, 1.65))
    m.blob("lips", (0.45, 0.2, 0.22), (0, -0.15, 3.15))  # big lips
    # wares on the counter
    m.lathe("lampgold", [(0, 0), (0.2, 0), (0.28, 0.12), (0.12, 0.25), (0.05, 0.4), (0, 0.42)], (-1.1, -0.5, 1.5))
    m.tube("lampgold", [(-0.86, -0.5, 1.62), (-0.7, -0.5, 1.72), (-0.6, -0.5, 1.75)], 0.04)
    for k in range(4):
        m.torus("rope", 0.25 - k * 0.02, 0.06, (0.0, -0.6, 1.58 + k * 0.08))
    m.blob("bomb", (0.42, 0.42, 0.42), (1.1, -0.5, 1.72))
    m.tube("rope", [(1.1, -0.5, 1.92), (1.15, -0.5, 2.05), (1.25, -0.5, 2.1)], 0.025)
    m.blob("orange", (0.08, 0.08, 0.08), (1.27, -0.5, 2.12))
    m.text("darkbrown", "MMMM", (0, -0.95, 0.9), size=0.3, depth=0.03)
    return m


def wise_mystical_tree():
    m = Meme("WiseMysticalTree")
    # an old tree with a kind face in its bark, glowing eyes and a leafy crown
    m.lathe("bark", [(0, 0), (1.1, 0), (0.8, 0.3), (0.6, 0.9), (0.55, 2.0), (0.7, 2.6), (0, 2.7)], (0, 0, 0), seg=24)
    for k in range(5):  # roots
        a = k / 5 * math.tau
        m.tube("bark", [(math.cos(a) * 0.5, math.sin(a) * 0.5, 0.4), (math.cos(a) * 1.0, math.sin(a) * 1.0, 0.1)], lambda t: 0.2 - 0.12 * t)
    for k, (dx, dz, r) in enumerate([(0, 3.7, 1.5), (-0.95, 3.2, 1.0), (0.95, 3.25, 1.05), (-0.5, 4.2, 0.95), (0.55, 4.25, 0.95), (0, 3.0, 1.1)]):
        m.blob("leaf" if k % 2 else "leaflight", (r * 1.4, r * 1.2, r * 1.1), (dx, 0.2, dz))
    for s in (-1, 1):  # glowing eyes and heavy brows in the trunk
        m.blob("black", (0.32, 0.15, 0.28), (s * 0.22, -0.55, 1.95))
        m.blob("yellow", (0.14, 0.08, 0.12), (s * 0.22, -0.62, 1.95))
        m.tube("darkbrown", [(s * 0.05, -0.6, 2.15), (s * 0.4, -0.58, 2.25)], 0.06)
    m.blob("darkbrown", (0.18, 0.16, 0.3), (0, -0.62, 1.65))  # knot nose
    m.blob("mouth", (0.4, 0.12, 0.3), (0, -0.58, 1.25))  # speaking mouth
    for k in range(6):  # beard of moss
        m.tube("leaf", [(-0.3 + k * 0.12, -0.6, 1.1), (-0.32 + k * 0.12, -0.62, 0.7 - (k % 2) * 0.15)], 0.04)
    m.text("leaflight", "ASK ME", (0, -0.9, 2.65), size=0.24, depth=0.04)
    return m


def uncanny_super_dad():
    m = Meme("UncannySuperDad")
    # a three-panel framed strip: a square-jawed dad smiling, then uneasy, then pitch black
    m.squircle("gold", (4.2, 0.25, 2.0), (0, 0, 2.3), power=8)
    for k, (bg, skin) in enumerate([("sky", "panel1"), ("gray", "panel2"), ("black", "panel3")]):
        x = -1.35 + k * 1.35
        m.squircle(bg, (1.22, 0.26, 1.7), (x, -0.02, 2.3), power=10)
        y = -0.18
        m.squircle(skin, (0.75, 0.15, 0.95), (x, y, 2.35), power=3)  # square-jawed face
        m.squircle("hairblond" if k < 2 else "panel3", (0.78, 0.17, 0.3), (x, y + 0.01, 2.78), power=3)
        if k == 0:
            for s in (-1, 1):
                m.blob("black", (0.1, 0.05, 0.1), (x + s * 0.18, y - 0.08, 2.45))
            m.tube("mouth", [(x - 0.2, y - 0.08, 2.12), (x, y - 0.09, 2.05), (x + 0.2, y - 0.08, 2.12)], 0.03)
        elif k == 1:
            for s in (-1, 1):
                m.blob("black", (0.12, 0.05, 0.06), (x + s * 0.18, y - 0.08, 2.45))
            m.tube("mouth", [(x - 0.2, y - 0.08, 2.08), (x + 0.2, y - 0.08, 2.1)], 0.025)
        else:
            for s in (-1, 1):
                m.blob("white", (0.1, 0.05, 0.1), (x + s * 0.18, y - 0.08, 2.45))  # just two white eyes
    for sx in (-1, 1):  # standing legs of the frame
        m.box("gold", (0.25, 0.6, 1.4), (sx * 1.8, 0.1, 0.7), bevel=0.05)
    return m


def phonk_eyebrow_speaker():
    m = Meme("PhonkEyebrowSpeaker")
    # a speaker box with a face: one eyebrow cranked way up while the bass rings pulse out
    m.squircle("speaker", (2.2, 1.6, 3.4), (0, 0, 1.75), power=6)
    m.cyl("darkgray", 0.85, 0.1, (0, -0.8, 1.2), rot=(90, 0, 0), seg=40)  # woofer
    m.cyl("black", 0.55, 0.12, (0, -0.82, 1.2), rot=(90, 0, 0), seg=32)
    m.blob("gray", (0.4, 0.2, 0.4), (0, -0.85, 1.2))
    for s in (-1, 1):  # tweeters as eyes
        m.cyl("darkgray", 0.3, 0.1, (s * 0.5, -0.8, 2.75), rot=(90, 0, 0), seg=24)
        m.blob("white", (0.4, 0.15, 0.4), (s * 0.5, -0.85, 2.75))
        m.blob("black", (0.2, 0.1, 0.2), (s * 0.5, -0.92, 2.72))
    m.box("black", (0.55, 0.12, 0.12), (-0.5, -0.82, 3.1), bevel=0.04)  # normal brow
    m.box("black", (0.55, 0.12, 0.12), (0.5, -0.82, 3.35), rot=(0, -25, 0), bevel=0.04)  # the raised one
    for k in range(3):  # bass rings
        m.torus("hotpink", 1.1 + k * 0.3, 0.035, (0, -1.0 - k * 0.15, 1.2), rot=(90, 0, 0))
    m.text("hotpink", "PHONK", (0, -0.82, 0.35), size=0.3, depth=0.03)
    return m


def clanging_pipe():
    m = Meme("ClangingPipe")
    # a dented steel pipe bouncing on the floor with a giant comic CLANG burst
    m.squircle("tile", (3.6, 2.0, 0.12), (0, 0, 0.06), power=6)
    m.cyl("pipe", 0.22, 3.0, (0, 0, 0.55), rot=(0, 75, 10), seg=20)
    m.torus("steel", 0.23, 0.05, (-1.3, -0.25, 0.18), rot=(0, 75, 10))
    m.torus("steel", 0.23, 0.05, (1.3, 0.25, 0.92), rot=(0, 75, 10))
    burst = []
    for i in range(24):
        a = i / 24 * math.tau
        r = 1.5 if i % 2 == 0 else 1.0
        burst.append((math.cos(a) * r * 1.2, math.sin(a) * r * 0.85))
    m.relief("yellow", burst, 0.15, (0, 0.3, 2.9), bevel=0.03)
    m.relief("orange", [(x * 0.8, z * 0.8) for x, z in burst], 0.17, (0, 0.28, 2.9), bevel=0.02)
    m.text("red", "CLANG!", (0, 0.16, 2.9), size=0.6, depth=0.08)
    for k in range(4):  # motion lines
        m.box("white", (0.05, 0.05, 0.35), (-1.6 + k * 0.25, -0.2, 1.3 + (k % 2) * 0.2), rot=(0, 20, 0), bevel=0.02)
    return m


def better_call_paul():
    m = Meme("BetterCallPaul")
    # a fast-talking lawyer in a loud tie, finger raised, on a spinning ad turntable
    m.cyl("gold", 1.3, 0.2, (0, 0, 0.1), seg=48)
    m.torus("lawyertie", 1.3, 0.05, (0, 0, 0.2))
    p = mp.person(m, skin="skin", shirt="shirtwhite", pants="khaki", shoes="brown", hair="hairbrown", hair_style="swoop",
                  expr="grin", face_kw={"brow_tilt": -0.3}, y=0.0,
                  arms={"r": ((0.95, -0.3, 3.0), (0.8, -0.5, 3.75)), "l": ((-0.95, -0.15, 2.4), (-0.6, -0.55, 2.4))})
    m.squircle("khaki", (1.12, 0.68, 1.2), (0, 0, 2.35), power=3)  # suit jacket
    m.squircle("shirtwhite", (0.4, 0.05, 0.7), (0, -0.35, 2.7), power=4)
    m.box("lawyertie", (0.18, 0.06, 0.65), (0, -0.39, 2.6), bevel=0.02)
    for k in range(3):
        m.box("yellow", (0.16, 0.03, 0.04), (0, -0.43, 2.4 + k * 0.18), rot=(0, 30, 0), bevel=0)
    m.box("skin", (0.07, 0.07, 0.3), (0.8, -0.55, 4.0), bevel=0.03)  # index finger up
    m.relief("yellow", [(-0.9, 0), (0.9, 0), (0.9, 0.5), (-0.9, 0.5)], 0.06, (0, -0.2, 4.95))
    m.text("lawyertie", "YOUR RIGHTS!", (0, -0.25, 5.2), size=0.22, depth=0.03)
    return m


def ohio_final_boss():
    m = Meme("OhioFinalBoss")
    # a hulking cornfield monster with too many teeth, crowned with a traffic cone
    for k in range(7):  # corn stalks
        x = -1.8 + k * 0.6
        m.cyl("cornstalk", 0.06, 1.6 + (k % 2) * 0.4, (x, 0.9, 0.8), seg=8)
        m.blob("corn", (0.15, 0.15, 0.4), (x + 0.08, 0.9, 1.4))
    m.squircle("ohio", (2.6, 1.9, 2.6), (0, 0, 1.75), power=2.2)  # body
    m.blob("darkgray", (1.6, 0.6, 1.4), (0, -0.75, 1.6))
    for s in (-1, 1):
        m.tube("ohio", [(s * 1.2, 0, 2.5), (s * 1.8, -0.4, 1.6), (s * 1.7, -0.6, 0.6)], lambda t: 0.4 - 0.12 * t)  # long arms
        for f in range(3):
            m.cyl("bone", 0.06, 0.3, (s * 1.7 + (f - 1) * 0.12, -0.75, 0.4), rot=(30, 0, 0), radius2=0.0, seg=8)  # claws
        m.squircle("ohio", (0.7, 0.9, 0.5), (s * 0.6, -0.2, 0.25), power=2.4)
        m.blob("yellow", (0.45, 0.2, 0.5), (s * 0.45, -0.82, 2.6))  # glowing eyes
        m.blob("black", (0.12, 0.1, 0.35), (s * 0.45, -0.93, 2.6))
    m.blob("mouth", (1.2, 0.3, 0.5), (0, -0.82, 1.9))
    for k in range(9):
        m.cyl("bone", 0.07, 0.22, (-0.48 + k * 0.12, -0.92, 2.05), rot=(180, 0, 0), radius2=0.0, seg=6)
    m.lathe("cone", [(0, 0), (0.6, 0), (0.6, 0.08), (0.45, 0.1), (0.05, 1.3), (0, 1.3)], (0.1, 0.0, 3.0), rot=(0, 12, 0))
    for z in (0.45, 0.8):
        m.torus("white", 0.33 - z * 0.15, 0.04, (0.1 + z * 0.2, 0.0, 3.0 + z), rot=(0, 12, 0))
    return m


def oh_yeah_villain():
    m = Meme("OhYeahVillain")
    # a lanky villain in an orange tracksuit and glasses, both fists pumping: OH YEAH!
    p = mp.person(m, skin="skin", shirt="tracksuit", pants="tracksuit", shoes="white", hair="hairblack", hair_style="mohawk",
                  build=0.9, expr="grin", face_kw={"brow_tilt": 0.4},
                  arms={"l": ((-1.0, -0.2, 3.2), (-1.15, -0.3, 4.1)), "r": ((1.0, -0.2, 3.2), (1.15, -0.3, 4.1))})
    hc, hs = p["head"], p["head_size"]
    for s in (-1, 1):
        m.torus("black", 0.17, 0.035, (hc.x + s * 0.3, hc.y - hs * 0.43, hc.z + 0.05), rot=(90, 0, 0))  # big round glasses
    m.box("black", (0.2, 0.04, 0.04), (hc.x, hc.y - hs * 0.44, hc.z + 0.07), bevel=0.01)
    for z in (1.4, 2.4):
        m.torus("white", 0.48, 0.03, (0, 0, z), scale=(1, 0.65, 1))  # tracksuit stripes
    m.box("white", (0.08, 0.05, 1.1), (0, -0.35, 2.4), bevel=0.02)  # zip
    m.text("orange", "OH YEAH!", (0, -0.3, 5.1), size=0.45, depth=0.06)
    return m


def whistle_edit():
    m = Meme("WhistleEdit")
    # a silver whistle on a red lanyard, hanging over a curl of film strip and floating notes
    m.squircle("darkgray", (2.0, 1.2, 0.2), (0, 0.2, 0.1), power=4)
    m.cyl("darkgray", 0.06, 3.0, (0, 0.5, 1.6), seg=8)
    m.tube("darkgray", [(0, 0.5, 3.1), (0, 0.2, 3.3), (0, -0.1, 3.2)], 0.05)
    m.tube("lanyard", [(0, -0.1, 3.2), (-0.35, -0.15, 2.8), (-0.2, -0.2, 2.3), (0.0, -0.25, 2.15)], 0.04)
    m.tube("lanyard", [(0, -0.1, 3.2), (0.35, -0.15, 2.8), (0.2, -0.2, 2.3), (0.0, -0.25, 2.15)], 0.04)
    m.cyl("whistle", 0.38, 0.55, (0.1, -0.3, 1.8), rot=(0, 90, 0), seg=28)  # whistle barrel
    m.squircle("whistle", (0.6, 0.3, 0.2), (-0.4, -0.3, 1.95), power=3)  # mouthpiece
    m.torus("whistle", 0.1, 0.03, (0.0, -0.3, 2.2), rot=(90, 0, 0))
    m.blob("black", (0.15, 0.1, 0.12), (0.2, -0.62, 1.9))
    # film strip curling around the base
    pts = [(math.cos(t) * 0.8, math.sin(t) * 0.45 - 0.1, 0.3 + t * 0.15) for t in [i * 0.35 for i in range(18)]]
    m.tube("film", pts, 0.12, seg=4)
    for k in range(3):
        x = -1.1 + k * 0.6
        m.blob("black", (0.18, 0.1, 0.14), (x - 0.4, -0.5, 3.4 + k * 0.3), rot=(0, -20, 0))
        m.cyl("black", 0.025, 0.45, (x - 0.32, -0.5, 3.62 + k * 0.3), seg=6)
    return m


ALL = [yes_no_lab_dog, assistant_sam, lamp_oil_merchant, wise_mystical_tree, uncanny_super_dad, phonk_eyebrow_speaker,
       clanging_pipe, better_call_paul, ohio_final_boss, oh_yeah_villain, whistle_edit]
