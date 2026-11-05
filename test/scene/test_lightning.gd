extends GutTest
## 落雷。パート（初めはスネア）が鳴った瞬間に、離れていても前にいる HP の多い敵に雷が落ちる

const EnemyScene := preload("res://scenes/enemy.tscn")
const PlayerScene := preload("res://scenes/player.tscn")
const SNARE := '{"frame_rate": 10, "parts": {"snare": {"level": [], "onsets": [0.05]}}}'

var _stage: Node3D


func before_each():
	_stage = add_child_autofree(Node3D.new())


func _add_enemy(position: Vector3, hp := 5) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	enemy.position = position
	_stage.add_child(enemy)
	return enemy


func _bolts() -> Array:
	return _stage.get_children().filter(func(n): return n is LightningBolt)


func test_前にいる敵をHPの多い順に数だけ選ぶ():
	_add_enemy(Vector3(0, 0, -5), 3)
	var big := _add_enemy(Vector3(3, 0, -30), 20)
	var middle := _add_enemy(Vector3(-3, 0, -10), 8)
	assert_eq(Lightning.targets(Vector3.ZERO, _stage.get_children(), 2), [big, middle])


func test_後ろの敵と倒れた敵と遠すぎる敵は選ばない():
	_add_enemy(Vector3(0, 0, 3), 50)
	var dead := _add_enemy(Vector3(0, 0, -3), 1)
	dead.take_hit(1)
	_add_enemy(Vector3(0, 0, -Lightning.RANGE - 1.0), 50)
	_stage.add_child(Node3D.new())
	assert_eq(Lightning.targets(Vector3.ZERO, _stage.get_children(), 3), [])


func test_パートが鳴るとねらった敵にダメージを与え雷を見せる():
	var player: Player = PlayerScene.instantiate()
	_stage.add_child(player)
	var far := _add_enemy(Vector3(3, 0, -40), 10)
	var near := _add_enemy(Vector3(0, 0, -4), 2)
	player.stats.lightning.damage = 3
	player.play_lightning(0.1, PartTrack.from_json(SNARE))
	assert_eq([far.health.hp, near.health.hp], [7, 2])
	assert_eq(_bolts().size(), 1)
	var bolt: Node3D = _bolts()[0]
	assert_eq(Vector2(bolt.position.x, bolt.position.z), Vector2(far.position.x, far.position.z))


func test_段階が上がると一度に落ちる数が増える():
	var player: Player = PlayerScene.instantiate()
	_stage.add_child(player)
	var a := _add_enemy(Vector3(3, 0, -40), 10)
	var b := _add_enemy(Vector3(0, 0, -4), 2)
	player.stats.lightning.raise_level(1)
	player.play_lightning(0.1, PartTrack.from_json(SNARE))
	assert_eq([a.health.hp, b.health.hp], [9, 1])
	assert_eq(_bolts().size(), 2)


func test_同じ区間をもう一度渡しても二度は落ちない():
	var player: Player = PlayerScene.instantiate()
	_stage.add_child(player)
	var enemy := _add_enemy(Vector3(0, 0, -10), 10)
	var track := PartTrack.from_json(SNARE)
	player.play_lightning(0.1, track)
	player.play_lightning(0.2, track)
	assert_eq(enemy.health.hp, 9)


func test_雷は少しのあいだ見えて消える():
	var bolt: LightningBolt = add_child_autofree(LightningBolt.new())
	simulate(bolt, 1, LightningBolt.DURATION / 2.0)
	assert_false(bolt.is_queued_for_deletion())
	simulate(bolt, 1, LightningBolt.DURATION)
	assert_true(bolt.is_queued_for_deletion())
