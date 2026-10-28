import numpy as np
import pytest
import soundfile

from analyze import analyze

SAMPLE_RATE = 22050


def write_clicks(path, bpm, offset, length=12.0):
    """offset から拍ごとに短いクリック音が鳴る wav を書き出す"""
    audio = np.zeros(int(length * SAMPLE_RATE), dtype=np.float32)
    click = np.sin(2 * np.pi * 1000 * np.arange(400) / SAMPLE_RATE) * np.linspace(1, 0, 400)
    for t in np.arange(offset, length - 0.1, 60.0 / bpm):
        start = int(round(t * SAMPLE_RATE))
        audio[start : start + len(click)] += click
    soundfile.write(path, audio, SAMPLE_RATE)


# 最初の拍の時刻は、オンセットの強さの1フレーム（約5.8ミリ秒）ほど遅れて出ることがあるので、8ミリ秒まで許す
@pytest.mark.parametrize("bpm, offset", [(120.0, 0.25), (97.0, 0.1)])
def test_analyze_finds_bpm_and_first_beat_of_click_track(tmp_path, bpm, offset):
    path = tmp_path / "clicks.wav"
    write_clicks(path, bpm=bpm, offset=offset)
    result = analyze(path, bpm_range=(90.0, 140.0), bpm_step=0.5)
    assert result["bpm"] == pytest.approx(bpm)
    assert result["offset"] == pytest.approx(offset, abs=0.008)
