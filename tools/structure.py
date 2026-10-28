"""拍や小節ごとにまとめた音の特徴から、曲の組み立て（小節の頭・セクション）を求める"""

import numpy as np


def find_downbeat(change, beats_per_bar):
    """拍ごとの「前の拍からの音の変わり方」から、小節の頭が何番目の拍かを返す

    和音や音色は小節の頭で変わりやすいので、変わり方の平均が最も大きい拍を小節の頭とする
    """
    change = np.asarray(change)
    scores = [change[phase::beats_per_bar].mean() for phase in range(beats_per_bar)]
    return int(np.argmax(scores))
