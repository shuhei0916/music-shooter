extends GutTest
## 難易度の目標: うまく選べば曲の終わりにHPがB（10億）を超えて無双でき、適当に選ぶと超えられない。
## 弾は計算に入れない（実際のプレイより厳しい）

const BalanceSimulator = preload("res://scripts/balance_simulator.gd")
const SPAWNER_SCENE = preload("res://scenes/components/spawner.tscn")
const BILLION := 1_000_000_000
const RUNS := 200
const SONG_TURNS := 180  # 3分の曲（1ターン1秒）


func after_all():
	randomize()


func _rate_over_billion(choose: Callable) -> float:
	var spawner: Node = autofree(SPAWNER_SCENE.instantiate())
	var over := 0
	for i in RUNS:
		seed(i)
		if BalanceSimulator.run(spawner, SONG_TURNS, choose) > BILLION:
			over += 1
	return float(over) / RUNS


func test_最善を選ぶとほぼBを超える():
	assert_gte(_rate_over_billion(func(c: Array): return c.max()), 0.9)


func test_適当に選ぶとBを超えない():
	assert_lte(_rate_over_billion(func(c: Array): return c.pick_random()), 0.05)
