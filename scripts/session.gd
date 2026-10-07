## シーンをまたいで受け渡す、今回のプレイの情報。オートロード（Session）として使う
extends Node

## 曲選択画面で選ばれた曲（空ならmainのシーンに設定された曲）
var song_path := ""
## タイミング調整画面を閉じたときに戻るシーン（開いた画面が設定する。空ならゲームに戻る）
var calibration_return_scene := ""
