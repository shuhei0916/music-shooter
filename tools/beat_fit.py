"""オンセットの強さの列から、拍の格子（BPMと最初の拍の時刻）を求める"""

import numpy as np


def grid_score(envelope, frame_rate, bpm, offset):
    """offset から 60/bpm 秒ごとに置いた拍の位置での、オンセットの強さの平均"""
    times = np.arange(offset, len(envelope) / frame_rate, 60.0 / bpm)
    frames = np.round(times * frame_rate).astype(int)
    frames = frames[frames < len(envelope)]
    return envelope[frames].mean()


def find_offset(envelope, frame_rate, bpm):
    """1拍の長さの中で、拍の格子が最もよく合う最初の拍の時刻（フレーム単位で探す）"""
    candidates = range(int(60.0 / bpm * frame_rate))
    best = max(candidates, key=lambda f: grid_score(envelope, frame_rate, bpm, f / frame_rate))
    return best / frame_rate
