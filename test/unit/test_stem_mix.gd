extends GutTest
## 曲をパートに分けたファイルがあれば一緒に鳴らす

const STEMS_SONG := "res://test/fixtures/stems_song.mp3"
const PLAIN_SONG := "res://test/fixtures/plain_song.ogg"


func test_曲の隣にパートのフォルダがあれば4つのパートを一緒に鳴らす曲にする():
	var song := StemMix.load_song(STEMS_SONG)
	assert_true(song is AudioStreamSynchronized)
	assert_eq(song.stream_count, StemMix.STEMS.size())


func test_パートのフォルダが無ければ曲のファイルをそのまま使う():
	var song := StemMix.load_song(PLAIN_SONG)
	assert_true(song is AudioStreamOggVorbis)


func test_曲もパートも無ければ曲なし():
	assert_null(StemMix.load_song("res://test/fixtures/no_such_song.mp3"))
