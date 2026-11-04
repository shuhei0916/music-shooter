class_name PartTrack
extends RefCounted
## 曲のパートの項目（ボーカル・キックなど）ごとの、鳴っている大きさと鳴った瞬間
## tools/parts.py で作る「曲の名前.parts.json」から読む

var _frame_rate := 1.0
## 項目の名前 → {"level": [0〜1, ...], "onsets": [秒, ...]}
var _parts := {}


## JSON の文字から作る。読めなければ項目なし
static func from_json(text: String) -> PartTrack:
	var track := PartTrack.new()
	var data = JSON.parse_string(text) if not text.is_empty() else null
	if data is Dictionary and data.get("parts") is Dictionary:
		track._frame_rate = float(data.get("frame_rate", 1.0))
		track._parts = data.parts
	return track


## 項目の名前（JSON の順）
func names() -> Array:
	return _parts.keys()


## time 秒の大きさ（0〜1）。記録のあいだはつなぎ、記録の外は 0
func level(part: String, time: float) -> float:
	var levels: Array = _parts.get(part, {}).get("level", [])
	var at := time * _frame_rate
	var i := floori(at)
	if i < 0 or i >= levels.size():
		return 0.0
	var next: float = levels[i + 1] if i + 1 < levels.size() else 0.0
	return lerpf(levels[i], next, at - i)


## time 秒より前（time を含む）で最後に鳴ってからの秒数。まだ鳴っていなければ INF
func since_onset(part: String, time: float) -> float:
	var times: Array = _parts.get(part, {}).get("onsets", [])
	var i := times.bsearch(time, false) - 1
	if i < 0:
		return INF
	return time - times[i]
