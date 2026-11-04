extends GutTest
## 敵の、当たったときや倒れたときの演出を曲の拍に合わせる動き

const EnemyScene := preload("res://scenes/enemy.tscn")
const BulletScene := preload("res://scenes/bullet.tscn")


## 敵が親に置くもの（ダメージの数字など）を調べやすいよう、テストごとに専用の親の下に置く
func _make_enemy(hp: int) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	add_child_autofree(Node3D.new()).add_child(enemy)
	return enemy


func _body_color(enemy: Enemy) -> Color:
	return enemy.get_node("Body").material_override.albedo_color


func _damage_texts(enemy: Enemy) -> Array:
	return enemy.get_parent().get_children().filter(func(n): return n is FloatingText)


## BPM 120（1拍 0.5 秒）の曲を time 秒まで進めた時計と拍の線を、敵に渡す
func _sync_to_beat(enemy: Enemy, time: float) -> TimerClock:
	var clock := TimerClock.new(100.0)
	clock.advance(time)
	enemy.clock = clock
	enemy.grid = BeatGrid.new(120.0)
	return clock


func _hit(enemy: Enemy, damage: int) -> void:
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	bullet.damage = damage
	enemy.area_entered.emit(bullet)


func test_拍に合わせるときは当たってすぐにはHPだけが減り演出はまだ出ない():
	var enemy := _make_enemy(5)
	var original := _body_color(enemy)
	_sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	assert_eq(enemy.health.hp, 3)
	assert_eq(_body_color(enemy), original)
	assert_eq(_damage_texts(enemy).size(), 0)


func test_拍に合わせるときは次の四分の一拍で光り数字が出る():
	var enemy := _make_enemy(5)
	var clock := _sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	clock.advance(0.075)
	simulate(enemy, 1, 0.0)
	assert_eq(_body_color(enemy), Color.WHITE)
	assert_eq(_damage_texts(enemy).map(func(t): return t.text), ["2"])


func test_演出が出るまでに続けて当たったダメージは1つの数字にまとめる():
	var enemy := _make_enemy(10)
	var clock := _sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	_hit(enemy, 3)
	clock.advance(0.075)
	simulate(enemy, 1, 0.0)
	assert_eq(_damage_texts(enemy).map(func(t): return t.text), ["5"])


func test_拍に合わせるときは倒れる演出を次の半拍まで待つ():
	var enemy := _make_enemy(2)
	var clock := _sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	clock.advance(0.15)
	simulate(enemy, 1, 0.0)
	assert_eq(_body_color(enemy).a, 1.0)
	assert_eq(_damage_texts(enemy).map(func(t): return t.text), ["2"])
	clock.advance(0.06)
	simulate(enemy, 1, enemy.death_duration / 2.0)
	assert_lt(_body_color(enemy).a, 1.0)


func test_拍に合わせるときはダメージの数字を1拍で消す():
	var enemy := _make_enemy(5)
	_sync_to_beat(enemy, 0.0)
	_hit(enemy, 1)
	assert_almost_eq(_damage_texts(enemy)[0].duration, 0.5, 0.0001)


func test_倒れる演出を待つあいだはHPを表示しない():
	var enemy := _make_enemy(2)
	_sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	assert_false(enemy.get_node("HpLabel").visible)


func _treasures(enemy: Enemy) -> Array:
	return enemy.get_parent().get_children().filter(func(n): return n is Treasure)


func test_拍に合わせるときは宝箱も倒れる演出と同じ次の半拍に出る():
	var enemy := _make_enemy(2)
	var clock := _sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	assert_eq(_treasures(enemy).size(), 0)
	clock.advance(0.2)
	simulate(enemy, 1, 0.0)
	assert_eq(_treasures(enemy).size(), 1)
	assert_eq(_treasures(enemy)[0].grid, enemy.grid)
