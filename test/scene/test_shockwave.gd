extends GutTest
## キックが鳴るたびに、プレイヤーから前に向けた扇形の中の敵にまとめてダメージを与える衝撃波

const EnemyScene := preload("res://scenes/enemy.tscn")
const PlayerScene := preload("res://scenes/player.tscn")

var _stage: Node3D


func before_each():
	_stage = add_child_autofree(Node3D.new())


func _add_enemy(position: Vector3, hp := 5) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	enemy.position = position
	_stage.add_child(enemy)
	return enemy


func test_前に向けた扇形の中にいる敵をまとめて選ぶ():
	var front := _add_enemy(Vector3(0, 0, -3))
	var diagonal := _add_enemy(Vector3(2, 0, -3))
	_add_enemy(Vector3(0, 0, -5))
	assert_eq(Shockwave.targets(Vector3.ZERO, _stage.get_children(), 4.0), [front, diagonal])


func test_扇形の外にいる横や後ろの敵は選ばない():
	_add_enemy(Vector3(3, 0, -1))
	_add_enemy(Vector3(-2, 0, 1))
	_add_enemy(Vector3(0, 0, 2))
	assert_eq(Shockwave.targets(Vector3.ZERO, _stage.get_children(), 4.0), [])


func test_プレイヤーと重なっている敵は選ぶ():
	var enemy := _add_enemy(Vector3.ZERO)
	assert_eq(Shockwave.targets(Vector3.ZERO, _stage.get_children(), 4.0), [enemy])


func test_高さは数えず床の上の距離で選ぶ():
	var enemy := _add_enemy(Vector3(0, 0, -3))
	assert_eq(Shockwave.targets(Vector3(0, 1, 0), _stage.get_children(), 3.5), [enemy])


func test_倒れた敵と敵でないものは選ばない():
	var dead := _add_enemy(Vector3(0, 0, -1), 1)
	dead.take_hit(1)
	_stage.add_child(Node3D.new())
	assert_eq(Shockwave.targets(Vector3.ZERO, _stage.get_children(), 4.0), [])


func test_選んだ敵みんなにダメージを与える():
	var a := _add_enemy(Vector3(0, 0, -2))
	var b := _add_enemy(Vector3(1, 0, -1))
	Shockwave.blast(Vector3.ZERO, _stage.get_children(), 4.0, 2)
	assert_eq([a.health.hp, b.health.hp], [3, 3])


func test_衝撃波の形は前に向けた扇形で後ろには広がらない():
	var ring: ShockwaveRing = add_child_autofree(ShockwaveRing.new())
	var box := ring.mesh.get_aabb()
	assert_lt(box.end.z, 0.01)
	assert_almost_eq(box.position.x, -box.end.x, 0.01)


func test_衝撃波の輪は半径まで広がって消える():
	var ring: ShockwaveRing = add_child_autofree(ShockwaveRing.new())
	ring.radius = 4.0
	simulate(ring, 1, ShockwaveRing.DURATION / 2.0)
	assert_gt(ring.scale.x, 0.0)
	assert_lt(ring.scale.x, 4.0)
	simulate(ring, 1, ShockwaveRing.DURATION)
	assert_true(ring.is_queued_for_deletion())


func test_衝撃波の弧はプレイヤーの子として足元に出て進んでも付いてくる():
	var player: Player = PlayerScene.instantiate()
	_stage.add_child(player)
	player.position = Vector3(2, 0, -5)
	var track := PartTrack.from_json(
		'{"frame_rate": 10, "parts": {"kick": {"level": [], "onsets": [0.05]}}}'
	)
	player.play_shockwave(0.1, track)
	var rings := player.get_children().filter(func(n): return n is ShockwaveRing)
	assert_eq(rings.size(), 1)
	player.position.z -= 1.0
	assert_eq(Vector2(rings[0].global_position.x, rings[0].global_position.z), Vector2(2, -6))
	assert_eq(player.stats.shockwave.radius(), rings[0].radius)
