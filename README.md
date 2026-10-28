# music-shooter

ゲートを選びながら進むランナー型シューターを作り、そこに音楽の要素を足していくプロジェクト（Godot 4.7）。

以前のMIDIシューター（ゲート・インフレ・MIDIの楽器推定まで）は、タグ `archive/midi-shooter-v1` に残してある。

## テスト

```
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```
