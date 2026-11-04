extends GutTest
## 曲をパートに分けたファイルがあれば一緒に鳴らし、取ったゲートに合わせてパートの音量を変える

const STEMS_SONG := "res://test/fixtures/stems_song.mp3"
const PLAIN_SONG := "res://test/fixtures/plain_song.ogg"


func _mix() -> StemMix:
	return StemMix.new(StemMix.load_song(STEMS_SONG))


func test_曲の隣にパートのフォルダがあれば4つのパートを一緒に鳴らす曲にする():
	var song := StemMix.load_song(STEMS_SONG)
	assert_true(song is AudioStreamSynchronized)
	assert_eq(song.stream_count, StemMix.STEMS.size())


func test_パートのフォルダが無ければ曲のファイルをそのまま使う():
	var song := StemMix.load_song(PLAIN_SONG)
	assert_true(song is AudioStreamOggVorbis)


func test_曲もパートも無ければ曲なし():
	assert_null(StemMix.load_song("res://test/fixtures/no_such_song.mp3"))


func test_ゲートの種類ごとに強くなるパートが決まっている():
	assert_eq(StemMix.part_of(Gate.new(Gate.Op.FIRE_RATE, 1)), "drums")
	assert_eq(StemMix.part_of(Gate.new(Gate.Op.POWER, 1)), "bass")
	assert_eq(StemMix.part_of(Gate.new(Gate.Op.ADD, 10)), "other")
	assert_eq(StemMix.part_of(Gate.new(Gate.Op.MULTIPLY, 2)), "other")


func test_初めはゲートで強くなるパートを小さく鳴らしボーカルはそのまま():
	var mix := _mix()
	assert_eq(mix.volume_db("vocals"), 0.0)
	for part in ["drums", "bass", "other"]:
		assert_eq(mix.volume_db(part), StemMix.START_DB)


func test_ゲートを取るとそのパートが一段大きくなる():
	var mix := _mix()
	mix.take(Gate.new(Gate.Op.FIRE_RATE, 1))
	assert_eq(mix.volume_db("drums"), StemMix.START_DB + StemMix.STEP_DB)
	assert_eq(mix.volume_db("bass"), StemMix.START_DB)


func test_鳴らしている曲の音量も変わる():
	var mix := _mix()
	mix.take(Gate.new(Gate.Op.POWER, 1))
	var song: AudioStreamSynchronized = mix.song
	var bass := StemMix.STEMS.find("bass")
	assert_eq(song.get_sync_stream_volume(bass), StemMix.START_DB + StemMix.STEP_DB)


func test_元の曲の大きさより大きくはならない():
	var mix := _mix()
	for i in 20:
		mix.take(Gate.new(Gate.Op.ADD, 10))
	assert_eq(mix.volume_db("other"), 0.0)


func test_悪いゲートを取るとそのパートが一段小さくなるが初めより小さくはならない():
	var mix := _mix()
	mix.take(Gate.new(Gate.Op.ADD, 10))
	mix.take(Gate.new(Gate.Op.ADD, 10))
	mix.take(Gate.new(Gate.Op.ADD, -5))
	assert_eq(mix.volume_db("other"), StemMix.START_DB + StemMix.STEP_DB)
	for i in 5:
		mix.take(Gate.new(Gate.Op.ADD, -5))
	assert_eq(mix.volume_db("other"), StemMix.START_DB)


func test_パートに分けていない曲ではゲートを取っても何も変わらない():
	var mix := StemMix.new(StemMix.load_song(PLAIN_SONG))
	mix.take(Gate.new(Gate.Op.FIRE_RATE, 1))
	assert_false(mix.has_stems())
	assert_eq(mix.volume_db("drums"), 0.0)
