class_name MusicVisual
extends RefCounted
## 音の解析（PartTrack）と曲の組み立て（SongMap）から、背景の演出に使う値を求める
## どの曲でも自動で動くよう、値はすべて解析の結果から決める

## キックがまだ鳴っていないときの、鳴ってからの秒数（シェーダーに INF を渡さないため）
const NEVER_AGE := 1000.0
## 音が鳴ったあと、光が消えるまでの秒数
const KICK_FADE := 0.2
const SNARE_FADE := 0.25
const HIHAT_FADE := 0.12
## BUILD の終わりに粒が集まる広がり（1 がふだん）。背景の粒が道の上に来ないよう、小さくしすぎない
const GATHERED_SPREAD := 0.7
## DROP の頭で粒が弾ける広がりの増え方と、落ち着くまでの拍数
const BURST_SPREAD := 0.5
const BURST_BEATS := 4.0
## セクションが分からない曲の盛り上がり
const UNKNOWN_ENERGY := 0.5
## セクションごとの粒の色 [主な色, 混ぜる色]。色数を絞ると、光が美しく見える
const PALETTES := {
	"VERSE": [Color(0.1, 0.75, 1.0), Color(0.25, 0.4, 1.0)],
	"BREAK": [Color(0.3, 0.25, 0.95), Color(0.1, 0.5, 0.85)],
	"BUILD": [Color(0.7, 0.25, 1.0), Color(1.0, 0.3, 0.7)],
	"DROP": [Color(1.0, 0.55, 0.2), Color(1.0, 0.2, 0.5)],
}

var _track: PartTrack
var _map: SongMap


func _init(track: PartTrack, map: SongMap) -> void:
	_track = track
	_map = map


## time 秒の演出の値。pos はその時刻の SongMap.at の結果
## kick_age: キックからの秒数、kick・snare・hihat: 鳴った瞬間が 1 で消えていく光、bass: 鳴っている大きさ
## energy: 盛り上がり、spread: 粒の広がり、burst: DROP の頭で弾ける強さ、color_a・color_b: 粒の色
func at(time: float, pos: Dictionary) -> Dictionary:
	var kick_age := _track.since_onset("kick", time)
	var burst := _burst(pos)
	var palette: Array = PALETTES.get(pos.label, PALETTES["VERSE"])
	return {
		"kick_age": minf(kick_age, NEVER_AGE),
		"kick": _fade(kick_age, KICK_FADE),
		"snare": _fade(_track.since_onset("snare", time), SNARE_FADE),
		"hihat": _fade(_track.since_onset("hihat", time), HIHAT_FADE),
		"bass": _track.level("bass", time),
		"energy": pos.energy if pos.section_count > 0 else UNKNOWN_ENERGY,
		"spread": _gathered(pos) + BURST_SPREAD * burst,
		"burst": burst,
		"color_a": palette[0],
		"color_b": palette[1],
	}


## 鳴ってから age 秒たった光の強さ。初めは速く、終わりはゆっくり消える
static func _fade(age: float, duration: float) -> float:
	var rest := clampf(1.0 - age / duration, 0.0, 1.0)
	return rest * rest


## BUILD のあいだ、終わりに向けて粒が集まる。それ以外は 1
func _gathered(pos: Dictionary) -> float:
	if pos.label != "BUILD" or pos.bars_in_section <= 0:
		return 1.0
	var progress: float = _beats_in_section(pos) / (pos.bars_in_section * _map.beats_per_bar)
	return lerpf(1.0, GATHERED_SPREAD, clampf(progress, 0.0, 1.0))


## DROP の頭で 1 になり、BURST_BEATS 拍かけて 0 に戻る
func _burst(pos: Dictionary) -> float:
	if pos.label != "DROP":
		return 0.0
	return _fade(_beats_in_section(pos), BURST_BEATS)


## セクションの始まりから何拍たったか
func _beats_in_section(pos: Dictionary) -> float:
	var whole: int = pos.bar_in_section * _map.beats_per_bar + pos.beat_in_bar
	return whole + pos.since_beat / _map.grid.seconds_per_beat()
