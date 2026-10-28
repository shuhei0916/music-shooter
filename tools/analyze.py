"""曲のファイルを読み、拍の格子（BPMと最初の拍の時刻）と、小節の頭・セクションを求める

使い方: python analyze.py 曲のファイル --bpm おおよそのBPM
曲と同じ場所に「曲の名前.beats.json」を書き出す
"""

import argparse
import json
from pathlib import Path

import librosa
import numpy as np

from beat_fit import find_grid
from structure import find_boundaries, find_downbeat, section_energy

SAMPLE_RATE = 22050
# オンセットの強さを求める間隔（サンプル数）。128 で約 5.8 ミリ秒ごと
HOP_LENGTH = 128
# 音を調べる窓の長さ（サンプル数）。短いほど音の立ち上がりの時刻がずれにくい
N_FFT = 512
# --bpm で与えたBPMの前後をどこまで、どの刻みで試すか
BPM_MARGIN = 5.0
BPM_STEP = 0.01
BEATS_PER_BAR = 4
# 和音・音色・大きさを調べる間隔（サンプル数）。拍や小節ごとにまとめるので粗くてよい
FEATURE_HOP = 512
N_MELS = 32
# セクションの切れ目は、前後それぞれ何小節を比べて探すか。また、セクションは最低何小節か
SECTION_WINDOW = 4
SECTION_MIN_LENGTH = 8
# 最後の区間が、区間の長さのこの割合までなら短くても1つと数える
LAST_SEGMENT_SLACK = 0.05


def analyze(path, bpm_range, bpm_step):
    audio, sample_rate = librosa.load(path, sr=SAMPLE_RATE, mono=True)
    envelope = librosa.onset.onset_strength(
        y=audio, sr=sample_rate, n_fft=N_FFT, hop_length=HOP_LENGTH
    )
    frame_rate = sample_rate / HOP_LENGTH
    bpm, offset = find_grid(envelope, frame_rate, bpm_range, bpm_step)

    duration = len(audio) / sample_rate
    feature_rate = sample_rate / FEATURE_HOP
    beat_length = 60.0 / bpm
    chroma = librosa.feature.chroma_stft(y=audio, sr=sample_rate, hop_length=FEATURE_HOP)
    beat_chroma = segment_means(chroma, feature_rate, offset, beat_length, duration)
    change = np.r_[0.0, np.linalg.norm(np.diff(beat_chroma, axis=0), axis=1)]
    downbeat = offset + find_downbeat(change, BEATS_PER_BAR) * beat_length

    bar_length = beat_length * BEATS_PER_BAR
    mel = librosa.feature.melspectrogram(
        y=audio, sr=sample_rate, hop_length=FEATURE_HOP, n_mels=N_MELS
    )
    bar_mel = librosa.power_to_db(segment_means(mel, feature_rate, downbeat, bar_length, duration))
    rms = librosa.feature.rms(y=audio, hop_length=FEATURE_HOP)
    bar_energy = segment_means(rms, feature_rate, downbeat, bar_length, duration)[:, 0]
    starts = find_boundaries(bar_mel, SECTION_WINDOW, SECTION_MIN_LENGTH)
    energies = section_energy(bar_energy, starts)
    return {
        "bpm": bpm,
        "offset": offset,
        "beats_per_bar": BEATS_PER_BAR,
        "downbeat": downbeat,
        "sections": [
            {"bar": bar, "start": downbeat + bar * bar_length, "energy": energy}
            for bar, energy in zip(starts, energies)
        ],
        "bar_energy": list(bar_energy / bar_energy.max()),
    }


def segment_means(feature, feature_rate, start, length, duration):
    """start 秒から length 秒ごとに区切り、曲の終わりまでに収まる区間ごとの特徴の平均を並べる

    最初の拍の時刻はわずかに遅れて出ることがあるので、最後の区間は少し短くても数える
    """
    count = int((duration - start) / length + LAST_SEGMENT_SLACK)
    rows = []
    for i in range(count):
        begin = int(round((start + i * length) * feature_rate))
        end = int(round((start + (i + 1) * length) * feature_rate))
        rows.append(feature[:, begin:end].mean(axis=1))
    return np.array(rows)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("song", type=Path)
    parser.add_argument("--bpm", type=float, required=True, help="おおよそのBPM")
    args = parser.parse_args(argv)
    bpm_range = (args.bpm - BPM_MARGIN, args.bpm + BPM_MARGIN)
    result = analyze(args.song, bpm_range, BPM_STEP)
    beats = {
        "bpm": round(result["bpm"], 2),
        "offset": round(result["offset"], 4),
        "beats_per_bar": result["beats_per_bar"],
        "downbeat": round(result["downbeat"], 4),
        "sections": [
            {"bar": s["bar"], "start": round(s["start"], 4), "energy": round(float(s["energy"]), 2)}
            for s in result["sections"]
        ],
        "bar_energy": [round(float(e), 2) for e in result["bar_energy"]],
    }
    out = args.song.with_name(args.song.stem + ".beats.json")
    out.write_text(json.dumps(beats, indent=2) + "\n", encoding="utf-8")
    print(f"{out}: {json.dumps(beats)}")


if __name__ == "__main__":
    main()
