import numpy as np
import pytest
import soundfile

from separate import SAMPLE_RATE, STEMS, main, write_ogg


def write_click(path, at, length=3.0, channels=2):
    """at 秒に短いクリックが1つだけ鳴る wav を書き出す"""
    audio = np.zeros((int(length * SAMPLE_RATE), channels), dtype=np.float32)
    start = int(at * SAMPLE_RATE)
    audio[start : start + 200] = 0.8
    soundfile.write(path, audio, SAMPLE_RATE)


def drums_only(audio, sample_rate):
    """受け取った音をすべてドラムとして返す、分ける処理の代わり"""
    return {name: audio if name == "drums" else np.zeros_like(audio) for name in STEMS}


def test_main_writes_each_stem_as_ogg_into_stems_folder_next_to_song(tmp_path):
    song = tmp_path / "song.wav"
    write_click(song, at=1.0)
    main([str(song)], separator=drums_only)
    folder = tmp_path / "song.stems"
    assert sorted(p.name for p in folder.iterdir()) == sorted(f"{n}.ogg" for n in STEMS)


def test_stems_keep_the_same_timeline_as_the_song(tmp_path):
    song = tmp_path / "song.wav"
    write_click(song, at=1.0)
    main([str(song)], separator=drums_only)
    drums, sample_rate = soundfile.read(tmp_path / "song.stems" / "drums.ogg")
    assert sample_rate == SAMPLE_RATE
    assert len(drums) == 3 * SAMPLE_RATE
    peak = np.argmax(np.abs(drums[:, 0])) / SAMPLE_RATE
    assert peak == pytest.approx(1.0, abs=0.006)


def test_mono_song_is_given_to_separator_as_stereo(tmp_path):
    song = tmp_path / "mono.wav"
    write_click(song, at=1.0, channels=1)
    received = []

    def spy(audio, sample_rate):
        received.append(audio.shape)
        return drums_only(audio, sample_rate)

    main([str(song)], separator=spy)
    assert received == [(2, 3 * SAMPLE_RATE)]


def test_write_ogg_keeps_length_of_long_audio(tmp_path):
    audio = np.random.default_rng(0).uniform(-0.5, 0.5, (2, 90 * SAMPLE_RATE)).astype(np.float32)
    path = tmp_path / "long.ogg"
    write_ogg(path, audio, SAMPLE_RATE)
    assert soundfile.info(path).frames == 90 * SAMPLE_RATE
