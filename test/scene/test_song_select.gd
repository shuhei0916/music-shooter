extends GutTest
## 曲を選ぶ画面

const SongSelectScene := preload("res://scenes/song_select.tscn")
const SONGS := [
	{"path": "res://music/a.mp3", "title": "Artist - A", "bpm": 125.0},
	{"path": "res://music/b.mp3", "title": "B", "bpm": 174.0},
]


## 選んだ曲でゲームを始めると、テストの画面が置き換わってしまうので、始めずに知らせるだけにする
func _make_select(songs: Array) -> SongSelect:
	var select: SongSelect = SongSelectScene.instantiate()
	select.songs = songs
	select.start_on_choose = false
	return add_child_autofree(select)


func _buttons(select: SongSelect) -> Array:
	return select.get_node("%List").get_children().filter(func(n): return n is Button)


func test_曲ごとに名前とBPMを書いたボタンが並ぶ():
	var select := _make_select(SONGS)
	var texts := _buttons(select).map(func(b): return b.text)
	assert_eq(texts, ["Artist - A   BPM 125", "B   BPM 174"])


func test_ボタンを押すとその曲を選んだと知らせる():
	var select := _make_select(SONGS)
	watch_signals(select)
	_buttons(select)[1].pressed.emit()
	assert_signal_emitted_with_parameters(select, "song_chosen", ["res://music/b.mp3"])


func test_初めは一番上の曲を選んでいる():
	var select := _make_select(SONGS)
	await wait_process_frames(1)
	assert_true(_buttons(select)[0].has_focus())


func test_曲が無ければ曲の置き方を案内する():
	var select := _make_select([])
	assert_eq(_buttons(select).size(), 0)
	assert_true(select.get_node("%Empty").visible)


func test_曲があれば案内は出さない():
	var select := _make_select(SONGS)
	assert_false(select.get_node("%Empty").visible)
