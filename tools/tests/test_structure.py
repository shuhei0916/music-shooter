import numpy as np
import pytest

from structure import find_boundaries, find_downbeat, label_sections, novelty, section_energy


def test_find_downbeat_picks_beat_where_sound_changes_most():
    # 4拍ごとに、3つ目の拍（番号2）で音が大きく変わる
    change = np.tile([0.1, 0.2, 1.0, 0.1], 8)
    assert find_downbeat(change, beats_per_bar=4) == 2


def test_find_downbeat_with_three_beats_per_bar():
    change = np.tile([0.0, 1.0, 0.2], 5)
    assert find_downbeat(change, beats_per_bar=3) == 1


def bars(*parts):
    """(特徴の番号, 小節の数) の順に、同じ番号なら同じ特徴の小節を並べる（少しだけ揺らす）"""
    rng = np.random.default_rng(0)
    rows = []
    for kind, count in parts:
        base = np.zeros(6)
        base[kind] = 1.0
        rows += [base + rng.normal(0, 0.05, 6) for _ in range(count)]
    return np.array(rows)


def test_find_boundaries_starts_section_where_bars_change():
    features = bars((0, 8), (1, 8), (2, 16), (0, 8))
    assert find_boundaries(features, window=4, min_length=4) == [0, 8, 16, 32]


def test_find_boundaries_keeps_only_one_of_changes_closer_than_min_length():
    # 2小節だけ違う部分があっても、その前後の両方をセクションの切れ目にはしない
    features = bars((0, 8), (1, 2), (0, 8))
    assert len(find_boundaries(features, window=4, min_length=4)) == 2


def test_find_boundaries_ignores_small_changes():
    features = bars((0, 8), (1, 8))
    features[12:] += 0.1  # 後ろの4小節が少しだけ変わる
    assert find_boundaries(features, window=4, min_length=4) == [0, 8]


def test_section_energy_is_mean_of_bars_relative_to_loudest_section():
    bar_energy = [1.0, 1.0, 4.0, 2.0, 2.0]
    assert section_energy(bar_energy, [0, 2, 3]) == pytest.approx([0.25, 1.0, 0.5])


def test_novelty_is_measured_only_where_both_windows_are_full():
    # 1小節ごとに交互に変わる。前後2小節ずつの平均は同じなので変化なし。
    # 曲の端で窓が欠けると平均がかたよるので、そこは測らない（0 とする）
    features = np.array([[1.0, 0.0], [0.0, 1.0]] * 4)
    assert novelty(features, window=2) == pytest.approx([0.0] * 8)


def test_label_sections_by_energy():
    # 大きいものは DROP、小さいものは BREAK、その間は VERSE。DROP の直前は BUILD
    energies = [0.7, 0.4, 0.8, 0.6, 0.95, 0.5, 1.0]
    assert label_sections(energies) == ["VERSE", "BREAK", "VERSE", "BUILD", "DROP", "BUILD", "DROP"]


def test_label_sections_keeps_drop_before_drop():
    assert label_sections([0.9, 1.0]) == ["DROP", "DROP"]
