class_name Sword
extends Bullet
## プレイヤーのまわりにためた剣を撃ち出したもの。前にいるいちばん近い敵を追いかけ、
## 当たると弾と同じようにダメージを与える（敵は Bullet として受ける）。ねらう敵がいなければまっすぐ前へ飛ぶ
## ねらった敵が先に倒れたら、乗りかえられる剣（retarget）だけが次の敵をねらう

## ねらう敵までの距離の上限
const SEEK_RANGE := 40.0
## 敵の足もとではなく、体のまんなかをねらう
const AIM_HEIGHT := 0.7

## ねらっている敵
var target: Enemy
## ねらった敵が倒れたら、次に近い敵に乗りかえるか。乗りかえないなら、そのときの向きのまま飛ぶ
var retarget := false
## 一度でも敵をねらったか。まだなら、ねらえる敵が来るまで探し続ける
var _locked := false
## いま飛んでいる向き
var _direction := Vector3.FORWARD


func _process(delta: float) -> void:
	if not _can_aim(target, global_position):
		target = null
		if retarget or not _locked:
			target = Sword.nearest(global_position, get_tree().get_nodes_in_group("enemies"))
			_locked = _locked or target != null
	var step := speed * delta
	if target != null:
		var aim := target.global_position + Vector3(0, AIM_HEIGHT, 0)
		_direction = global_position.direction_to(aim)
	global_position += _direction * step
	if not _direction.is_equal_approx(Vector3.UP) and not _direction.is_equal_approx(Vector3.DOWN):
		look_at(global_position + _direction)
	_traveled += step
	if _traveled >= max_range:
		queue_free()


## nodes のうち、from より前にいて、倒れていない、いちばん近い敵。いなければ null
static func nearest(from: Vector3, nodes: Array) -> Enemy:
	var best: Enemy = null
	for node in nodes:
		if not _can_aim(node, from):
			continue
		if (
			best == null
			or from.distance_to(node.global_position) < from.distance_to(best.global_position)
		):
			best = node
	return best


## ねらえる敵か。前にいて（z が from 以下）、倒れておらず、SEEK_RANGE より近い
static func _can_aim(node: Node, from: Vector3) -> bool:
	if not is_instance_valid(node) or not node is Enemy or node.health == null:
		return false
	var enemy: Enemy = node
	return (
		not enemy.health.is_dead()
		and enemy.global_position.z <= from.z
		and from.distance_to(enemy.global_position) <= SEEK_RANGE
	)
