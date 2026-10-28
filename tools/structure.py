"""拍や小節ごとにまとめた音の特徴から、曲の組み立て（小節の頭・セクション）を求める"""

import numpy as np


def find_downbeat(change, beats_per_bar):
    """拍ごとの「前の拍からの音の変わり方」から、小節の頭が何番目の拍かを返す

    和音や音色は小節の頭で変わりやすいので、変わり方の平均が最も大きい拍を小節の頭とする
    """
    change = np.asarray(change)
    scores = [change[phase::beats_per_bar].mean() for phase in range(beats_per_bar)]
    return int(np.argmax(scores))


def novelty(features, window):
    """小節ごとに、その前の window 小節と後ろの window 小節の特徴（平均）がどれだけ違うか"""
    features = np.asarray(features, dtype=float)
    result = np.zeros(len(features))
    for i in range(1, len(features)):
        before = features[max(0, i - window) : i].mean(axis=0)
        after = features[i : i + window].mean(axis=0)
        result[i] = np.linalg.norm(after - before)
    return result


def find_boundaries(features, window, min_length, threshold=0.3):
    """小節ごとの特徴から、セクションが始まる小節の番号を返す（最初は必ず 0）

    前後で特徴が大きく変わる小節を切れ目とする。変わり方が最も大きいものの threshold 倍より
    小さい変化は無視し、min_length 小節より近い切れ目は、変わり方が大きい方だけを残す
    """
    score = novelty(features, window)
    count = len(score)
    peaks = [
        i
        for i in range(1, count)
        if score[i] >= score[i - 1]
        and (i + 1 == count or score[i] >= score[i + 1])
        and score[i] >= threshold * score.max()
    ]
    starts = [0]
    for i in sorted(peaks, key=lambda i: score[i], reverse=True):
        if count - i >= min_length and all(abs(i - s) >= min_length for s in starts):
            starts.append(i)
    return sorted(starts)


def section_energy(bar_energy, starts):
    """セクションごとの小節の大きさの平均を、最も大きいセクションを 1 として返す"""
    bar_energy = np.asarray(bar_energy, dtype=float)
    ends = list(starts[1:]) + [len(bar_energy)]
    means = np.array([bar_energy[s:e].mean() for s, e in zip(starts, ends)])
    return list(means / means.max())
