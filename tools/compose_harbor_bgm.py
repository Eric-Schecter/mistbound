"""Original Mistbound miniature waltz. Pure synthesis, no external recordings."""
from array import array
from pathlib import Path
import math, wave
SR = 22050
BEAT = 60 / 90
BARS = 24
N = round(BARS * 3 * BEAT * SR)
left, right = array('f', [0]) * N, array('f', [0]) * N

def note(beat, midi, duration, gain, kind='pluck', pan=0):
    freq = 440 * 2 ** ((midi - 69) / 12)
    length = int(duration * SR)
    start = round(beat * BEAT * SR)
    for i in range(length):
        t = i / SR
        attack = min(1, t / .012)
        release = min(1, (duration - t) / .12)
        if kind == 'bass':
            v = (math.sin(math.tau*freq*t)+.22*math.sin(math.tau*2*freq*t)) * math.exp(-t*2.5)
        elif kind == 'wood':
            v = (math.sin(math.tau*freq*t)*math.exp(-t*4)+.22*math.sin(math.tau*4*freq*t)*math.exp(-t*15))
        else:
            v = sum(a*math.sin(math.tau*freq*h*t)*math.exp(-t*(2.4+h)) for h,a in [(1,1),(2,.32),(3,.12)])
        v *= gain * attack * release
        j = (start + i) % N
        left[j] += v * math.sqrt((1-pan)/2)
        right[j] += v * math.sqrt((1+pan)/2)

# D major; a gentle 8-bar question/answer, then variation and return.
chords = [(50, [62,66,69]), (47,[62,66,71]), (43,[62,67,71]), (45,[61,64,69]),
          (50,[62,66,69]), (43,[62,67,71]), (45,[61,64,69]), (50,[62,66,69])]
melodies = [[(0,74),(1,78),(2,76)],[(.5,73),(1.5,74)],[(0,71),(1,74),(2.5,78)],[(0,76),(2,73)],
            [(0,74),(1.5,81),(2,78)],[(0,79),(1,78),(2,74)],[(.5,76),(1.5,73)],[(0,74)]]
for bar in range(BARS):
    root, chord = chords[bar%8]
    note(bar*3,root,1.4,.18,'bass',-.05)
    for b in [1,2]:
        for k,p in enumerate(chord): note(bar*3+b+k*.045,p,.75,.065,'pluck',-.35+k*.16)
    for b,p in melodies[bar%8]:
        if 8 <= bar < 16: p = p-12 if bar%2 else p
        note(bar*3+b,p,1.2,.13,'wood',.25)
    if bar%4==3: note(bar*3+2.5,81,.55,.045,'wood',-.3)
# Circular short room reflections preserve the loop seam and natural tails.
for channel in [left,right]:
    dry = array('f',channel)
    for delay,gain in [(.073,.12),(.137,.08),(.239,.045)]:
        offset=round(delay*SR)
        for i in range(N): channel[(i+offset)%N] += dry[i]*gain
peak=max(max(abs(v) for v in left),max(abs(v) for v in right))
scale=10**(-3/20)/peak
pcm=array('h')
for l,r in zip(left,right): pcm.extend((round(l*scale*32767),round(r*scale*32767)))
path=Path(__file__).resolve().parents[1]/'assets/audio/mistbound-harbor-bgm.wav'
with wave.open(str(path),'wb') as out:
    out.setnchannels(2); out.setsampwidth(2); out.setframerate(SR); out.writeframes(pcm.tobytes())
print(f'{path}: {N/SR:.1f}s, original 90 BPM 3/4 seamless loop')
