"""曲のパート（separate.py で作る「曲の名前.stems/」）から、項目ごとの鳴った瞬間と鳴っている大きさを求め、
曲の隣の「曲の名前.parts.json」に書き出す

使い方: python parts.py 曲.mp3

項目はボーカル・キック・スネア・ハイハット・ベース・その他。ドラムは音の高さで3つに分ける
（低い音をキック、中くらいをスネア、高い音をハイハットとみなす。ほかの太鼓の音も混ざる）
"""

import argparse
import json
from pathlib import Path

import librosa
import numpy as np
import scipy.signal

from separate import STEMS_SUFFIX

SAMPLE_RATE = 22050
# 大きさを何分の1秒ごとに記録するか
FRAME_RATE = 25
FRAME_HOP = SAMPLE_RATE // FRAME_RATE
# 鳴った瞬間を探すときの細かさ（約 12 ミリ秒）
ONSET_HOP = 256
# 大きさの目盛り。これより小さい音は 0、これより大きい音は 1（dB、音の波の大きさの2乗平均から）
FLOOR_DB = -50.0
TOP_DB = -10.0
# 鳴った瞬間でも、大きさがこれに満たないものは、ほかのパートから漏れた小さな音として捨てる
ONSET_MIN_LEVEL = 0.2
# 鳴った瞬間の前後で大きさを比べる間（ONSET_HOP の数。約 23 ミリ秒）
ONSET_RISE_FRAMES = 2
# [項目, パートのファイル, 音の高さの範囲（Hz。None は限らない）]
PARTS = [
    ("vocals", "vocals", None),
    ("kick", "drums", (30, 150)),
    ("snare", "drums", (180, 2500)),
    ("hihat", "drums", (6000, None)),
    ("bass", "bass", None),
    ("other", "other", None),
]


def analyze_parts(song):
    """曲のパートから、項目ごとの {"level": [...], "onsets": [...]} を求める"""
    folder = song.with_name(song.stem + STEMS_SUFFIX)
    stems = {}
    result = {}
    for name, stem, band in PARTS:
        if stem not in stems:
            stems[stem], _ = librosa.load(folder / f"{stem}.ogg", sr=SAMPLE_RATE, mono=True)
        audio = band_pass(stems[stem], band)
        level = loudness(audio)
        result[name] = {"level": level.tolist(), "onsets": onsets(audio, level)}
    return result


def band_pass(audio, band):
    """音の高さを band の範囲に絞る"""
    if band is None:
        return audio
    low, high = band
    if high is None:
        sos = scipy.signal.butter(4, low, "highpass", fs=SAMPLE_RATE, output="sos")
    else:
        sos = scipy.signal.butter(4, [low, high], "bandpass", fs=SAMPLE_RATE, output="sos")
    return scipy.signal.sosfiltfilt(sos, audio).astype(np.float32)


def loudness(audio):
    """1/FRAME_RATE 秒ごとの大きさを 0〜1 で求める"""
    rms = librosa.feature.rms(y=audio, frame_length=FRAME_HOP * 2, hop_length=FRAME_HOP)[0]
    db = 20 * np.log10(np.maximum(rms, 1e-10))
    return np.round(np.clip((db - FLOOR_DB) / (TOP_DB - FLOOR_DB), 0.0, 1.0), 2)


def onsets(audio, level):
    """鳴った瞬間の時刻（秒）。小さすぎる音と、音が途切れた瞬間（直後が直前より小さい）は除く"""
    frames = librosa.onset.onset_detect(y=audio, sr=SAMPLE_RATE, hop_length=ONSET_HOP)
    short = librosa.feature.rms(y=audio, frame_length=ONSET_HOP * 2, hop_length=ONSET_HOP)[0]
    kept = []
    for f in frames:
        t = f * ONSET_HOP / SAMPLE_RATE
        frame = min(int(round(t * FRAME_RATE)), len(level) - 1)
        before = short[max(f - ONSET_RISE_FRAMES, 0)]
        after = short[min(f + ONSET_RISE_FRAMES, len(short) - 1)]
        if level[frame] >= ONSET_MIN_LEVEL and after > before:
            kept.append(round(float(t), 3))
    return kept


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("song", type=Path)
    args = parser.parse_args(argv)
    data = {"frame_rate": FRAME_RATE, "parts": analyze_parts(args.song)}
    out = args.song.with_name(args.song.stem + ".parts.json")
    out.write_text(json.dumps(data, separators=(",", ":")) + "\n", encoding="utf-8")
    counts = {name: len(part["onsets"]) for name, part in data["parts"].items()}
    print(f"{out}: {counts}")


if __name__ == "__main__":
    main()
