import json

import numpy as np
import pytest
import soundfile

from analyze import analyze, main

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


def test_main_writes_beats_json_next_to_song(tmp_path):
    path = tmp_path / "clicks.wav"
    write_clicks(path, bpm=120.0, offset=0.25)
    main([str(path), "--bpm", "120"])
    # 12秒の音では、0.01 刻みの BPM の違いは1ミリ秒ほどのずれにしかならず、見分けられない
    beats = json.loads((tmp_path / "clicks.beats.json").read_text(encoding="utf-8"))
    assert beats["bpm"] == pytest.approx(120.0, abs=0.05)
    assert beats["offset"] == pytest.approx(0.25, abs=0.008)


def write_song(path, bpm, offset, first_bar_beat, quiet_bars, loud_bars):
    """拍ごとのクリックに、小節の頭で変わる和音を重ねた wav を書き出す

    最初の小節の頭は first_bar_beat 番目の拍。初めの quiet_bars 小節は小さく、
    続く loud_bars 小節は大きく、別の和音で鳴らす。和音は2小節ごとに入れ替わる
    """
    beat = 60.0 / bpm
    bar = beat * 4
    downbeat = offset + first_bar_beat * beat
    length = downbeat + (quiet_bars + loud_bars) * bar
    write_clicks(path, bpm, offset, length=length)
    audio, _ = soundfile.read(path, dtype="float32")
    chords = {False: [[220.0, 277.2], [196.0, 246.9]], True: [[329.6, 415.3], [293.7, 370.0]]}
    for i in range(-1, quiet_bars + loud_bars):
        loud = i >= quiet_bars
        start = int(max(0.0, downbeat + i * bar) * SAMPLE_RATE)
        end = min(int((downbeat + (i + 1) * bar) * SAMPLE_RATE), len(audio))
        t = np.arange(start, end) / SAMPLE_RATE
        tone = sum(np.sin(2 * np.pi * f * t) for f in chords[loud][(i // 2) % 2])
        audio[start:end] += tone * (0.4 if loud else 0.08)
    soundfile.write(path, audio, SAMPLE_RATE)


def test_analyze_finds_first_downbeat_and_sections(tmp_path):
    path = tmp_path / "song.wav"
    write_song(path, bpm=120.0, offset=0.25, first_bar_beat=1, quiet_bars=8, loud_bars=8)
    result = analyze(path, bpm_range=(115.0, 125.0), bpm_step=0.5)
    assert result["beats_per_bar"] == 4
    assert result["downbeat"] == pytest.approx(0.75, abs=0.008)
    sections = result["sections"]
    assert [s["bar"] for s in sections] == [0, 8]
    assert sections[1]["start"] == pytest.approx(0.75 + 8 * 2.0, abs=0.008)
    assert sections[0]["energy"] < 0.5
    assert sections[1]["energy"] == pytest.approx(1.0)
    assert len(result["bar_energy"]) == 16


def test_main_writes_downbeat_and_sections_too(tmp_path):
    path = tmp_path / "song.wav"
    write_song(path, bpm=120.0, offset=0.25, first_bar_beat=1, quiet_bars=8, loud_bars=8)
    main([str(path), "--bpm", "120"])
    beats = json.loads((tmp_path / "song.beats.json").read_text(encoding="utf-8"))
    assert beats["beats_per_bar"] == 4
    assert beats["downbeat"] == pytest.approx(0.75, abs=0.008)
    assert [s["bar"] for s in beats["sections"]] == [0, 8]
    assert beats["sections"][1]["energy"] == 1.0
    assert len(beats["bar_energy"]) == 16


def test_main_writes_section_labels(tmp_path):
    path = tmp_path / "song.wav"
    write_song(path, bpm=120.0, offset=0.25, first_bar_beat=1, quiet_bars=8, loud_bars=8)
    main([str(path), "--bpm", "120"])
    beats = json.loads((tmp_path / "song.beats.json").read_text(encoding="utf-8"))
    assert [s["label"] for s in beats["sections"]] == ["BUILD", "DROP"]
