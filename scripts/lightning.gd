class_name Lightning
extends RefCounted
## 落雷。パート（初めはスネア）が鳴った瞬間に、離れていても前にいる HP の多い敵に雷が落ちる
## 敵はコースに初めから並んでいるので、画面に見えるくらいの範囲（RANGE）の敵だけをねらう

## ねらう敵までの前への距離の上限（m）
const RANGE := 50.0


## nodes のうち、from より前にいて RANGE より近い、倒れていない敵を、HP の多い順に count 体まで（同じ HP なら nodes の順）
static func targets(from: Vector3, nodes: Array, count: int) -> Array:
	var candidates := []
	for node in nodes:
		if not is_instance_valid(node) or not node is Enemy or node.health == null:
			continue
		var enemy: Enemy = node
		var ahead := from.z - enemy.global_position.z
		if not enemy.health.is_dead() and ahead >= 0.0 and ahead <= RANGE:
			candidates.append(enemy)
	var order := range(candidates.size())
	order.sort_custom(
		func(a, b):
			var hp_a: int = candidates[a].health.hp
			var hp_b: int = candidates[b].health.hp
			return hp_a > hp_b or (hp_a == hp_b and a < b)
	)
	return order.slice(0, count).map(func(i): return candidates[i])
