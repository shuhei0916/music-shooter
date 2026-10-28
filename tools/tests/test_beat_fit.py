import numpy as np
import pytest

from beat_fit import find_grid, find_offset

FRAME_RATE = 100.0


def pulses(times, length=10.0):
    """指定した時刻にだけ山があるオンセットの強さの列を作る"""
    envelope = np.zeros(int(length * FRAME_RATE))
    for t in times:
        envelope[round(t * FRAME_RATE)] = 1.0
    return envelope


def test_find_offset_returns_time_of_first_beat():
    beats = np.arange(0.3, 10.0, 0.5)
    assert find_offset(pulses(beats), FRAME_RATE, bpm=120.0) == 0.3


def test_find_offset_with_another_first_beat():
    beats = np.arange(0.12, 10.0, 0.5)
    assert find_offset(pulses(beats), FRAME_RATE, bpm=120.0) == 0.12


def test_find_grid_returns_bpm_and_first_beat():
    beats = np.arange(0.2, 10.0, 0.6)
    bpm, offset = find_grid(pulses(beats), FRAME_RATE, bpm_range=(95.0, 125.0), bpm_step=0.5)
    assert bpm == pytest.approx(100.0)
    assert offset == pytest.approx(0.2)


def test_find_grid_with_another_bpm():
    beats = np.arange(0.05, 10.0, 60.0 / 110.0)
    bpm, offset = find_grid(pulses(beats), FRAME_RATE, bpm_range=(95.0, 125.0), bpm_step=0.5)
    assert bpm == pytest.approx(110.0)
    assert offset == pytest.approx(0.05)
