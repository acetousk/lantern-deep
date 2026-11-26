"""Makes the sound effects for Lantern Deep. No downloads, only Python itself.

Run:  python3 tools/make_sfx.py
Writes short WAV files into sfx/ (16-bit, mono, 22050 Hz).

How a sound is made: a wave (beep) or noise (hiss), a pitch that can slide
up or down, and a volume that fades out. Change the numbers below to change a sound.
"""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050  # Samples per second.
OUT = Path(__file__).resolve().parent.parent / "sfx"
rng = random.Random(7)  # Same numbers every time = the same sounds every time.


def tone(start_hz, end_hz, seconds, shape="square", volume=0.4, noise=0.0, fade=6.0):
    """One sound: the pitch slides from start_hz to end_hz.
    shape: "sine" (soft), "square" (retro), "tri" (in between).
    noise: 0 = clean, 1 = only hiss. fade: bigger = dies out faster."""
    samples = []
    phase = 0.0
    n = int(RATE * seconds)
    for i in range(n):
        t = i / n
        hz = start_hz + (end_hz - start_hz) * t
        phase += hz / RATE
        p = phase % 1.0
        if shape == "sine":
            w = math.sin(2 * math.pi * p)
        elif shape == "tri":
            w = 4 * abs(p - 0.5) - 1
        else:
            w = 1.0 if p < 0.5 else -1.0
        w = w * (1 - noise) + rng.uniform(-1, 1) * noise
        attack = min(1.0, i / (RATE * 0.004))  # 4 ms fade in, so it doesn't click.
        samples.append(w * volume * attack * math.exp(-fade * t))
    return samples


def notes(hz_list, each, **kw):
    """A few short tones one after another (like a little tune)."""
    out = []
    for hz in hz_list:
        out += tone(hz, hz, each, **kw)
    return out


def silence(seconds):
    return [0.0] * int(RATE * seconds)


SOUNDS = {
    # You take a step: a tiny soft tap.
    "step": lambda: tone(180, 120, 0.05, shape="tri", volume=0.25, noise=0.6, fade=10),
    # You or a monster lands a hit: a crunchy thump.
    "hit": lambda: tone(260, 70, 0.14, volume=0.45, noise=0.5, fade=7),
    # A swing that misses: a soft whoosh.
    "miss": lambda: tone(500, 300, 0.12, shape="sine", volume=0.25, noise=0.85, fade=5),
    # You get hurt: a sharp falling buzz.
    "hurt": lambda: tone(330, 140, 0.2, volume=0.4, noise=0.15, fade=5),
    # A hero dies: a long slide down.
    "die": lambda: tone(400, 60, 0.6, shape="tri", volume=0.45, noise=0.1, fade=3),
    # Level up: 4 notes going up (C E G C).
    "level_up": lambda: notes([523, 659, 784, 1047], 0.08, volume=0.3, fade=3),
    # Drink a potion: 3 little bubbles going up.
    "drink": lambda: tone(300, 600, 0.07, shape="sine", volume=0.35, fade=4) + silence(0.03)
    + tone(400, 800, 0.07, shape="sine", volume=0.35, fade=4) + silence(0.03)
    + tone(500, 1000, 0.07, shape="sine", volume=0.35, fade=4),
    # Go down the stairs: 3 notes going down.
    "stairs": lambda: notes([659, 523, 392], 0.1, shape="tri", volume=0.35, fade=3),
    # Grab the Ember Relic: a bright happy tune.
    "relic": lambda: notes([523, 659, 784, 1047, 1319], 0.1, volume=0.3, fade=2)
    + tone(1047, 1047, 0.4, shape="sine", volume=0.3, fade=4),
    # Everyone died: a slow sad tune going down.
    "lose": lambda: notes([392, 311, 262], 0.25, shape="tri", volume=0.35, fade=2)
    + tone(196, 180, 0.5, shape="tri", volume=0.35, fade=3),
    # A menu button: a tiny tick.
    "click": lambda: tone(1200, 1000, 0.03, shape="sine", volume=0.3, fade=8),
}


def save(name, samples):
    OUT.mkdir(exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))


if __name__ == "__main__":
    for name, make in SOUNDS.items():
        samples = make()
        save(name, samples)
        print(f"sfx/{name}.wav  {len(samples) / RATE:.2f} s")
