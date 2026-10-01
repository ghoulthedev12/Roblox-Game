"""Batch 1 of the meme sculptures. Each function builds one meme with memekit.
Coordinates: z is up, the model faces -y (the front), about 4-5 units (studs) tall."""
import math

from memekit import Meme


def chill_dude():
    m = Meme("ChillDude")
    for s in (-1, 1):
        m.box("white", (0.62, 1.0, 0.34), (s * 0.36, -0.12, 0.17), bevel=0.12)
        m.box("red", (0.64, 1.02, 0.1), (s * 0.36, -0.12, 0.05), bevel=0.04)
        m.box("jeans", (0.56, 0.6, 1.5), (s * 0.34, 0, 1.08), bevel=0.14)
        m.box("sky", (0.6, 0.64, 0.18), (s * 0.34, 0, 0.42), bevel=0.06)  # rolled cuff
        m.box("navy", (0.3, 0.06, 0.36), (s * 0.46, -0.37, 1.95), bevel=0.02)  # pocket slit
    m.box("jeans", (1.36, 0.72, 0.5), (0, 0, 1.95), bevel=0.14)
    m.box("sweater", (1.5, 0.86, 1.32), (0, 0, 2.78), bevel=0.3)
    m.box("darkgray", (1.56, 0.9, 0.2), (0, 0, 2.16), bevel=0.08)  # ribbed hem
    m.blob("sweater", (1.85, 0.92, 0.66), (0, 0, 3.36))
    for s in (-1, 1):  # arms straight down, hands in pockets
        m.tube("sweater", [(s * 0.86, 0, 3.32), (s * 0.84, -0.06, 2.7), (s * 0.66, -0.2, 2.1)], lambda t: 0.25 - 0.03 * t)
        m.blob("darkgray", (0.42, 0.44, 0.22), (s * 0.62, -0.22, 2.06))  # cuff at the pocket
    m.blob("darkgray", (0.74, 0.64, 0.28), (0, 0, 3.66))  # collar
    m.blob("tan", (1.15, 1.05, 1.12), (0, 0, 4.22))  # head
    m.blob("cream", (0.64, 0.8, 0.52), (0, -0.5, 4.02))  # snout
    m.blob("black", (0.28, 0.18, 0.18), (0, -0.9, 4.16))  # nose
    m.tube("darkbrown", [(-0.1, -0.86, 3.86), (0.05, -0.88, 3.85), (0.2, -0.85, 3.9)], 0.025)  # smirk
    for s in (-1, 1):
        m.blob("white", (0.26, 0.06, 0.15), (s * 0.25, -0.46, 4.38))  # relaxed half-closed eyes
        m.blob("black", (0.13, 0.07, 0.1), (s * 0.24, -0.49, 4.37))
        m.blob("tan", (0.3, 0.1, 0.1), (s * 0.25, -0.48, 4.45))  # soft lids, no frown
        m.blob("brown", (0.3, 0.2, 0.8), (s * 0.6, 0.05, 4.12), rot=(0, s * 15, 0))  # floppy ears
    return m


def log_guy():
    m = Meme("LogBatGuy")
    for s in (-1, 1):
        m.tube("darkbrown", [(s * 0.3, 0, 0.75), (s * 0.32, 0, 0.1)], 0.11)
        m.blob("darkbrown", (0.34, 0.55, 0.22), (s * 0.32, -0.1, 0.09))
    m.cyl("wood", 0.62, 3.0, (0, 0, 2.2), seg=36)
    m.cyl("lightwood", 0.56, 0.06, (0, 0, 3.71), seg=36)  # cut top
    m.torus("brown", 0.36, 0.025, (0, 0, 3.745))  # tree rings
    m.torus("brown", 0.18, 0.02, (0, 0, 3.745))
    for z in (1.2, 1.9, 2.6, 3.3):  # bark lines
        m.torus("brown", 0.62, 0.025, (0, 0, z), scale=(1, 1, 0.4))
    for s in (-1, 1):  # big round eyes
        m.blob("white", (0.42, 0.14, 0.48), (s * 0.26, -0.6, 3.05))
        m.blob("black", (0.18, 0.1, 0.22), (s * 0.24, -0.66, 3.02))
        m.box("darkbrown", (0.34, 0.08, 0.07), (s * 0.26, -0.62, 3.38), rot=(0, -s * 8, 0), bevel=0.02)
    m.blob("darkred", (0.66, 0.1, 0.28), (0, -0.6, 2.52))  # huge grin
    m.box("teeth", (0.5, 0.06, 0.08), (0, -0.64, 2.6), bevel=0.02)
    m.tube("wood", [(-0.6, 0, 2.6), (-0.82, -0.1, 2.1), (-0.8, -0.15, 1.7)], 0.09)  # left arm down
    m.tube("wood", [(0.6, 0, 2.7), (0.95, -0.1, 3.2), (1.05, -0.15, 3.55)], 0.09)  # right arm up
    m.cyl("lightwood", 0.08, 2.0, (1.1, -0.2, 3.9), rot=(0, 30, 0), radius2=0.2)  # the bat
    return m


def cappuccino_ballerina():
    m = Meme("CappuccinoBallerina")
    for s in (-1, 1):
        m.tube("skin", [(s * 0.13, 0, 1.55), (s * 0.15, 0, 0.8), (s * 0.12, 0, 0.18)], lambda t: 0.09 - 0.03 * t)
        m.blob("pink", (0.18, 0.28, 0.3), (s * 0.12, -0.04, 0.12))  # pointe shoes
    m.cyl("pink", 1.0, 0.08, (0, 0, 1.55), seg=40, scale=(1, 1, 1))  # tutu
    m.cyl("hotpink", 0.82, 0.12, (0, 0, 1.62), seg=40)
    for k in range(16):  # tutu ruffles
        a = k / 16 * math.tau
        m.blob("pink", (0.4, 0.28, 0.12), (math.cos(a) * 0.86, math.sin(a) * 0.86, 1.52), rot=(0, 0, math.degrees(a)))
    m.blob("hotpink", (0.58, 0.44, 0.9), (0, 0, 2.05))  # leotard
    for s in (-1, 1):  # arms up in an arc over the head
        m.tube("skin", [(s * 0.28, 0, 2.35), (s * 0.66, 0, 2.95), (s * 0.5, 0, 3.55), (s * 0.12, 0, 3.75)], 0.06)
    m.cyl("white", 0.46, 0.78, (0, 0, 2.85), seg=36, radius2=0.5)  # the cup head
    m.cyl("coffee", 0.47, 0.04, (0, 0, 3.23), seg=36)
    m.blob("foam", (0.5, 0.5, 0.1), (0, 0, 3.25))
    m.blob("coffee", (0.18, 0.16, 0.04), (0, 0, 3.3))  # latte heart
    m.torus("white", 0.18, 0.05, (0.52, 0, 2.86), rot=(90, 0, 0))  # handle
    for s in (-1, 1):
        m.blob("black", (0.1, 0.06, 0.14), (s * 0.16, -0.47, 2.95))
        m.blob("pink", (0.12, 0.04, 0.07), (s * 0.27, -0.46, 2.8))
    m.tube("darkred", [(-0.1, -0.48, 2.72), (0, -0.5, 2.68), (0.1, -0.48, 2.72)], 0.025)
    m.cyl("white", 0.7, 0.06, (0, 0, 2.43), seg=36)  # saucer collar
    return m


def sneaker_shark():
    m = Meme("SneakerShark")
    m.blob("shark", (3.3, 1.1, 1.15), (0, 0, 2.15))
    m.blob("white", (2.8, 0.96, 0.62), (-0.1, 0, 1.86))  # belly
    m.cyl("shark", 0.45, 0.9, (0.1, 0, 2.95), rot=(0, -25, 0), radius2=0.02, scale=(1, 0.25, 1))  # dorsal fin
    m.cyl("shark", 0.4, 0.9, (1.8, 0, 2.5), rot=(0, 35, 0), radius2=0.03, scale=(1, 0.22, 1))  # tail fins
    m.cyl("shark", 0.35, 0.7, (1.75, 0, 1.85), rot=(0, 145, 0), radius2=0.03, scale=(1, 0.22, 1))
    for s in (-1, 1):
        m.blob("shark", (0.65, 0.4, 0.12), (-0.3, s * 0.6, 1.75), rot=(s * 25, 0, 0))
        m.blob("black", (0.2, 0.08, 0.2), (-1.1, s * 0.44, 2.3))
    for i in range(6):  # teeth
        m.cyl("teeth", 0.05, 0.12, (-1.45 + i * 0.07, -0.38 + i * 0.03, 1.98), rot=(180, 0, 0), radius2=0.0)
    m.tube("darkgray", [(-1.6, -0.2, 2.0), (-1.3, -0.45, 1.96), (-0.95, -0.5, 1.98)], 0.03)
    for i, (x, y) in enumerate([(-0.7, -0.2), (0, 0.25), (0.7, -0.2)]):  # three legs in sneakers
        m.tube("shark", [(x, y, 1.7), (x, y, 0.35)], 0.11)
        m.box("blue", (0.7, 0.36, 0.3), (x - 0.12, y, 0.2), bevel=0.12)
        m.box("white", (0.72, 0.38, 0.08), (x - 0.12, y, 0.05), bevel=0.03)
        m.box("white", (0.2, 0.37, 0.12), (x + 0.1, y, 0.3), bevel=0.04)  # plain heel tab, no logo
    return m


def six_seven_hands():
    m = Meme("SixSevenHands")
    m.cyl("darkgray", 1.2, 0.2, (0, 0, 0.1), seg=40)  # round stand
    m.cyl("gold", 1.22, 0.06, (0, 0, 0.22), seg=40)

    def hand(x, z):
        # a big cartoon hand, palm up and tipped toward the viewer, rising on its forearm
        m.tube("skin2", [(x, 0.15, 0.25), (x, 0.05, z - 0.45)], lambda t: 0.2 - 0.03 * t)  # forearm
        m.blob("skin2", (0.8, 0.85, 0.32), (x, -0.25, z - 0.2), rot=(-25, 0, 0))  # palm
        for f in range(4):  # four fingers, slightly curled up
            fx = x + (f - 1.5) * 0.18
            m.tube("skin2", [(fx, -0.55, z - 0.12), (fx, -0.82, z - 0.02), (fx, -0.92, z + 0.12)], 0.075)
        side = 1 if x < 0 else -1
        m.tube("skin2", [(x + side * 0.35, -0.2, z - 0.2), (x + side * 0.55, -0.45, z - 0.05), (x + side * 0.55, -0.6, z + 0.1)], 0.085)
    hand(-0.75, 1.9)  # one hand low...
    hand(0.75, 2.6)   # ...one hand high, mid-bounce
    # chunky 3D numbers bouncing above the palms
    m.torus("orange", 0.27, 0.11, (-0.75, -0.35, 2.32), rot=(90, 0, 0))
    m.tube("orange", [(-1.0, -0.35, 2.38), (-0.98, -0.35, 2.8), (-0.78, -0.35, 3.02), (-0.55, -0.35, 2.98)], 0.11)
    m.tube("blue", [(0.45, -0.35, 3.62), (1.05, -0.35, 3.62), (0.78, -0.35, 2.98)], 0.12)
    return m


def low_taper_fade():
    m = Meme("LowTaperFade")
    m.cyl("darkgray", 0.55, 0.3, (0, 0, 0.15), seg=32, radius2=0.45)  # mannequin stand
    m.cyl("lightgray", 0.12, 0.9, (0, 0, 0.75))
    m.blob("skin", (1.1, 0.9, 0.5), (0, 0, 1.3))  # shoulders stub
    m.cyl("skin", 0.25, 0.5, (0, 0, 1.6))  # neck
    m.blob("skin", (1.0, 1.1, 1.25), (0, 0, 2.35))  # head
    m.blob("skin", (0.18, 0.3, 0.32), (0, -0.56, 2.3))  # nose
    m.tube("darkred", [(-0.13, -0.52, 2.04), (0, -0.55, 2.0), (0.13, -0.52, 2.04)], 0.025)
    for s in (-1, 1):
        m.blob("skin", (0.12, 0.25, 0.32), (s * 0.5, 0.05, 2.32))  # ears
        m.blob("white", (0.17, 0.06, 0.11), (s * 0.2, -0.52, 2.5))
        m.blob("black", (0.08, 0.05, 0.09), (s * 0.2, -0.55, 2.5))
        m.box("black", (0.22, 0.06, 0.05), (s * 0.2, -0.53, 2.64), bevel=0.02)  # eyebrows
    # the massive low taper fade: skin-close sides fading up into an absurdly tall, smooth top
    m.blob("darkbrown", (1.03, 1.13, 0.62), (0, 0.04, 2.62))  # short faded sides
    m.blob("brown", (1.05, 1.15, 0.22), (0, 0.04, 2.42))  # the lightest part of the fade
    m.cyl("black", 0.46, 2.0, (0, 0.06, 3.75), seg=36, scale=(1, 1.08, 1))  # the towering top
    m.blob("black", (0.92, 1.0, 0.7), (0, 0.06, 4.75))
    m.blob("black", (0.98, 1.08, 0.5), (0, 0.06, 2.85))
    m.blob("darkgray", (0.1, 0.5, 1.6), (-0.36, -0.12, 3.8))  # shine streak
    m.box("lightgray", (0.4, 0.12, 0.7), (0.95, -0.15, 1.45), rot=(0, -20, 0), bevel=0.05)  # clippers
    m.box("darkgray", (0.42, 0.14, 0.14), (1.03, -0.15, 1.82), rot=(0, -20, 0), bevel=0.03)
    return m


def dubai_chocolate():
    m = Meme("DubaiChocolate")
    m.box("lightwood", (3.0, 1.6, 0.15), (0, 0, 0.08), bevel=0.05)  # board
    for side in (-1, 1):  # the bar snapped in two, both halves lying flat, slightly apart
        cx = side * 0.72
        m.box("milkchoc", (1.25, 0.95, 0.42), (cx, 0, 0.38), rot=(0, side * 6, side * -4), bevel=0.06)
        for i in range(3):
            for j in range(2):
                m.box("chocolate", (0.34, 0.38, 0.08), (cx + (i - 1) * 0.38, (j - 0.5) * 0.42, 0.62),
                      rot=(0, side * 6, side * -4), bevel=0.04)
        m.box("pistachio", (0.12, 0.8, 0.24), (side * 0.11, 0, 0.36), bevel=0.05)  # filling showing at the break
    for i in range(9):  # gooey pistachio oozing out between the halves
        m.blob("pistachio", (0.42, 0.36, 0.42), (((i % 3) - 1) * 0.08, (i - 4) * 0.11, 0.42 + (i % 2) * 0.1))
    m.tube("pistachio", [(0.0, -0.4, 0.4), (0.02, -0.65, 0.22), (0.05, -0.75, 0.17)], 0.08)
    m.blob("pistachio", (0.8, 0.6, 0.08), (0.05, -0.78, 0.17))  # puddle on the board
    for i in range(12):  # crunchy pastry strands sticking out
        m.tube("lightwood", [(0.0, (i - 6) * 0.06, 0.42), ((i % 2 - 0.5) * 0.3, (i - 6) * 0.065, 0.5)], 0.015)
    return m


def baby_hippo():
    m = Meme("BabyHippo")
    m.blob("hippo", (1.4, 2.2, 1.3), (0, 0.2, 0.85))  # body
    for x in (-0.45, 0.45):
        for y in (-0.5, 0.9):
            m.cyl("hippo", 0.2, 0.5, (x, y, 0.25))
    m.blob("hippo", (1.25, 1.2, 1.0), (0, -0.85, 1.35), rot=(-10, 0, 0))  # head
    m.blob("hippopink", (1.1, 0.7, 0.42), (0, -1.4, 1.12))  # open lower jaw
    m.blob("darkred", (0.85, 0.5, 0.3), (0, -1.38, 1.3))  # open mouth
    m.blob("hippo", (1.0, 0.65, 0.4), (0, -1.38, 1.55))  # upper snout
    for s in (-1, 1):
        m.blob("teeth", (0.08, 0.08, 0.14), (s * 0.3, -1.6, 1.28))
        m.blob("black", (0.08, 0.04, 0.05), (s * 0.18, -1.68, 1.68))  # nostrils
        m.blob("black", (0.16, 0.1, 0.16), (s * 0.36, -1.1, 1.75))  # eyes
        m.blob("white", (0.05, 0.04, 0.05), (s * 0.34, -1.15, 1.8))
        m.blob("hippo", (0.16, 0.12, 0.22), (s * 0.38, -0.75, 1.9))  # ears
        m.blob("hippopink", (0.3, 0.06, 0.16), (s * 0.5, -1.2, 1.38))  # rosy cheeks
    for k in range(5):  # wet shine droplets
        m.blob("sky", (0.08, 0.08, 0.12), (math.cos(k) * 0.6, 0.4 - k * 0.3, 1.45 - k * 0.05))
    m.blob("sky", (2.2, 2.8, 0.06), (0, 0, 0.02))  # puddle
    return m


def birthday_shake():
    m = Meme("BirthdayShake")
    m.blob("purple", (1.9, 1.6, 0.06), (0.35, -0.3, 0.03))  # spill
    m.cyl("white", 0.6, 2.0, (0, 0, 1.0), seg=36, radius2=0.7)  # tapered cup
    m.cyl("purple", 0.665, 0.6, (0, 0, 1.15), seg=36, radius2=0.69)  # band
    m.blob("purple", (1.36, 1.36, 0.6), (0, 0, 2.05))  # shake top
    m.blob("lilac", (1.42, 1.42, 0.66), (0, 0, 2.08))  # clear dome
    m.blob("purple", (0.22, 0.22, 0.5), (0.62, -0.25, 1.7))  # drip
    m.tube("white", [(0.15, 0, 2.2), (0.6, 0, 3.3)], 0.08)  # straw
    m.tube("purple", [(0.48, 0, 3.0), (0.6, 0, 3.3)], 0.085)
    m.cyl("pink", 0.05, 0.45, (-0.3, 0, 2.6))  # birthday candle
    m.blob("yellow", (0.12, 0.12, 0.22), (-0.3, 0, 2.92))
    m.blob("orange", (0.08, 0.08, 0.14), (-0.3, 0, 2.92))
    return m


def punch_and_plushie():
    m = Meme("PunchMonkey")
    m.blob("lightwood", (2.6, 1.9, 0.12), (0, 0.1, 0.06))  # straw bed
    # the plush orangutan, sitting, shaggy orange with long dangling arms
    m.blob("orangutan", (1.1, 0.95, 1.2), (0.45, 0.25, 0.7))
    m.blob("orangutan", (0.95, 0.85, 0.85), (0.45, 0.2, 1.55))
    m.blob("skin2", (0.62, 0.22, 0.5), (0.45, -0.18, 1.5))  # plush face disc
    for s in (-1, 1):
        m.blob("black", (0.1, 0.05, 0.1), (0.45 + s * 0.13, -0.29, 1.6))
        m.blob("orangutan", (0.22, 0.18, 0.22), (0.45 + s * 0.48, 0.2, 1.6))  # ears
        m.tube("orangutan", [(0.45 + s * 0.5, 0.2, 1.15), (0.45 + s * 0.75, 0.0, 0.6), (0.45 + s * 0.7, -0.2, 0.18)], 0.14)
    for k in range(10):  # shaggy fur tufts
        a = k / 10 * math.tau
        m.blob("redbrown", (0.22, 0.16, 0.3), (0.45 + 0.52 * math.cos(a), 0.25 + 0.45 * math.sin(a), 0.85))
    m.tube("darkbrown", [(0.33, -0.3, 1.38), (0.45, -0.32, 1.35), (0.57, -0.3, 1.38)], 0.025)
    # Punch, the baby macaque, hugging the plush tight from the front-left
    m.blob("macaque", (0.7, 0.62, 0.85), (-0.25, -0.15, 0.62))
    m.blob("macaque", (0.66, 0.6, 0.6), (-0.32, -0.32, 1.3))
    m.blob("macaqueface", (0.42, 0.16, 0.38), (-0.36, -0.6, 1.26))
    for s in (-1, 1):
        m.blob("black", (0.09, 0.05, 0.11), (-0.36 + s * 0.1, -0.68, 1.33))
        m.blob("white", (0.03, 0.03, 0.03), (-0.37 + s * 0.1, -0.71, 1.36))
        m.blob("macaqueface", (0.15, 0.1, 0.18), (-0.36 + s * 0.33, -0.35, 1.36))  # ears
    m.tube("macaque", [(-0.05, -0.35, 0.95), (0.25, -0.45, 0.95), (0.55, -0.3, 0.95)], 0.1)  # hugging arms
    m.tube("macaque", [(-0.3, 0.1, 1.0), (0.1, 0.15, 1.05), (0.4, 0.05, 1.0)], 0.1)
    m.tube("macaque", [(-0.5, 0.15, 0.35), (-0.85, 0.35, 0.2), (-1.0, 0.2, 0.1)], 0.05)  # tail
    for s in (-1, 1):
        m.blob("macaque", (0.22, 0.32, 0.18), (-0.25 + s * 0.22, -0.4, 0.15))  # feet
    return m


ALL = [chill_dude, log_guy, cappuccino_ballerina, sneaker_shark, six_seven_hands, low_taper_fade,
       dubai_chocolate, baby_hippo, birthday_shake, punch_and_plushie]
