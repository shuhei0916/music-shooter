import numpy as np

from structure import find_downbeat


def test_find_downbeat_picks_beat_where_sound_changes_most():
    # 4拍ごとに、3つ目の拍（番号2）で音が大きく変わる
    change = np.tile([0.1, 0.2, 1.0, 0.1], 8)
    assert find_downbeat(change, beats_per_bar=4) == 2


def test_find_downbeat_with_three_beats_per_bar():
    change = np.tile([0.0, 1.0, 0.2], 5)
    assert find_downbeat(change, beats_per_bar=3) == 1
