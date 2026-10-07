## プレイヤー環境ごとの設定。オートロード（Settings）として使う
extends Node

var path := "user://settings.cfg"
## 映像（発射）を音より何秒先行させるか。タイミング調整画面で設定する
var visual_offset_sec := 0.04


func save_to_file() -> void:
	var config := ConfigFile.new()
	config.set_value("timing", "visual_offset_sec", visual_offset_sec)
	config.save(path)


func load_from_file() -> void:
	var config := ConfigFile.new()
	config.load(path)
	visual_offset_sec = config.get_value("timing", "visual_offset_sec", visual_offset_sec)
