class_name Shockwave
extends RefCounted
## 衝撃波。撃つパート（初めはキック）が鳴るたびに、プレイヤーから前（-z）に向けた扇形
## （半径 PlayerStats.shockwave_radius、前から左右に HALF_ANGLE ずつ）の中の敵にまとめてダメージを与える。
## 後ろの敵はもうすれ違ったあとなので当てない。高さは数えず、床の上の距離と向きで測る

## 扇形の、前から左右それぞれに開く角度
const HALF_ANGLE := deg_to_rad(60.0)


## nodes のうち、center から前に向けた扇形（半径 radius）の中にいる、倒れていない敵（nodes の順）
static func targets(center: Vector3, nodes: Array, radius: float) -> Array:
	var hit := []
	for node in nodes:
		if not is_instance_valid(node) or not node is Enemy or node.health == null:
			continue
		var enemy: Enemy = node
		if not enemy.health.is_dead() and in_fan(enemy.global_position - center, radius):
			hit.append(enemy)
	return hit


## center のまわりの扇形（半径 radius）の中の敵みんなに damage を与える
static func blast(center: Vector3, nodes: Array, radius: float, damage: int) -> void:
	for enemy in targets(center, nodes, radius):
		enemy.take_hit(damage)


## 扇形の中心から見て offset の位置が、扇形（半径 radius）の中か。中心に重なっていれば中とする
static func in_fan(offset: Vector3, radius: float) -> bool:
	# 床の上の (x, z)。前（-z）は Vector2.UP（0, -1）にあたる
	var flat := Vector2(offset.x, offset.z)
	if flat.length() > radius:
		return false
	if flat.is_zero_approx():
		return true
	return absf(flat.angle_to(Vector2.UP)) <= HALF_ANGLE + 0.0001
