extends GutTest
## 曲のパートの項目ごとの、鳴っている大きさと鳴った瞬間（tools/parts.py で作る「曲の名前.parts.json」）

const JSON_TEXT := (
	'{"frame_rate": 10, "parts": {'
	+ '"vocals": {"level": [0.0, 0.5, 1.0], "onsets": [0.1]},'
	+ '"kick": {"level": [0.0, 0.0, 0.0], "onsets": [0.05, 0.25, 0.5]}}}'
)


func test_項目の名前をJSONの順に返す():
	assert_eq(PartTrack.from_json(JSON_TEXT).names(), ["vocals", "kick"])


func test_大きさは記録のあいだをつないで求める():
	var track := PartTrack.from_json(JSON_TEXT)
	assert_almost_eq(track.level("vocals", 0.1), 0.5, 0.001)
	assert_almost_eq(track.level("vocals", 0.15), 0.75, 0.001)


func test_記録の外の大きさは0():
	var track := PartTrack.from_json(JSON_TEXT)
	assert_eq(track.level("vocals", 5.0), 0.0)
	assert_eq(track.level("vocals", -1.0), 0.0)


func test_最後に鳴ってからの時間():
	var track := PartTrack.from_json(JSON_TEXT)
	assert_almost_eq(track.since_onset("kick", 0.3), 0.05, 0.001)
	assert_almost_eq(track.since_onset("kick", 0.25), 0.0, 0.001)


func test_まだ鳴っていなければ限りなく長い():
	var track := PartTrack.from_json(JSON_TEXT)
	assert_eq(track.since_onset("kick", 0.0), INF)


func test_読めなければ項目なし():
	var track := PartTrack.from_json("")
	assert_eq(track.names(), [])
	assert_eq(track.level("kick", 1.0), 0.0)
	assert_eq(track.since_onset("kick", 1.0), INF)
