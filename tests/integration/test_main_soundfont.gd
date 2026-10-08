extends GutTest
## メインシーンのサウンドフォント読み込み（実際のサウンドフォントを使うため、1テスト約2.3秒かかる）

const MainScene = preload("res://scenes/main/main.tscn")


## 実際のサウンドフォントを読み込むシーン（約2.3秒かかる。同じ音色構成なら2回目からはキャッシュが使われる）
func _main_with_soundfont() -> Node:
	var scene = MainScene.instantiate()
	add_child_autofree(scene)
	return scene


func test_カウントダウン中に曲のサウンドフォントが読み込まれている():
	var scene = _main_with_soundfont()
	assert_not_null(scene.midi_player.bank)


func test_カウントダウン終了時はカウントダウン中に読み込んだサウンドフォントを使う():
	var scene = _main_with_soundfont()
	var preloaded_bank = scene.midi_player.bank
	scene._on_start_timer_timeout()
	assert_same(preloaded_bank, scene.midi_player.bank)


func test_Sessionで選ばれた曲もカウントダウン中に読み込んだサウンドフォントを使う():
	var saved_song: String = Session.song_path
	Session.song_path = "res://assets/audio/Jump!.mid"
	var scene = _main_with_soundfont()
	var preloaded_bank = scene.midi_player.bank
	scene._on_start_timer_timeout()
	Session.song_path = saved_song
	assert_same(preloaded_bank, scene.midi_player.bank)
