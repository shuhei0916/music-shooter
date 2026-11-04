"""曲をパート（ボーカル・ドラム・ベース・その他）に分け、曲の隣の「曲の名前.stems/」に ogg で書き出す

使い方: python separate.py 曲.mp3

分けるのは demucs（htdemucs）。モデルは初めて使うときに自動で落ちてくる。
曲は librosa で読んでから demucs に渡す。analyze.py の拍と同じ時間の並びにするため
（demucs に mp3 を直接読ませると、mp3 の頭の詰め物の分だけ 12 ミリ秒ほど遅れる）
"""

import argparse
from pathlib import Path

import librosa
import numpy as np
import soundfile

SAMPLE_RATE = 44100
STEMS = ["vocals", "drums", "bass", "other"]
STEMS_SUFFIX = ".stems"
# ogg を一度に長く書くと libsndfile が落ちることがあるので、1秒ずつ書く
WRITE_BLOCK = SAMPLE_RATE


def separate_song(path, separator):
    """曲を分け、パートごとの ogg を書き出したフォルダを返す"""
    audio, _ = librosa.load(path, sr=SAMPLE_RATE, mono=False)
    if audio.ndim == 1:
        audio = np.stack([audio, audio])
    stems = separator(audio, SAMPLE_RATE)
    folder = path.with_name(path.stem + STEMS_SUFFIX)
    folder.mkdir(exist_ok=True)
    for name in STEMS:
        write_ogg(folder / f"{name}.ogg", stems[name], SAMPLE_RATE)
    return folder


def write_ogg(path, audio, sample_rate):
    """(チャンネル, サンプル) の音を ogg vorbis で書き出す"""
    frames = np.clip(audio.T, -1.0, 1.0)
    with soundfile.SoundFile(
        path, "w", sample_rate, frames.shape[1], format="OGG", subtype="VORBIS"
    ) as file:
        for start in range(0, len(frames), WRITE_BLOCK):
            file.write(frames[start : start + WRITE_BLOCK])


def demucs_separator(audio, sample_rate):
    """demucs の htdemucs で (2, サンプル) の音をパートに分ける"""
    import torch
    from demucs.apply import apply_model
    from demucs.pretrained import get_model

    model = get_model("htdemucs")
    assert model.samplerate == sample_rate
    device = "cuda" if torch.cuda.is_available() else "cpu"
    mix = torch.from_numpy(np.ascontiguousarray(audio, dtype=np.float32))
    # demucs の決まりどおり、曲全体の平均と広がりで正規化して渡し、戻す
    reference = mix.mean(0)
    mean, std = reference.mean(), reference.std()
    sources = apply_model(model, ((mix - mean) / std)[None], device=device, progress=True)[0]
    sources = sources * std + mean
    return {name: sources[model.sources.index(name)].numpy() for name in STEMS}


def main(argv=None, separator=demucs_separator):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("song", type=Path)
    args = parser.parse_args(argv)
    print(separate_song(args.song, separator))


if __name__ == "__main__":
    main()
