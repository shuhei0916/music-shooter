import numpy as np

from beat_fit import find_offset

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
