"""memeparts: bigger reusable pieces for the meme sculptures, built from memekit primitives.

  person(m, ...)   a stylized standing (or sitting) human: shoes, legs, hips, torso, posable
                   arms with hands, neck, head, hair and a face. Returns the key points.
  face(m, ...)     eyes, brows, nose and a mouth for any head facing -y (people and animals).
  paws/limbs       small helpers for animals.

Conventions as in memekit: z is up, the figure faces -y, about 4-5 studs tall.
"""
import math

from mathutils import Vector

from memekit import rgb

# skin tones and a few clothing colors everyone can use (appended to the palette)
for _name, _c in [
    ("skin3", (160, 105, 70)), ("skin4", (110, 70, 45)), ("blush", (255, 140, 150)), ("lips", (200, 90, 90)),
    ("hairblack", (35, 30, 30)), ("hairbrown", (95, 60, 35)), ("hairblond", (235, 200, 110)), ("hairred", (190, 80, 40)),
    ("hairgray", (180, 180, 185)), ("tongue", (230, 90, 110)), ("mouth", (70, 20, 30)), ("shirtwhite", (240, 240, 236)),
    ("suit", (45, 48, 60)), ("tie", (180, 30, 40)), ("hoodie", (90, 100, 120)), ("sneaker", (245, 245, 245)),
]:
    rgb(_name, *_c)


def V(*a):
    return Vector(a)


# ------------------------------------------------------------------------------------------
# faces
# ------------------------------------------------------------------------------------------
def face(m, c, w, expr="smile", skin="skin", eye=0.2, eye_gap=None, eye_z=0.08, iris="black", brows="hairbrown",
         brow_tilt=0.0, mouth_z=-0.22, mouth_w=0.34, nose=True, nose_color=None, look=(0.0, 0.0), lids=0.0, blush=False,
         teeth=False):
    """A face on the front (-y) of a head centered at c with half-depth w (the front surface is at
    c.y - w). expr: smile, grin, open, o, flat, smirk, frown, scream, cat (w-shaped), tongue.
    brow_tilt > 0 = angry (inner ends down), < 0 = worried. lids 0..1 closes the eyes."""
    c = Vector(c)
    front = c.y - w
    gap = eye_gap if eye_gap is not None else eye * 1.1
    for s in (-1, 1):
        e = (c.x + s * gap, front + eye * 0.18, c.z + eye_z)
        m.eye(e, (eye, eye * 0.5, eye * 1.15), iris=iris, look=look, lid=skin if lids > 0 else None, lid_drop=lids)
        if brows:
            m.box(brows, (eye * 1.1, 0.06, eye * 0.22), (c.x + s * gap, front + 0.02, c.z + eye_z + eye * 0.85),
                  rot=(0, s * brow_tilt * 25, 0), bevel=0.02)
        if blush:
            m.blob("blush", (eye * 0.9, 0.05, eye * 0.45), (c.x + s * gap * 1.55, front + 0.06, c.z + eye_z - eye * 0.9))
    if nose:
        m.blob(nose_color or skin, (0.11, 0.12, 0.13), (c.x, front - 0.03, c.z - 0.08))
    mz = c.z + mouth_z
    my = front + 0.03
    if expr == "smile":
        m.tube("mouth", [(c.x - mouth_w / 2, my, mz + 0.05), (c.x, my - 0.01, mz - 0.05), (c.x + mouth_w / 2, my, mz + 0.05)], 0.03)
    elif expr == "smirk":
        m.tube("mouth", [(c.x - mouth_w / 2, my, mz), (c.x + mouth_w * 0.2, my - 0.01, mz - 0.01), (c.x + mouth_w / 2, my, mz + 0.07)], 0.028)
    elif expr == "flat":
        m.tube("mouth", [(c.x - mouth_w / 2, my, mz), (c.x + mouth_w / 2, my, mz)], 0.026)
    elif expr == "frown":
        m.tube("mouth", [(c.x - mouth_w / 2, my, mz - 0.05), (c.x, my - 0.01, mz + 0.04), (c.x + mouth_w / 2, my, mz - 0.05)], 0.03)
    elif expr == "cat":
        m.tube("mouth", [(c.x - mouth_w / 2, my, mz + 0.03), (c.x - mouth_w / 4, my - 0.01, mz - 0.04), (c.x, my, mz + 0.02),
                         (c.x + mouth_w / 4, my - 0.01, mz - 0.04), (c.x + mouth_w / 2, my, mz + 0.03)], 0.025)
    elif expr in ("grin", "open", "o", "scream", "tongue"):
        if expr == "grin":
            size = (mouth_w * 1.3, 0.1, mouth_w * 0.45)
        elif expr == "o":
            size = (mouth_w * 0.55, 0.1, mouth_w * 0.6)
        elif expr == "scream":
            size = (mouth_w * 1.1, 0.12, mouth_w * 1.2)
        else:
            size = (mouth_w * 1.0, 0.1, mouth_w * 0.7)
        m.blob("mouth", size, (c.x, my, mz))
        if expr in ("grin", "open") or teeth:
            m.box("teeth", (size[0] * 0.8, 0.05, size[2] * 0.22), (c.x, my - 0.04, mz + size[2] * 0.3), bevel=0.015)
        if expr in ("open", "scream", "tongue"):
            m.blob("tongue", (size[0] * 0.6, 0.06, size[2] * 0.4), (c.x, my - 0.03, mz - size[2] * 0.22))
        if expr == "tongue":
            m.blob("tongue", (0.16, 0.12, 0.22), (c.x, my - 0.06, mz - size[2] * 0.6))


# ------------------------------------------------------------------------------------------
# people
# ------------------------------------------------------------------------------------------
def arm(m, color, shoulder, elbow, hand, r=0.15, hand_color="skin", hand_size=0.27, sleeve=None, fist=False):
    """One smooth arm from the shoulder through the elbow to a mitten hand with a thumb.
    sleeve = color of the forearm (bare skin for short sleeves)."""
    shoulder, elbow, hand = Vector(shoulder), Vector(elbow), Vector(hand)
    wrist = hand + (elbow - hand).normalized() * hand_size * 0.42
    lower = sleeve or color
    if lower == color:
        m.tube(color, [shoulder, shoulder.lerp(elbow, 0.5), elbow, elbow.lerp(wrist, 0.5), wrist],
               lambda t: r * (1.08 - 0.3 * t), seg=14)
    else:
        m.tube(color, [shoulder, shoulder.lerp(elbow, 0.5), elbow + (elbow - shoulder).normalized() * 0.05],
               lambda t: r * (1.08 - 0.1 * t), seg=14)
        m.tube(lower, [elbow, elbow.lerp(wrist, 0.5), wrist], lambda t: r * (0.9 - 0.2 * t), seg=14)
    d = (hand - elbow).normalized()
    m.squircle(hand_color, (hand_size * 0.95, hand_size * 0.7, hand_size * (1.0 if fist else 1.2)), hand, power=2.4)
    if not fist:
        side = d.cross(Vector((0, 0, 1)))
        if side.length < 0.01:
            side = Vector((1, 0, 0))
        m.blob(hand_color, (hand_size * 0.34, hand_size * 0.34, hand_size * 0.5),
               hand - side.normalized() * hand_size * 0.42 - d * hand_size * 0.12 + Vector((0, -hand_size * 0.1, 0)))
    return hand


def person(m, skin="skin", shirt="white", pants="jeans", shoes="sneaker", hair="hairbrown", hair_style="short",
           arms=None, sleeve=None, sleeves_short=False, height=1.0, build=1.0, head=1.0, expr="smile", face_kw=None,
           sitting=False, legs=None, belt=None, neck_color=None, x=0.0, y=0.0, turn=0.0, shoe_color=None,
           belly=None, sole="white", z=0.0):
    """A stylized cartoon human (about 4.6 studs tall at height 1, big friendly head).
    arms = {"l": (elbow, hand), "r": (elbow, hand)} as points relative to the figure's origin
    (x right, -y front, z up); default arms hang relaxed. legs = {-1/1: (knee, foot)} likewise.
    hair_style: short, spiky, long, bun, bald, curly, fade, slick, cap, mohawk, swoop.
    Returns key points: head (center), head_size, hands, chest, shoulder_z, hip_z, O."""
    h, b = height, build
    O = Vector((x, y, z))  # z lifts the whole figure (standing on something)
    ca, sa = math.cos(math.radians(turn)), math.sin(math.radians(turn))

    def P(px, py, pz):
        return O + Vector((px * ca - py * sa, px * sa + py * ca, pz))

    def L(v):  # a point given relative to the figure (for arms/legs), turned with it
        return P(v[0], v[1], v[2])

    fwd = Vector((sa, -ca, 0))  # the figure's front direction
    hip_z = (1.05 if sitting else 1.6) * h
    # legs: one smooth tube each, hip -> knee -> ankle, then a chunky sneaker
    for s in (-1, 1):
        top = P(s * 0.27 * b, 0, hip_z)
        if sitting:
            knee, foot = P(s * 0.29 * b, -1.0 * h, hip_z + 0.05), P(s * 0.3 * b, -1.1 * h, 0.15)
        elif legs and s in legs:
            knee, foot = L(legs[s][0]), L(legs[s][1])
        else:
            knee, foot = P(s * 0.28 * b, -0.05, 0.85 * h), P(s * 0.3 * b, 0, 0.16)
        ankle = foot - fwd * 0.04 + Vector((0, 0, 0.16))
        m.tube(pants, [top, top.lerp(knee, 0.5), knee, knee.lerp(ankle, 0.5), ankle],
               lambda t: 0.25 * b * (1 - 0.25 * t), seg=14)
        m.squircle(shoe_color or shoes, (0.4 * b, 0.68, 0.3), foot + fwd * 0.14, rot=(0, 0, turn), power=3)
        if sole:
            m.squircle(sole, (0.42 * b, 0.7, 0.09), foot + fwd * 0.14 + Vector((0, 0, -0.11)), rot=(0, 0, turn), power=4)
    # hips, belly and chest (tapered: broad shoulders, narrower waist)
    m.squircle(pants, (0.86 * b, 0.58 * b, 0.5 * h), P(0, 0, hip_z + 0.06), rot=(0, 0, turn), power=2.8)
    if belt:
        m.squircle(belt, (0.88 * b, 0.6 * b, 0.1), P(0, 0, hip_z + 0.28 * h), rot=(0, 0, turn), power=4)
    bw = (belly or 0.86) * b
    m.squircle(shirt, (bw, 0.6 * b * max(1.0, bw / (0.86 * b)), 0.7 * h), P(0, 0, hip_z + 0.5 * h), rot=(0, 0, turn), power=2.6)
    chest_z = hip_z + 0.92 * h
    m.squircle(shirt, (1.08 * b, 0.64 * b, 0.72 * h), P(0, 0, chest_z), rot=(0, 0, turn), power=2.8)
    sh_z = chest_z + 0.24 * h
    for s in (-1, 1):
        m.blob(shirt, (0.42 * b, 0.48 * b, 0.4 * b), P(s * 0.5 * b, 0, sh_z))
    # arms
    hands = {}
    arms = arms or {}
    for key, s in (("l", -1), ("r", 1)):
        shoulder = P(s * 0.58 * b, 0, sh_z)
        if key in arms:
            elbow, hand = L(arms[key][0]), L(arms[key][1])
        else:
            elbow, hand = P(s * 0.7 * b, 0.04, sh_z - 0.62 * h), P(s * 0.74 * b, -0.06, sh_z - 1.18 * h)
        lower = sleeve or (skin if sleeves_short else shirt)
        hands[key] = arm(m, shirt, shoulder, elbow, hand, r=0.15 * b, hand_color=skin, sleeve=lower)
    # neck and the big head
    m.cyl(neck_color or skin, 0.17 * b, 0.32, P(0, 0, sh_z + 0.16), seg=16)
    hs = 1.3 * head
    hc = P(0, -0.03, sh_z + 0.26 + hs * 0.5)
    m.squircle(skin, (hs * 0.86, hs * 0.84, hs), hc, rot=(0, 0, turn), power=2.3)
    m.blob(skin, (hs * 0.62, hs * 0.5, hs * 0.4), hc + fwd * hs * 0.12 + Vector((0, 0, -hs * 0.3)))  # soft jaw
    for s in (-1, 1):  # ears
        m.blob(skin, (0.12, 0.2, 0.28), hc + Vector((s * hs * 0.43 * ca, s * hs * 0.43 * sa, -0.02)))
    hair_kind = hair_style if hair else "bald"
    top = hc + Vector((0, 0.04, hs * 0.2))
    if hair_kind == "short":
        m.squircle(hair, (hs * 0.9, hs * 0.88, hs * 0.5), top + Vector((0, 0.03, hs * 0.08)), power=2.3)
        m.blob(hair, (hs * 0.7, hs * 0.3, hs * 0.2), top + Vector((0.05, -hs * 0.34, hs * 0.12)), rot=(0, -10, 0))  # fringe
    elif hair_kind == "fade":
        m.squircle(hair, (hs * 0.88, hs * 0.86, hs * 0.38), top + Vector((0, 0.03, hs * 0.16)), power=3)
    elif hair_kind == "slick":
        m.squircle(hair, (hs * 0.9, hs * 0.9, hs * 0.46), top + Vector((0, 0.06, hs * 0.1)), power=2.5)
        m.blob(hair, (hs * 0.72, hs * 0.55, hs * 0.24), top + Vector((0, -hs * 0.14, hs * 0.28)))
    elif hair_kind == "swoop":
        m.squircle(hair, (hs * 0.9, hs * 0.88, hs * 0.45), top + Vector((0, 0.04, hs * 0.1)), power=2.4)
        m.blob(hair, (hs * 0.95, hs * 0.5, hs * 0.3), top + Vector((hs * 0.08, -hs * 0.22, hs * 0.3)), rot=(0, -18, 0))
    elif hair_kind == "spiky":
        m.squircle(hair, (hs * 0.88, hs * 0.86, hs * 0.42), top + Vector((0, 0.03, hs * 0.06)), power=2.4)
        for k in range(9):
            a = -1.3 + k * 0.325
            for row, dy in ((0, -0.15), (1, 0.18)):
                m.cyl(hair, 0.15, 0.48, top + Vector((math.sin(a) * hs * 0.34, dy, hs * 0.26 + math.cos(a) * 0.06)),
                      rot=(-25 if row == 0 else 20, math.degrees(a) * 0.8, 0), radius2=0.0, seg=8)
    elif hair_kind == "mohawk":
        m.squircle(hair, (hs * 0.6, hs * 0.86, hs * 0.3), top + Vector((0, 0.03, hs * 0.18)), power=2.2)
        for k in range(5):
            m.cyl(hair, 0.13, 0.5, top + Vector((0, -0.3 + k * 0.16, hs * 0.38)), rot=(-20 + k * 10, 0, 0), radius2=0.0, seg=8)
    elif hair_kind == "long":
        m.squircle(hair, (hs * 0.94, hs * 0.92, hs * 0.56), top + Vector((0, 0.03, hs * 0.06)), power=2.3)
        m.squircle(hair, (hs * 0.96, hs * 0.46, hs * 1.15), hc + Vector((0, hs * 0.26, -hs * 0.3)), power=2.6)
        for s in (-1, 1):
            m.squircle(hair, (hs * 0.18, hs * 0.4, hs * 0.85), hc + Vector((s * hs * 0.44, -hs * 0.02, -hs * 0.22)), power=2.4)
    elif hair_kind == "bun":
        m.squircle(hair, (hs * 0.9, hs * 0.88, hs * 0.5), top + Vector((0, 0.03, hs * 0.06)), power=2.3)
        m.blob(hair, (hs * 0.42, hs * 0.42, hs * 0.42), top + Vector((0, 0.12, hs * 0.48)))
    elif hair_kind == "curly":
        for k in range(14):
            a = k / 14 * math.tau
            m.blob(hair, (hs * 0.34, hs * 0.34, hs * 0.34), top + Vector((math.cos(a) * hs * 0.36, math.sin(a) * hs * 0.32 + 0.08, hs * 0.14)))
        for k in range(6):
            a = k / 6 * math.tau
            m.blob(hair, (hs * 0.34, hs * 0.34, hs * 0.34), top + Vector((math.cos(a) * hs * 0.2, math.sin(a) * hs * 0.18 + 0.08, hs * 0.32)))
    elif hair_kind == "cap":
        m.squircle(hair, (hs * 0.92, hs * 0.9, hs * 0.48), top + Vector((0, 0.02, hs * 0.1)), power=2.2)
        m.squircle(hair, (hs * 0.7, hs * 0.55, 0.07), top + Vector((0, -hs * 0.56, 0.0)), rot=(-8, 0, 0), power=4)
    kw = dict(skin=skin, eye=0.24 * head, eye_gap=0.24 * head, eye_z=0.05 * head, mouth_z=-0.28 * head, mouth_w=0.36 * head)
    kw.update(face_kw or {})
    face(m, hc, hs * 0.42, expr=expr, **kw)
    return {"head": hc, "head_size": hs, "hands": hands, "chest": P(0, 0, chest_z), "shoulder_z": sh_z, "hip_z": hip_z, "O": O}


# ------------------------------------------------------------------------------------------
# animals
# ------------------------------------------------------------------------------------------
def leg(m, color, top, foot, r=0.14, paw=None, paw_size=0.3):
    top, foot = Vector(top), Vector(foot)
    m.tube(color, [top, foot + Vector((0, 0, r * 0.6))], lambda t: r * (1 - 0.15 * t))
    m.blob(paw or color, (paw_size, paw_size * 1.2, paw_size * 0.6), foot + Vector((0, -paw_size * 0.15, paw_size * 0.28)))


def ear(m, color, base, tip, width=0.3, inner=None, thick=0.08):
    """A pointy ear from base to tip (a flattened cone), with an optional inner color."""
    base, tip = Vector(base), Vector(tip)
    d = tip - base
    length = d.length
    pitch = math.degrees(math.atan2(math.hypot(d.x, d.y), d.z))
    yaw = math.degrees(math.atan2(d.x, -d.y)) if math.hypot(d.x, d.y) > 1e-4 else 0
    mid = (base + tip) / 2
    m.cyl(color, width, length, mid, rot=(pitch, 0, yaw), radius2=0.02, seg=16, scale=(1, thick / width * 2.4, 1))
    if inner:
        m.cyl(inner, width * 0.6, length * 0.8, mid + Vector((0, -thick * 0.5, -length * 0.05)), rot=(pitch, 0, yaw),
              radius2=0.01, seg=12, scale=(1, thick / width * 1.2, 1))
