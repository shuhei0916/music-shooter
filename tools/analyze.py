"""曲のファイルを読み、拍の格子（BPMと最初の拍の時刻）を求める"""

import librosa

from beat_fit import find_grid

SAMPLE_RATE = 22050
# オンセットの強さを求める間隔（サンプル数）。128 で約 5.8 ミリ秒ごと
HOP_LENGTH = 128
# 音を調べる窓の長さ（サンプル数）。短いほど音の立ち上がりの時刻がずれにくい
N_FFT = 512


def analyze(path, bpm_range, bpm_step):
    audio, sample_rate = librosa.load(path, sr=SAMPLE_RATE, mono=True)
    envelope = librosa.onset.onset_strength(
        y=audio, sr=sample_rate, n_fft=N_FFT, hop_length=HOP_LENGTH
    )
    frame_rate = sample_rate / HOP_LENGTH
    bpm, offset = find_grid(envelope, frame_rate, bpm_range, bpm_step)
    return {"bpm": bpm, "offset": offset}
