extends GutTest
## スネアとハイハットで剣をため、上限までたまったら次のキックでまとめて撃つ

const JSON_TEXT := (
	'{"frame_rate": 10, "parts": {'
	+ '"snare": {"level": [], "onsets": [0.1, 0.3, 0.5, 0.7]},'
	+ '"hihat": {"level": [], "onsets": [0.2, 0.4]},'
	+ '"kick": {"level": [], "onsets": [0.15, 0.45, 0.9]}}}'
)

var _track: PartTrack
var _stats: PlayerStats
var _quiver: SwordQuiver


func before_each():
	_track = PartTrack.from_json(JSON_TEXT)
	_stats = PlayerStats.new(10)
	_quiver = SwordQuiver.new()


## times の区切りで順に進め、撃った本数を並べる
func _play(times: Array) -> Array:
	var released := []
	for i in range(1, times.size()):
		released.append(_quiver.update(_track, times[i - 1], times[i], _stats))
	return released


func test_スネアとハイハットが鳴るたびに剣が1本たまる():
	_play([0.0, 0.12, 0.25])
	assert_eq(_quiver.count, 2)


func test_上限までたまっていなければキックが鳴っても撃たない():
	assert_eq(_play([0.0, 0.16]), [0])
	assert_eq(_quiver.count, 1)


func test_上限までたまったら次のキックでまとめて撃つ():
	# 0.1・0.2・0.3・0.4 で4本たまり、0.45 のキックで撃つ
	assert_eq(_play([0.0, 0.42, 0.46]), [0, 4])
	assert_eq(_quiver.count, 0)


func test_区間の中ではキックより前に鳴った音だけで上限を判断する():
	# 0.15 のキックのときはまだ1本なので撃たず、0.45 のキックで撃つ
	assert_eq(_play([0.0, 0.46]), [4])


func test_上限より多くはたまらない():
	_quiver.count = _stats.sword_capacity()
	_play([0.0, 0.12])
	assert_eq(_quiver.count, _stats.sword_capacity())


func test_剣の段階が上がると1回の音でたまる本数と上限が増える():
	_stats.sword_count = 2
	assert_eq(_stats.sword_capacity(), PlayerStats.SWORDS_PER_VOLLEY * 2)
	_play([0.0, 0.12])
	assert_eq(_quiver.count, 2)


func test_パートの解析が無ければ剣はたまらない():
	assert_eq(_quiver.update(PartTrack.from_json(""), 0.0, 10.0, _stats), 0)
	assert_eq(_quiver.count, 0)
