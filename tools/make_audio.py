"""Composes the game's music and sound effects from scratch (no samples, all synthesized).

Writes assets/audio/*.ogg:
  music_world1.ogg ... music_world9.ogg   a seamless loop for every world, each in its own style
  sfx_dig.ogg      soft dirt/rock crunch, treble rolled off
  sfx_find.ogg     short clean chime (about 1.2 s)
  sfx_click.ogg    soft pop for UI buttons
  sfx_clang.ogg    gentle metallic "tink" when a pickaxe bounces off hard rock
  sfx_combo.ogg    tiny rising blip for combos

You only need this if you want to change the audio. It needs:  pip install numpy soundfile
Then upload the files with tools/upload_audio.py (standard Python only).
    python3 tools/make_audio.py            (everything)
    python3 tools/make_audio.py sfx        (just the sound effects)
    python3 tools/make_audio.py 3          (just World 3's music)
"""
import os, sys
import numpy as np
import soundfile as sf

SR = 32000
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "audio")


# ---------------------------------------------------------------------------------------------
# BASICS
# ---------------------------------------------------------------------------------------------
def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12.0)


def seconds(n):
    return np.arange(int(n)) / SR


def fft_filter(x, low=None, high=None, slope=1.5):
    """Smooth band filter in the frequency domain. low = high-pass corner, high = low-pass corner."""
    n = len(x)
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / SR)
    gain = np.ones_like(f)
    if high:
        gain *= 1 / (1 + (f / high) ** (2 * slope))
    if low:
        gain *= 1 / (1 + (low / np.maximum(f, 1e-3)) ** (2 * slope))
    return np.fft.irfft(spec * gain, n)


def envelope(n, attack=0.005, decay=0.4, release=0.02):
    t = seconds(n)
    env = np.minimum(1, t / max(attack, 1e-4)) * np.exp(-t / max(decay, 1e-4))
    r = int(release * SR)
    if 0 < r < n:
        env[-r:] *= np.linspace(1, 0, r)
    return env


def place(buf, sig, start, wrap=True):
    """Adds sig into buf at start (in samples); whatever runs past the end wraps to the start,
    so the loop stays seamless."""
    start = int(start) % len(buf)
    end = start + len(sig)
    if end <= len(buf):
        buf[start:end] += sig
    else:
        cut = len(buf) - start
        buf[start:] += sig[:cut]
        if wrap:
            rest = sig[cut:]
            while len(rest) > 0:
                k = min(len(rest), len(buf))
                buf[:k] += rest[:k]
                rest = rest[k:]


def reverb(x, size=2.0, damp=4000, mix=0.3, seed=1):
    """Circular convolution with a decaying noise tail: a soft room/hall that also wraps around
    the loop point (no gap when the track repeats)."""
    rng = np.random.default_rng(seed)
    n = int(size * SR)
    ir = rng.standard_normal(n) * np.exp(-seconds(n) / (size / 5))
    ir = fft_filter(ir, low=200, high=damp)
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
    L = len(x)
    padded = np.zeros(L)
    padded[: min(n, L)] = ir[: min(n, L)]
    wet = np.fft.irfft(np.fft.rfft(x) * np.fft.rfft(padded), L)
    return x * (1 - mix) + wet * mix * 1.4


# ---------------------------------------------------------------------------------------------
# INSTRUMENTS (additive, so everything is vectorized and fast)
# ---------------------------------------------------------------------------------------------
def epiano(f, dur, vel=0.6):
    n = int((dur + 1.2) * SR)
    t = seconds(n)
    out = np.zeros(n)
    for k, a in [(1, 1), (2, 0.35), (3, 0.12), (4, 0.06), (7, 0.02)]:
        out += a * np.sin(2 * np.pi * f * k * t) * np.exp(-t * (0.9 + 1.4 * k))
    out *= 1 + 0.08 * np.sin(2 * np.pi * 4.5 * t)  # gentle tremolo
    return out * envelope(n, 0.004, 9, 0.05) * vel


def pluck(f, dur, vel=0.6, bright=1.0, decay=1.2):
    n = int((decay * 2 + 0.2) * SR)
    t = seconds(n)
    out = np.zeros(n)
    for k in range(1, 10):
        if f * k > SR / 2.2:
            break
        out += (bright ** (k - 1)) / k * np.sin(2 * np.pi * f * k * t + k) * np.exp(-t * (1 / decay) * (1 + 0.7 * k))
    return out * envelope(n, 0.002, 99, 0.02) * vel


def bell(f, dur, vel=0.5, decay=2.2):
    n = int((decay * 2.5) * SR)
    t = seconds(n)
    out = np.zeros(n)
    for ratio, a, d in [(1, 1, 1), (2.01, 0.45, 0.7), (3.0, 0.18, 0.5), (4.2, 0.14, 0.35), (5.43, 0.06, 0.25)]:
        out += a * np.sin(2 * np.pi * f * ratio * t) * np.exp(-t / (decay * d))
    return out * envelope(n, 0.002, 99, 0.05) * vel


def pad(f, dur, vel=0.3, partials=8, detune=0.004, attack=0.9, bright=0.8):
    n = int((dur + 1.0) * SR)
    t = seconds(n)
    out = np.zeros(n)
    for d in (-detune, detune):
        for k in range(1, partials + 1):
            if f * k > 7000:
                break
            out += (bright ** (k - 1)) / k * np.sin(2 * np.pi * f * (1 + d) * k * t + k * 1.7)
    env = np.minimum(1, t / attack)
    rel = int(1.0 * SR)
    env[-rel:] *= np.linspace(1, 0, rel)
    return out * env * vel / partials * 2.2


def bass(f, dur, vel=0.7, drive=1.4):
    n = int((dur + 0.1) * SR)
    t = seconds(n)
    x = np.sin(2 * np.pi * f * t) + 0.25 * np.sin(2 * np.pi * 2 * f * t)
    x = np.tanh(drive * x) / np.tanh(drive)
    return x * envelope(n, 0.006, max(dur * 1.2, 0.15), 0.03) * vel


def saw(f, dur, vel=0.4, cutoff=3000, decay=0.6):
    n = int((dur + 0.15) * SR)
    t = seconds(n)
    out = np.zeros(n)
    k = 1
    while f * k < min(cutoff * 2.5, SR / 2.2):
        roll = 1 / (1 + (f * k / cutoff) ** 2)
        out += roll / k * np.sin(2 * np.pi * f * k * t)
        k += 1
    return out * envelope(n, 0.004, decay, 0.04) * vel


def square(f, dur, vel=0.35, decay=0.25):
    n = int((dur + 0.1) * SR)
    t = seconds(n)
    out = np.zeros(n)
    for k in range(1, 12, 2):
        if f * k > 6000:
            break
        out += 1 / k * np.sin(2 * np.pi * f * k * t)
    return out * envelope(n, 0.002, decay, 0.03) * vel


# ------------------------------------------ DRUMS --------------------------------------------
_rng = np.random.default_rng(7)


def noise(n):
    return _rng.standard_normal(int(n))


def kick(vel=0.9, low=48, punch=70):
    n = int(0.45 * SR)
    t = seconds(n)
    freq = low + punch * np.exp(-t * 28)
    phase = 2 * np.pi * np.cumsum(freq) / SR
    return np.sin(phase) * np.exp(-t * 7) * vel


def snare(vel=0.5, tone=190, tail=16):
    n = int(0.35 * SR)
    t = seconds(n)
    body = np.sin(2 * np.pi * tone * t) * np.exp(-t * 28)
    rattle = fft_filter(noise(n), low=900, high=7000) * np.exp(-t * tail)
    return (0.6 * body + 0.9 * rattle / (np.abs(rattle).max() + 1e-9)) * vel


def hat(vel=0.18, length=0.06):
    n = int(0.12 * SR)
    t = seconds(n)
    x = fft_filter(noise(n), low=6000, high=11000)
    return x / (np.abs(x).max() + 1e-9) * np.exp(-t / length * 5) * vel


def shaker(vel=0.12):
    n = int(0.12 * SR)
    t = seconds(n)
    x = fft_filter(noise(n), low=4500, high=10000)
    return x / (np.abs(x).max() + 1e-9) * np.sin(np.pi * np.minimum(1, t / 0.1)) * vel


def clap(vel=0.45):
    n = int(0.3 * SR)
    t = seconds(n)
    x = fft_filter(noise(n), low=1000, high=6000)
    x = x / (np.abs(x).max() + 1e-9)
    env = np.exp(-t * 20)
    for off in (0.0, 0.012, 0.024):
        env += np.exp(-np.maximum(t - off, 0) * 120) * (t >= off)
    return x * env * vel * 0.5


def tom(f=90, vel=0.8, length=0.5):
    n = int(length * SR)
    t = seconds(n)
    freq = f + f * 0.6 * np.exp(-t * 18)
    phase = 2 * np.pi * np.cumsum(freq) / SR
    hit = fft_filter(noise(n), low=200, high=2000) * np.exp(-t * 60) * 0.3
    return (np.sin(phase) * np.exp(-t / (length / 4)) + hit) * vel


def darbuka(kind, vel=0.5):
    if kind == "d":  # doum: deep center hit
        return tom(110, vel, 0.4)
    n = int(0.12 * SR)  # tek: bright rim slap
    t = seconds(n)
    x = fft_filter(noise(n), low=1500, high=7000)
    return (x / (np.abs(x).max() + 1e-9) * np.exp(-t * 45) + 0.4 * np.sin(2 * np.pi * 620 * t) * np.exp(-t * 40)) * vel * 0.6


# ------------------------------------------- FX ----------------------------------------------
def crackle(n, amount=0.012):
    x = np.zeros(int(n))
    pops = _rng.integers(0, int(n), int(n / SR * 9))
    x[pops] = _rng.standard_normal(len(pops))
    x = fft_filter(x, low=800, high=5000)
    hiss = fft_filter(noise(n), low=2000, high=7000) * 0.05
    return (x / (np.abs(x).max() + 1e-9) + hiss) * amount


def wind(n, amount=0.05):
    x = fft_filter(noise(n), low=200, high=1200)
    t = seconds(n)
    swell = 0.6 + 0.4 * np.sin(2 * np.pi * t / 7.3) * np.sin(2 * np.pi * t / 3.1)
    return x / (np.abs(x).max() + 1e-9) * swell * amount


def bubbles(n, amount=0.08, rate=1.5):
    out = np.zeros(int(n))
    for _ in range(int(n / SR * rate)):
        start = _rng.integers(0, int(n))
        length = int(_rng.uniform(0.04, 0.12) * SR)
        t = seconds(length)
        f0 = _rng.uniform(500, 1400)
        sig = np.sin(2 * np.pi * np.cumsum(f0 * (1 + 3 * t / t[-1])) / SR) * np.sin(np.pi * t / t[-1])
        place(out, sig * _rng.uniform(0.3, 1), start)
    return out * amount


# ---------------------------------------------------------------------------------------------
# CHORDS + ARRANGING
# ---------------------------------------------------------------------------------------------
QUALITY = {
    "maj": [0, 4, 7], "min": [0, 3, 7], "maj7": [0, 4, 7, 11], "min7": [0, 3, 7, 10], "dom7": [0, 4, 7, 10],
    "maj9": [0, 4, 7, 11, 14], "min9": [0, 3, 7, 10, 14], "sus2": [0, 2, 7], "sus4": [0, 5, 7], "six": [0, 4, 7, 9],
    "add9": [0, 4, 7, 14], "madd9": [0, 3, 7, 14], "five": [0, 7, 12],
}


def chord(root, quality):
    return [root + i for i in QUALITY[quality]]


class Song:
    def __init__(self, bpm, bars, beats_per_bar=4):
        self.bpm = bpm
        self.beat = 60 / bpm
        self.bars = bars
        self.bar = self.beat * beats_per_bar
        self.length = int(round(self.bar * bars * SR))
        self.stems = {}

    def stem(self, name):
        if name not in self.stems:
            self.stems[name] = np.zeros(self.length)
        return self.stems[name]

    def at(self, bar, beat=0.0):
        return int(round((bar * self.bar + beat * self.beat) * SR))

    def pattern(self, name, bar, steps, sounds, swing=0.0, steps_per_beat=4):
        """steps like "x...x..." (one char per 16th); sounds[char] = sample (or function)"""
        buf = self.stem(name)
        for i, ch in enumerate(steps):
            if ch in sounds:
                beat = i / steps_per_beat
                if swing and i % 2 == 1:
                    beat += swing / steps_per_beat
                s = sounds[ch]
                place(buf, s() if callable(s) else s, self.at(bar, beat))


def master(song, levels, reverb_sends, lowpass=None, highpass=40, crackle_amt=0, target_rms=0.12):
    mix = np.zeros(song.length)
    wet = np.zeros(song.length)
    for name, stem in song.stems.items():
        level = levels.get(name, 0.5)
        mix += stem * level
        wet += stem * level * reverb_sends.get(name, 0.2)
    mix += reverb(wet, size=2.4, mix=1.0) * 0.8
    if crackle_amt:
        mix += crackle(song.length, crackle_amt)
    mix = fft_filter(mix, low=highpass, high=lowpass)
    # loudness: same average level for every track, gentle soft-clip for the peaks
    rms = np.sqrt(np.mean(mix ** 2)) + 1e-9
    mix *= target_rms / rms
    mix = np.tanh(mix * 1.1) / 1.1
    peak = np.abs(mix).max()
    if peak > 0.9:
        mix *= 0.9 / peak
    return mix


def seeded(world):
    return np.random.default_rng(1000 + world)


def melody(song, name, rng, bars, chords_per_bar, prog, scale, instrument, octave=72, density=0.55, vel=0.45, step=0.5):
    """a simple motif-based melody: chord tones on strong beats, scale steps in between"""
    buf = song.stem(name)
    motif = [rng.random() < density for _ in range(int(4 / step))]
    motif[0] = True
    for bar in bars:
        root, quality = prog[(bar // chords_per_bar) % len(prog)]
        tones = [((root + i) % 12) for i in QUALITY[quality]]
        prev = None
        for i, on in enumerate(motif):
            if not on:
                continue
            beat = i * step
            if beat % 1 == 0:  # strong beat: a chord tone
                pc = tones[rng.integers(0, len(tones))]
            else:
                pc = scale[rng.integers(0, len(scale))]
            note = octave + ((pc - octave) % 12)
            if prev is not None and abs(note - prev) > 7:
                note += -12 if note > prev else 12
            prev = note
            place(buf, instrument(hz(note), step * song.beat * 1.6, vel * rng.uniform(0.8, 1.05)), song.at(bar, beat))


# ---------------------------------------------------------------------------------------------
# THE WORLDS
# ---------------------------------------------------------------------------------------------
def world1():  # The Meme Dig Site: lo-fi chill beats
    s = Song(78, 24)
    rng = seeded(1)
    prog = [(53, "maj9"), (52, "min7"), (50, "min9"), (48, "maj9")]  # Fmaj9 Em7 Dm9 Cmaj9
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        for i, n in enumerate(chord(root, q)):
            place(s.stem("keys"), epiano(hz(n + 12), s.bar * 2, 0.35), s.at(bar, 0 if bar % 2 == 0 else 2.5) + i * 180)
        place(s.stem("bass"), bass(hz(root - 12), s.beat * 1.5, 0.7), s.at(bar, 0))
        place(s.stem("bass"), bass(hz(root - 12 + 7), s.beat * 0.8, 0.5), s.at(bar, 2.5))
        if bar >= 4:
            s.pattern("drums", bar, "x.........x.....", {"x": kick(0.85)}, swing=0.35)
            s.pattern("drums", bar, "....x.......x...", {"x": snare(0.45)}, swing=0.35)
            s.pattern("hats", bar, "x.x.x.x.x.x.xx.x", {"x": lambda: hat(rng.uniform(0.1, 0.18))}, swing=0.35)
    melody(s, "lead", rng, range(8, 24), 2, prog, [0, 2, 4, 5, 7, 9, 11], lambda f, d, v: epiano(f, d, v * 0.8), octave=76, density=0.4)
    return master(s, {"keys": 0.7, "bass": 0.8, "drums": 0.9, "hats": 0.6, "lead": 0.5},
                  {"keys": 0.35, "lead": 0.4, "drums": 0.08}, lowpass=6500, crackle_amt=0.02)


def world2():  # Neon Sakura Grove: koto plucks over a soft pad
    s = Song(84, 24)
    rng = seeded(2)
    prog = [(50, "min9"), (46, "maj7"), (43, "min7"), (45, "min7")]  # Dm9 Bbmaj7 Gm7 Am7
    koto = lambda f, d, v: pluck(f, d, v, bright=0.55, decay=0.9)
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        if bar % 2 == 0:
            for n in chord(root, q)[:4]:
                place(s.stem("pad"), pad(hz(n), s.bar * 2, 0.22, bright=0.6), s.at(bar))
        notes = chord(root, q)
        for i in range(8):  # rolling koto arpeggio
            n = notes[[0, 2, 1, 3, 2, 1, 3, 2][i] % len(notes)] + 12
            place(s.stem("koto"), koto(hz(n), s.beat * 0.5, 0.35 if i % 2 else 0.45), s.at(bar, i * 0.5))
        place(s.stem("bass"), bass(hz(root - 12), s.beat * 3, 0.5), s.at(bar))
        if bar >= 4:
            s.pattern("drums", bar, "x.......x.......", {"x": kick(0.55, 50, 40)})
            s.pattern("drums", bar, "..x...x...x...xx", {"x": lambda: shaker(rng.uniform(0.08, 0.14))})
    melody(s, "lead", rng, range(12, 24), 2, prog, [2, 5, 7, 9, 0], koto, octave=79, density=0.45, vel=0.5)
    return master(s, {"pad": 0.6, "koto": 0.7, "bass": 0.6, "drums": 0.7, "lead": 0.7},
                  {"pad": 0.4, "koto": 0.35, "lead": 0.45}, lowpass=9000)


def world3():  # Galaxy Drift: dreamy space ambient
    s = Song(66, 20)
    rng = seeded(3)
    prog = [(52, "maj9"), (49, "min9"), (45, "maj9"), (47, "sus4")]  # Emaj9 C#m9 Amaj9 Bsus4
    for bar in range(0, s.bars, 2):
        root, q = prog[(bar // 2) % 4]
        for n in chord(root, q):
            place(s.stem("pad"), pad(hz(n), s.bar * 2 + 1, 0.28, partials=10, detune=0.006, attack=2.2, bright=0.85), s.at(bar))
        place(s.stem("bass"), pad(hz(root - 24), s.bar * 2, 0.35, partials=3, attack=1.5), s.at(bar))
        for i in range(6):  # slow shimmering bell arpeggio
            notes = chord(root, q)
            n = notes[rng.integers(0, len(notes))] + 24
            place(s.stem("bells"), bell(hz(n), 1, rng.uniform(0.12, 0.22), decay=3), s.at(bar, i * 1.33))
    return master(s, {"pad": 0.7, "bass": 0.6, "bells": 0.6}, {"pad": 0.6, "bells": 0.7}, lowpass=8000, target_rms=0.1)


def world4():  # Frostbyte Tundra: icy bells, airy pad and wind
    s = Song(72, 20)
    rng = seeded(4)
    prog = [(57, "min9"), (53, "maj7"), (48, "maj7"), (55, "six")]  # Am9 Fmaj7 Cmaj7 G6
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        if bar % 2 == 0:
            for n in chord(root, q):
                place(s.stem("pad"), pad(hz(n - 12), s.bar * 2, 0.2, attack=1.5, bright=0.7), s.at(bar))
            place(s.stem("bass"), bass(hz(root - 24), s.bar * 1.8, 0.45, drive=1.0), s.at(bar))
        notes = chord(root, q)
        for i in range(8):
            if rng.random() < 0.7:
                n = notes[rng.integers(0, len(notes))] + 24
                place(s.stem("bells"), bell(hz(n), 0.5, rng.uniform(0.12, 0.2), decay=1.5), s.at(bar, i * 0.5))
        if bar >= 4:
            s.pattern("drums", bar, "x.......x..x....", {"x": kick(0.5, 45, 40)})
            s.pattern("drums", bar, "....x.......x...", {"x": snare(0.18, 260, 30)})
    s.stem("air")[:] += wind(s.length, 0.05)
    return master(s, {"pad": 0.6, "bells": 0.7, "bass": 0.5, "drums": 0.6, "air": 0.6},
                  {"pad": 0.5, "bells": 0.6}, lowpass=10000)


def world5():  # Chrome Dunes: desert adventure (E phrygian dominant, hand drums, oud)
    s = Song(96, 24)
    rng = seeded(5)
    oud = lambda f, d, v: pluck(f, d, v, bright=0.7, decay=0.6)
    prog = [(40, "maj"), (41, "maj"), (40, "maj"), (38, "min")]  # E F E Dm
    scale = [4, 5, 8, 9, 11, 0, 2]  # E F G# A B C D
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        if bar % 2 == 0:
            place(s.stem("drone"), pad(hz(40), s.bar * 2, 0.3, partials=6, attack=0.5), s.at(bar))
            place(s.stem("drone"), pad(hz(47), s.bar * 2, 0.18, partials=6, attack=0.5), s.at(bar))
        s.pattern("drums", bar, "d..tt.d.d..tt.t.", {"d": darbuka("d", 0.6), "t": lambda: darbuka("t", rng.uniform(0.35, 0.5))})
        place(s.stem("bass"), bass(hz(root - 12), s.beat * 0.9, 0.6), s.at(bar))
        place(s.stem("bass"), bass(hz(root - 12), s.beat * 0.9, 0.45), s.at(bar, 2.5))
    melody(s, "lead", rng, range(4, 24), 2, prog, scale, oud, octave=64, density=0.6, vel=0.55, step=0.5)
    return master(s, {"drone": 0.5, "drums": 0.85, "bass": 0.6, "lead": 0.8},
                  {"drone": 0.3, "lead": 0.35, "drums": 0.12}, lowpass=9000)


def world6():  # Coral Circuit: muffled, underwater chill with bubbles
    s = Song(70, 20)
    rng = seeded(6)
    prog = [(50, "maj9"), (47, "min9"), (43, "maj9"), (45, "six")]  # Dmaj9 Bm9 Gmaj9 A6
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        for i, n in enumerate(chord(root, q)):
            place(s.stem("keys"), epiano(hz(n + 12), s.bar, 0.3), s.at(bar, 0 if bar % 2 == 0 else 1.5) + i * 260)
        if bar % 2 == 0:
            for n in chord(root, q)[:3]:
                place(s.stem("pad"), pad(hz(n), s.bar * 2, 0.2, attack=1.5, bright=0.6), s.at(bar))
        place(s.stem("bass"), bass(hz(root - 12), s.beat * 2, 0.55, drive=1.0), s.at(bar))
        if bar >= 4:
            s.pattern("drums", bar, "x.......x.x.....", {"x": kick(0.6, 45, 45)})
    s.stem("fx")[:] += bubbles(s.length, 0.08, 1.2)
    return master(s, {"keys": 0.8, "pad": 0.6, "bass": 0.7, "drums": 0.7, "fx": 0.5},
                  {"keys": 0.5, "pad": 0.5, "fx": 0.4}, lowpass=2600)


def world7():  # Candy Mainframe: bubbly, bright pop
    s = Song(112, 32)
    rng = seeded(7)
    prog = [(60, "maj"), (57, "min"), (53, "maj"), (55, "maj")]  # C Am F G
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        notes = chord(root, q)
        for i in range(8):
            n = notes[i % 3] + (12 if i >= 4 else 0)
            place(s.stem("plucks"), square(hz(n), s.beat * 0.4, 0.22, decay=0.12), s.at(bar, i * 0.5))
        place(s.stem("bass"), bass(hz(root - 24), s.beat * 0.9, 0.6), s.at(bar))
        place(s.stem("bass"), bass(hz(root - 12), s.beat * 0.4, 0.5), s.at(bar, 1.5))
        place(s.stem("bass"), bass(hz(root - 24), s.beat * 0.9, 0.55), s.at(bar, 2))
        if bar >= 4:
            s.pattern("drums", bar, "x...x...x...x...", {"x": kick(0.7, 55, 60)})
            s.pattern("drums", bar, "....x.......x...", {"x": clap(0.5)})
            s.pattern("hats", bar, "..x...x...x...x.", {"x": hat(0.14)})
    melody(s, "lead", rng, range(8, 32), 2, prog, [0, 2, 4, 7, 9], lambda f, d, v: bell(f, d, v, 0.8), octave=79, density=0.55, vel=0.35)
    return master(s, {"plucks": 0.6, "bass": 0.7, "drums": 0.85, "hats": 0.6, "lead": 0.7},
                  {"plucks": 0.3, "lead": 0.35, "drums": 0.05}, lowpass=11000)


def world8():  # Volcano Forge: heavy drums, dark minor riff, drone
    s = Song(88, 24)
    rng = seeded(8)
    prog = [(48, "min"), (44, "maj"), (46, "maj"), (43, "min")]  # Cm Ab Bb Gm
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        if bar % 2 == 0:
            for n in chord(root, q):
                place(s.stem("pad"), pad(hz(n - 12), s.bar * 2, 0.22, attack=1.2, bright=0.9), s.at(bar))
        s.pattern("drums", bar, "x..x..x...x.x...", {"x": lambda: tom(rng.uniform(55, 65), 0.95, 0.7)})
        s.pattern("drums", bar, "....x.......x..x", {"x": lambda: tom(rng.uniform(110, 130), 0.6, 0.4)})
        for i, st in enumerate([0, 0.75, 1.5, 2.5, 3]):  # the riff
            place(s.stem("riff"), saw(hz(root - 12 + (0 if i < 3 else 3)), s.beat * 0.6, 0.35, cutoff=900, decay=0.25), s.at(bar, st))
    melody(s, "lead", rng, range(8, 24), 2, prog, [0, 2, 3, 5, 7, 8, 10], lambda f, d, v: saw(f, d, v, 2200, 0.5), octave=67, density=0.4, vel=0.3, step=1)
    return master(s, {"pad": 0.6, "drums": 0.95, "riff": 0.7, "lead": 0.55},
                  {"pad": 0.4, "drums": 0.18, "lead": 0.3}, lowpass=7000)


def world9():  # Glitch Nexus: synthwave
    s = Song(104, 32)
    rng = seeded(9)
    prog = [(57, "min"), (53, "maj"), (48, "maj"), (55, "maj")]  # Am F C G
    for bar in range(s.bars):
        root, q = prog[(bar // 2) % 4]
        notes = chord(root, q)
        if bar % 2 == 0:
            for n in notes:
                place(s.stem("pad"), pad(hz(n), s.bar * 2, 0.2, attack=0.6, bright=0.9), s.at(bar))
        for i in range(16):  # 16th-note arpeggio
            n = notes[[0, 1, 2, 1][i % 4]] + 12 + (12 if i % 8 >= 4 else 0)
            place(s.stem("arp"), saw(hz(n), s.beat * 0.22, 0.18, cutoff=2500 + 1500 * np.sin(bar / 3), decay=0.12), s.at(bar, i * 0.25))
        for i in range(8):  # octave bass
            place(s.stem("bass"), saw(hz(root - 24 + (12 if i % 2 else 0)), s.beat * 0.45, 0.45, cutoff=700, decay=0.18), s.at(bar, i * 0.5))
        if bar >= 4:
            s.pattern("drums", bar, "x...x...x...x...", {"x": kick(0.8, 50, 70)})
            s.pattern("drums", bar, "....x.......x...", {"x": snare(0.5, 200, 9)})
            s.pattern("hats", bar, "..x...x...x...x.", {"x": hat(0.12)})
    melody(s, "lead", rng, range(16, 32), 2, prog, [9, 11, 0, 2, 4, 5, 7], lambda f, d, v: saw(f, d * 2, v, 3000, 0.7), octave=76, density=0.45, vel=0.28, step=0.5)
    return master(s, {"pad": 0.55, "arp": 0.6, "bass": 0.8, "drums": 0.9, "hats": 0.5, "lead": 0.6},
                  {"pad": 0.4, "arp": 0.35, "drums": 0.25, "lead": 0.4}, lowpass=11000)


WORLDS = [world1, world2, world3, world4, world5, world6, world7, world8, world9]


# ---------------------------------------------------------------------------------------------
# SOUND EFFECTS
# ---------------------------------------------------------------------------------------------
def finish(x, peak=0.8, fade=0.01):
    x = x.copy()
    x[: int(0.002 * SR)] *= np.linspace(0, 1, int(0.002 * SR))  # 2 ms fade-in: no click at the start
    n = int(fade * SR)
    if n and len(x) > n:
        x[-n:] *= np.linspace(1, 0, n)
    return x / (np.abs(x).max() + 1e-9) * peak


def sfx_dig():
    n = int(0.26 * SR)
    t = seconds(n)
    thud = np.sin(2 * np.pi * np.cumsum(70 + 60 * np.exp(-t * 40)) / SR) * np.exp(-t * 22)
    crunch = fft_filter(noise(n), low=250, high=2200, slope=2) * np.exp(-t * 26)
    crunch /= np.abs(crunch).max() + 1e-9
    grains = np.zeros(n)
    for _ in range(14):  # little bits of gravel
        s = _rng.integers(0, int(0.12 * SR))
        g = fft_filter(noise(int(0.012 * SR)), low=600, high=2600) * np.hanning(int(0.012 * SR))
        place(grains, g * _rng.uniform(0.2, 0.6), s, wrap=False)
    x = 0.9 * thud + 0.55 * crunch + 0.25 * grains / (np.abs(grains).max() + 1e-9)
    return finish(fft_filter(x, low=50, high=3200, slope=2), 0.8)


def sfx_find():
    n = int(1.25 * SR)
    x = np.zeros(n)
    for i, (note, v) in enumerate([(84, 0.7), (88, 0.6), (91, 0.55), (96, 0.45)]):  # C E G C, a quick sparkle
        place(x, bell(hz(note), 1, v, decay=0.45), int(i * 0.06 * SR), wrap=False)
    x = x * np.exp(-seconds(n) * 1.5)
    x = fft_filter(x, low=300, high=9000)
    return finish(x, 0.7, 0.2)


def sfx_click():
    n = int(0.07 * SR)
    t = seconds(n)
    x = np.sin(2 * np.pi * np.cumsum(620 - 250 * t / t[-1]) / SR) * np.exp(-t * 70)
    return finish(fft_filter(x, low=150, high=4000), 0.6, 0.005)


def sfx_clang():
    n = int(0.45 * SR)
    x = bell(hz(81), 0.3, 0.8, decay=0.25)[:n]
    x = x + 0.4 * fft_filter(noise(n), low=1500, high=4000) * np.exp(-seconds(n) * 60)
    return finish(fft_filter(x, low=200, high=5000), 0.6, 0.05)


def sfx_combo():
    n = int(0.12 * SR)
    t = seconds(n)
    x = np.sin(2 * np.pi * np.cumsum(700 + 500 * t / t[-1]) / SR) * np.exp(-t * 25)
    return finish(fft_filter(x, low=200, high=5000), 0.5, 0.01)


SFX = {"sfx_dig": sfx_dig, "sfx_find": sfx_find, "sfx_click": sfx_click, "sfx_clang": sfx_clang, "sfx_combo": sfx_combo}


def write(name, x):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name + ".ogg")
    x = x.astype(np.float32)
    # written in small blocks: libsndfile's Vorbis encoder can crash on one huge write
    with sf.SoundFile(path, "w", SR, 1, format="OGG", subtype="VORBIS") as f:
        for i in range(0, len(x), 8192):
            f.write(x[i:i + 8192])
    print("  %-18s %5.1fs  %4d KB" % (name, len(x) / SR, os.path.getsize(path) // 1024))


def main():
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    if which in ("all", "sfx"):
        for name, fn in SFX.items():
            write(name, fn())
    if which == "all" or which.isdigit():
        for i, fn in enumerate(WORLDS, start=1):
            if which == "all" or int(which) == i:
                write("music_world%d" % i, fn())


if __name__ == "__main__":
    main()
