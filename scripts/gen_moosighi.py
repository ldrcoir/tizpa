#!/usr/bin/env python3
# --- music composer for Tiz Pa ---
# notes: hijaz / double-harmonic scales, layered drums + bass + pads + lead
# output: 6 seamless WAV loops in game/assets/audio/
import numpy as np, soundfile as sf, os

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "game", "assets", "audio")
rng = np.random.default_rng(735311)

NOTE = {"C":0,"C#":1,"Db":1,"D":2,"D#":3,"Eb":3,"E":4,"F":5,"F#":6,"Gb":6,"G":7,"G#":8,"Ab":8,"A":9,"A#":10,"Bb":10,"B":11}
def f(n, octv):
    return 440.0 * 2 ** ((NOTE[n] + 12 * (octv - 4) - 9) / 12.0)

# hijaz-on-D and friends, as scale degrees (name, octave, semitone-offset-from-tonic not needed; explicit)
HIJAZ_D = [("D",4),("Eb",4),("F#",4),("G",4),("A",4),("Bb",4),("C",5),("D",5)]
NAHAVAND_G = [("G",4),("Ab",4),("Bb",4),("C",5),("D",5),("Eb",5),("F",5),("G",5)]

def env_exp(n, dec):
    return np.exp(-np.arange(n) / (SR * dec))

def kick(dur=0.32):
    n = int(dur * SR)
    t = np.arange(n) / SR
    fr = 150 * np.exp(-t * 28) + 44
    ph = 2 * np.pi * np.cumsum(fr) / SR
    s = np.sin(ph) * env_exp(n, 0.10)
    s += (rng.standard_normal(n) * env_exp(n, 0.012)) * 0.35
    return s

def snare(dur=0.24):
    n = int(dur * SR)
    t = np.arange(n) / SR
    nz = rng.standard_normal(n)
    nz = np.convolve(nz, np.ones(6) / 6, "same") - 0.5 * np.convolve(nz, np.ones(24) / 24, "same")
    s = nz * env_exp(n, 0.055) * 0.9
    s += np.sin(2 * np.pi * 196 * t) * env_exp(n, 0.035) * 0.5
    s += np.sin(2 * np.pi * 262 * t) * env_exp(n, 0.028) * 0.35
    return s

def hat(dur=0.09, open_=False):
    n = int(dur * SR)
    nz = rng.standard_normal(n)
    nz = nz - np.convolve(nz, np.ones(8) / 8, "same")
    return nz * env_exp(n, 0.028 if open_ else 0.012) * (0.5 if open_ else 0.34)

def bass(freq, dur, bright=0.4):
    n = int(dur * SR)
    t = np.arange(n) / SR
    saw = 2 * ((freq * t) % 1.0) - 1.0
    sub = np.sign(np.sin(2 * np.pi * freq * t / 2)) * 0.5
    s = (saw * bright + sub) * (0.35 + 0.65 * np.minimum(1, t * 90))
    one = np.exp(-1.0 / (SR * dur * 0.9))
    out = np.zeros(n); acc = 0.0
    for i in range(n):
        acc = s[i] * (1 - 0.55) + acc * one * 0.99
        out[i] = acc
    return out * env_exp(n, dur * 0.9)

def pluck(freq, dur, tone=0.5):
    n = int(dur * SR)
    t = np.arange(n) / SR
    s = np.sin(2 * np.pi * freq * t) + tone * np.sin(2 * np.pi * freq * 2 * t) + 0.3 * np.sin(2 * np.pi * freq * 3.01 * t)
    return s * env_exp(n, dur * 0.30)

def pad_chord(freqs, dur, det=0.006):
    n = int(dur * SR)
    t = np.arange(n) / SR
    s = np.zeros(n)
    for fq in freqs:
        for d in (-det, det):
            ph = fq * (1 + d)
            s += 2 * ((ph * t + rng.random()) % 1.0) - 1.0
    one = np.exp(-1.0 / (SR * 0.12))
    out = np.zeros(n); acc = 0.0
    for i in range(n):
        acc = s[i] * 0.45 + acc * one
        out[i] = acc
    a = np.minimum(1, t / 0.4) * np.minimum(1, (dur - t) / 0.5 + 0.2)
    return out * a * 0.11

def lead(freq, dur, vib=0.014):
    n = int(dur * SR)
    t = np.arange(n) / SR
    v = 1 + vib * np.sin(2 * np.pi * 5.4 * t) * np.minimum(1, t * 4)
    ph = 2 * np.pi * np.cumsum(freq * v) / SR
    s = np.sin(ph) + 0.42 * np.sin(2 * ph) + 0.16 * np.sin(3 * ph)
    a = np.minimum(1, t / 0.02) * np.exp(-np.maximum(0, t - dur * 0.72) * 9)
    return s * a * 0.30

def put(buf, sig, at, gain=1.0, pan=0.0):
    i = int(at * SR)
    if i >= buf.shape[1]:
        return
    seg = sig[: buf.shape[1] - i]
    gl = gain * min(1.0, 1.0 - pan); gr = gain * min(1.0, 1.0 + pan)
    buf[0, i:i + len(seg)] += seg * gl
    buf[1, i:i + len(seg)] += seg * gr

def fold_loop(buf, tail_s):
    """wrap the musical tail back to the start for a seamless loop"""
    n = int(tail_s * SR)
    if n <= 0 or n > buf.shape[1]:
        return buf
    ramp = np.linspace(0, 1, n)[None, :]
    buf[:, :n] += buf[:, -n:] * ramp
    return buf[:, :-n]

def compose(spec):
    bpm, bars, scale, root = spec["bpm"], spec["bars"], spec["scale"], spec["root_shift"]
    spb = 60.0 / bpm
    bar = 4 * spb
    total = bars * bar
    buf = np.zeros((2, int((total + 3 * bar) * SR)))
    ch = [(n, o + root) for (n, o) in scale]

    prog = spec.get("prog", [0, 0, 5, 3, 0, 0, 5, 4, 0, 0, 5, 3, 4, 4, 5, 5])
    prog = [p % len(ch) for p in prog]

    for b in range(bars + 2):
        at = b * bar
        deg = prog[b % len(prog)]
        # drums
        for beat in range(4):
            t = at + beat * spb
            if spec.get("drums", True) and b >= 2:
                if beat in (0, 2):
                    put(buf, kick(), t, 0.85)
                if beat == 2 and b % 4 == 3:
                    put(buf, snare(), t, 0.75)
                elif beat in (1, 3):
                    put(buf, snare(), t, 0.62)
                put(buf, hat(0.09), t, 0.5)
                put(buf, hat(0.16, True), t + spb * 0.5, 0.42)
                if beat == 3:
                    put(buf, hat(0.12), t + spb * 0.75, 0.4)
        if b >= bars - 1:
            put(buf, snare(0.5), at + 3.5 * spb, 0.8)
        # bass (root, fifth)
        bf = f(ch[deg][0], ch[deg][1] - 2)
        put(buf, bass(bf, bar * 0.94, spec.get("bass", 0.4)), at, 0.62, 0.0)
        put(buf, bass(bf * 1.5, bar * 0.45), at + 2 * spb, 0.34, 0.12)
        # pad
        tri = [f(ch[deg][0], ch[deg][1]), f(ch[(deg + 2) % len(ch)][0], ch[(deg + 2) % len(ch)][1]), f(ch[(deg + 4) % len(ch)][0], ch[(deg + 4) % len(ch)][1])]
        put(buf, pad_chord(tri, bar * 1.02, spec.get("det", 0.006)), at, spec.get("padg", 1.0))
        # santur arpeggio
        if spec.get("santur", True) and b % 2 == 1:
            for k, step in enumerate([0, 2, 4, 6, 4, 2]):
                nx = ch[(deg + step) % len(ch)]
                put(buf, pluck(f(nx[0], nx[1] + 1), 0.42, 0.35), at + k * spb * 0.5 + (0.25 * spb if k % 2 else 0), 0.30, 0.3 if k % 2 else -0.3)
        # lead melody in A/B sections
        if b >= 4 and b < bars and spec.get("lead", True):
            mel = spec["mel"]
            for (beat, dstep, dl) in mel[b % len(mel)]:
                nx = ch[(deg + dstep) % len(ch)]
                put(buf, lead(f(nx[0], nx[1] + 1), dl * spb), at + beat * spb, 0.62, -0.18)
    fold_loop(buf, 2 * bar)
    # duck pads under kicks (simple sidechain feel)
    mix = buf
    peak = np.max(np.abs(mix)) + 1e-9
    mix = np.tanh(mix / peak * 1.4) * 0.88
    return mix

TRACKS = {
    # menu — calm santur groove
    "moosighi_menu": dict(bpm=94, bars=16, scale=NAHAVAND_G, root_shift=0, drums=True, bass=0.3, padg=1.25, det=0.004,
        mel=[[(0,0,1.6),(1.5,2,1.2),(2.5,1,1.2)], [(0,4,1.6),(1.5,2,1.2),(3,1,0.9)], [(0,0,1.6),(2,4,1.6)], [(0,5,1.4),(2,4,1.4),(3,2,0.9)]]),
    # valiasr — sunset boulevard, warm and rolling
    "moosighi_1": dict(bpm=102, bars=16, scale=HIJAZ_D, root_shift=0,
        mel=[[(0,0,1.4),(1,1,0.8),(2,2,1.6)], [(0,3,1.4),(2,2,1.4)], [(0,4,1.4),(1,3,0.8),(2,2,1.6)], [(0,1,2.6)]]),
    # hemmat — night highway synthwave
    "moosighi_2": dict(bpm=120, bars=16, scale=HIJAZ_D, root_shift=2, bass=0.62, padg=1.1,
        mel=[[(0,7,0.8),(0.5,6,0.8),(1,4,1.6),(2.5,3,1.2)], [(0,2,1.4),(1.5,4,1.4)], [(0,4,0.8),(0.5,6,0.8),(1,7,1.6)], [(0,3,2.4)]]),
    # bazaar — tight alleys, percussive
    "moosighi_3": dict(bpm=112, bars=16, scale=HIJAZ_D, root_shift=-2, bass=0.5, padg=0.8,
        mel=[[(0,0,0.6),(0.5,0,0.6),(1,1,0.9),(2,0,1.4)], [(0,4,0.9),(1,2,0.9),(2,1,1.4)], [(0,0,0.6),(0.5,2,0.6),(1,1,0.9),(2,4,1.4)], [(0,6,0.8),(1,4,0.8),(2,1,1.6)]]),
    # tajrish — mountain sweep, bright
    "moosighi_4": dict(bpm=116, bars=16, scale=NAHAVAND_G, root_shift=1,
        mel=[[(0,0,1.2),(1,2,1.2),(2,4,1.4)], [(0,5,1.2),(1,4,1.2),(2,2,1.4)], [(0,4,1.2),(1,2,1.2),(2,1,1.4)], [(0,2,2.4)]]),
    # azadi — final night, epic
    "moosighi_5": dict(bpm=128, bars=16, scale=HIJAZ_D, root_shift=0, bass=0.66, padg=1.2,
        mel=[[(0,0,0.7),(0.5,1,0.7),(1,2,0.9),(2,4,1.4)], [(0,3,0.9),(1,2,0.9),(2,1,1.4)], [(0,4,0.7),(0.5,2,0.7),(1,1,0.9),(2,0,1.4)], [(0,7,0.9),(1,6,0.9),(2,4,1.6)]]),
}

def main():
    os.makedirs(OUT, exist_ok=True)
    for name, spec in TRACKS.items():
        mix = compose(spec)
        p = os.path.join(OUT, name + ".wav")
        sf.write(p, mix.T.astype(np.float32), SR, subtype="PCM_16")
        d = os.path.getsize(p) / 1e6
        print("saz:", name, round(mix.shape[1] / SR, 1), "s", round(d, 1), "MB")

if __name__ == "__main__":
    main()
