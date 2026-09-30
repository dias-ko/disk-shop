"""Rebuild original synthesized audio and the initial editable map (overwrites it)."""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
RATE = 22050
rng = random.Random(73)

def wav(name, samples):
    path = ROOT / 'assets' / 'audio' / (name + '.wav')
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), 'wb') as f:
        f.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        f.writeframes(b''.join(struct.pack('<h', round(max(-0.95, min(0.95, s)) * 32767)) for s in samples))

def tone(freq, t, decay=10):
    return math.sin(math.tau * freq * t) * math.exp(-t * decay)

def sound(name, duration, fn):
    wav(name, [fn(i / RATE) * min(1, i / 80) for i in range(int(duration * RATE))])

sound('hit', .14, lambda t: (rng.uniform(-1, 1) * .35 + tone(100, t, 25) * .5) * math.exp(-t * 25))
sound('coin', .2, lambda t: tone(880 if t < .08 else 1320, t, 14) * .5)
sound('ability', .4, lambda t: math.sin(math.tau * (240 * t - 230 * t*t)) * math.exp(-t*9) * .7)
sound('shop', .25, lambda t: (tone(440, t, 15) + tone(660, t, 15)) * .3)
sound('host', .27, lambda t: (tone(170, t, 8) + .4*tone(510, t, 8)) * (.45 + .4*math.sin(t*55)))
sound('win', 1.3, lambda t: sum(tone(f, max(0, t-j*.12), 4) if t >= j*.12 else 0 for j, f in enumerate([330, 440, 550, 660])) * .23)
beat_seconds = 60 / 88
duration = beat_seconds * 16
samples = []
for i in range(int(duration * RATE)):
    t = i / RATE
    beat = int(t / beat_seconds)
    p = t % beat_seconds
    kick = math.sin(math.tau * (58 * p + 4 * (1-math.exp(-p*30)))) * math.exp(-p*22) * .55 if beat % 4 in (0, 2) else 0
    snare = rng.uniform(-1, 1) * math.exp(-p*27) * .28 if beat % 4 in (1, 3) else 0
    hat_phase = t % (beat_seconds / 2)
    hat = rng.uniform(-1, 1) * math.exp(-hat_phase*130) * .1
    bass_freq = [55, 55, 65.406, 49][beat // 4]
    bass = math.sin(math.tau * bass_freq * t) * math.exp(-p*4) * .20
    chord_phase = t % (beat_seconds * 2)
    chord = sum(math.sin(math.tau * f * t) for f in [220, 261.626, 329.628]) * .025 * math.exp(-chord_phase*3)
    samples.append(kick + snare + hat + bass + chord)
wav('beat', samples)

# A fixed fan of routes; unpainted exterior is void. All data remains editable.
w, h = 31, 39
grid = [[' '] * w for _ in range(h)]
for y in range(h):
    half = min(14, 2 + y // 3)
    for x in range(15-half, 16+half):
        grid[y][x] = '#'
    if 1 <= y <= 36:
        for x in range(16-half, 15+half):
            tier = 1 if y < 6 else 2 if y < 13 else 3 if y < 25 else 4
            grid[y][x] = str(tier)
        # Central expensive route; winding side paths offer weaker blocks.
        if y >= 6:
            grid[y][15] = '4' if y >= 15 else '3'
        if y >= 8:
            for side in (-1, 1):
                xx = 15 + side * (half - 1)
                grid[y][xx] = str(max(1, tier - 1))
        if y in (9, 16, 23, 30):
            for x in range(16-half, 15+half):
                if x not in (15, 16-half, 14+half): grid[y][x] = '#'
for y in range(1, 4):
    for x in range(14, 17): grid[y][x] = '.'
grid[1][15] = 'E'
for x, y, symbol in [(12, 8, 'S'), (21, 20, 'G'), (4, 33, 'P'), (15, 37, 'D')]:
    grid[y][x] = symbol
    grid[y-1][x] = '.'
for x, y in [(17, 7), (11, 14), (23, 27), (7, 28)]: grid[y][x] = '$'
tiles = '\n'.join(''.join(row) for row in grid)
encoded = tiles.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
(ROOT / 'data' / 'shop_layout.tres').write_text(
    '[gd_resource type="Resource" script_class="ShopLayout" load_steps=2 format=3]\n\n'
    '[ext_resource type="Script" path="res://scripts/map_layout.gd" id="1"]\n\n'
    '[resource]\nscript = ExtResource("1")\ntiles = "' + encoded + '"\n', encoding='utf-8')
print('Generated map and original synthesized WAV assets.')
