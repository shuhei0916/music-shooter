class_name SongMap
extends RefCounted
## 曲の組み立て（拍・小節・セクション）。時刻から、いまどのセクションの何小節目の何拍目かを求める

var grid: BeatGrid
## 最初の小節の頭の時刻（秒）
var downbeat: float
var beats_per_bar: int
## セクションの {bar: 始まる小節, label: 名前, energy: 盛り上がり}。小節の順に並ぶ
var sections: Array
## 曲の小節の数。分からなければ 0
var bar_count: int


func _init(
	p_grid: BeatGrid, p_downbeat: float, p_beats_per_bar := 4, p_sections := [], p_bar_count := 0
) -> void:
	grid = p_grid
	downbeat = p_downbeat
	beats_per_bar = p_beats_per_bar
	sections = p_sections
	bar_count = p_bar_count


## 曲を調べるツール（tools/analyze.py）が書き出した JSON から作る
## 読めなければ、BPM は fallback_bpm、小節の頭は 0 秒、セクションはなしとする
static func from_json(text: String, fallback_bpm: float) -> SongMap:
	var grid := BeatGrid.from_json(text, fallback_bpm)
	var data = JSON.parse_string(text) if not text.is_empty() else null
	if not data is Dictionary:
		return SongMap.new(grid, grid.offset)
	var sections := []
	for section in data.get("sections", []):
		sections.append(_read_section(section))
	return SongMap.new(
		grid,
		float(data.get("downbeat", grid.offset)),
		int(data.get("beats_per_bar", 4)),
		sections,
		data.get("bar_energy", []).size()
	)


static func _read_section(data: Dictionary) -> Dictionary:
	return {
		"bar": int(data.bar),
		"label": str(data.get("label", "")),
		"energy": float(data.get("energy", 0.0)),
	}


## time 秒の位置。section_index・section_count・label・energy・bar_in_section・
## bars_in_section（分からなければ 0）・beat_in_bar（0 が小節の頭）・since_beat（直前の拍からの秒数）
func at(time: float) -> Dictionary:
	var beat_length := grid.seconds_per_beat()
	var beat := floori((time - downbeat) / beat_length)
	var bar := maxi(floori(float(beat) / beats_per_bar), 0)
	var index := -1
	for i in sections.size():
		if sections[i].bar <= bar:
			index = i
	var start: int = sections[index].bar if index >= 0 else 0
	var end: int = bar_count
	if index + 1 < sections.size():
		end = sections[index + 1].bar
	return {
		"section_index": maxi(index, 0),
		"section_count": sections.size(),
		"label": sections[index].label if index >= 0 else "",
		"energy": sections[index].energy if index >= 0 else 0.0,
		"bar_in_section": bar - start,
		"bars_in_section": maxi(end - start, 0),
		"beat_in_bar": posmod(beat, beats_per_bar),
		"since_beat": time - downbeat - beat * beat_length,
	}


## 曲の長さ duration 秒までの、小節の頭の線。速さ speed で進むコース上の距離（distance）と、
## セクションの始まりか（section_start）、その小節のセクションの盛り上がり（energy）
func bar_lines(speed: float, duration: float) -> Array:
	var bar_length := grid.seconds_per_beat() * beats_per_bar
	var lines := []
	var bar := 0
	var time := downbeat
	while time <= duration:
		lines.append(
			{
				"distance": time * speed,
				"section_start": sections.any(func(s): return s.bar == bar),
				"energy": at(time).energy,
			}
		)
		bar += 1
		time = downbeat + bar * bar_length
	return lines
