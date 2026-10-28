"""曲のファイルを読み、拍の格子（BPMと最初の拍の時刻）を求める

使い方: python analyze.py 曲のファイル --bpm おおよそのBPM
曲と同じ場所に「曲の名前.beats.json」を書き出す
"""

import argparse
import json
from pathlib import Path

import librosa

from beat_fit import find_grid

SAMPLE_RATE = 22050
# オンセットの強さを求める間隔（サンプル数）。128 で約 5.8 ミリ秒ごと
HOP_LENGTH = 128
# 音を調べる窓の長さ（サンプル数）。短いほど音の立ち上がりの時刻がずれにくい
N_FFT = 512
# --bpm で与えたBPMの前後をどこまで、どの刻みで試すか
BPM_MARGIN = 5.0
BPM_STEP = 0.01


def analyze(path, bpm_range, bpm_step):
    audio, sample_rate = librosa.load(path, sr=SAMPLE_RATE, mono=True)
    envelope = librosa.onset.onset_strength(
        y=audio, sr=sample_rate, n_fft=N_FFT, hop_length=HOP_LENGTH
    )
    frame_rate = sample_rate / HOP_LENGTH
    bpm, offset = find_grid(envelope, frame_rate, bpm_range, bpm_step)
    return {"bpm": bpm, "offset": offset}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("song", type=Path)
    parser.add_argument("--bpm", type=float, required=True, help="おおよそのBPM")
    args = parser.parse_args(argv)
    bpm_range = (args.bpm - BPM_MARGIN, args.bpm + BPM_MARGIN)
    result = analyze(args.song, bpm_range, BPM_STEP)
    beats = {"bpm": round(result["bpm"], 2), "offset": round(result["offset"], 4)}
    out = args.song.with_name(args.song.stem + ".beats.json")
    out.write_text(json.dumps(beats, indent=2) + "\n", encoding="utf-8")
    print(f"{out}: {beats}")


if __name__ == "__main__":
    main()
