import json

import numpy as np
import pytest

from parts import FRAME_RATE, PARTS, analyze_parts, main
from separate import STEMS, write_ogg

SAMPLE_RATE = 44100
LENGTH = 3.0


def tone(freq, start, end, amplitude=0.5):
    """start から end 秒まで鳴る、正弦波の音（ステレオ）"""
    audio = np.zeros(int(LENGTH * SAMPLE_RATE), dtype=np.float32)
    begin, stop = int(start * SAMPLE_RATE), int(end * SAMPLE_RATE)
    t = np.arange(stop - begin) / SAMPLE_RATE
    audio[begin:stop] = amplitude * np.sin(2 * np.pi * freq * t)
    return np.stack([audio, audio])


def hiss(start, end, amplitude=0.5):
    """start から end 秒まで鳴る、ハイハットのような高い雑音（ステレオ）"""
    audio = np.zeros(int(LENGTH * SAMPLE_RATE), dtype=np.float32)
    begin, stop = int(start * SAMPLE_RATE), int(end * SAMPLE_RATE)
    noise = np.random.default_rng(0).uniform(-1, 1, stop - begin)
    audio[begin:stop] = amplitude * np.diff(noise, prepend=0) / 2
    return np.stack([audio, audio])


def write_stems(tmp_path, **stems):
    """曲の隣に「曲の名前.stems/」を作る。渡さなかったパートは無音"""
    folder = tmp_path / "song.stems"
    folder.mkdir()
    silence = np.zeros((2, int(LENGTH * SAMPLE_RATE)), dtype=np.float32)
    for name in STEMS:
        write_ogg(folder / f"{name}.ogg", stems.get(name, silence), SAMPLE_RATE)
    return tmp_path / "song.mp3"


def test_drum_hits_are_split_into_kick_and_hihat_by_pitch(tmp_path):
    drums = tone(60, 1.0, 1.15, amplitude=0.8) + hiss(2.0, 2.05)
    result = analyze_parts(write_stems(tmp_path, drums=drums))
    assert result["kick"]["onsets"] == [pytest.approx(1.0, abs=0.03)]
    assert result["hihat"]["onsets"] == [pytest.approx(2.0, abs=0.03)]


def test_level_follows_how_loud_the_part_is(tmp_path):
    result = analyze_parts(write_stems(tmp_path, vocals=tone(440, 0.5, 1.5)))
    level = result["vocals"]["level"]
    assert level[int(1.0 * FRAME_RATE)] > 0.8
    assert level[int(2.5 * FRAME_RATE)] == 0.0


def test_silent_part_has_no_onsets_and_zero_level(tmp_path):
    result = analyze_parts(write_stems(tmp_path, vocals=tone(440, 0.5, 1.5)))
    assert result["bass"]["onsets"] == []
    assert max(result["bass"]["level"]) == 0.0


def test_main_writes_parts_json_next_to_song(tmp_path):
    song = write_stems(tmp_path, bass=tone(55, 1.0, 2.0))
    main([str(song)])
    data = json.loads((tmp_path / "song.parts.json").read_text(encoding="utf-8"))
    assert data["frame_rate"] == FRAME_RATE
    assert list(data["parts"]) == [name for name, _, _ in PARTS]
    assert data["parts"]["bass"]["onsets"] == [pytest.approx(1.0, abs=0.03)]
