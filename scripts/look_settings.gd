class_name LookSettings
extends RefCounted
## 見た目の設定をファイルに保存して、次に起動したときも同じ見た目にする

const PATH := "user://look.cfg"
const SECTION := "look"
const KEY := "fancy"


## path に保存した設定で派手な表示にするか。保存がないときや読めないときは派手な表示にする
static func load_fancy(path: String) -> bool:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return true
	return config.get_value(SECTION, KEY, true)


static func save_fancy(path: String, fancy: bool) -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, KEY, fancy)
	config.save(path)
