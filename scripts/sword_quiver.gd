class_name SwordQuiver
extends RefCounted
## プレイヤーのまわりにためる剣。ためるパート（初めはハイハット）が鳴るたびにたまり、
## 上限（SwordWeapon.capacity）までたまったら、次に撃つパート（初めはスネア）が鳴ったときにまとめて撃つ

## いまたまっている剣の本数
var count := 0


## from 秒より後から to 秒までに鳴った音を時刻の順にたどって剣をためる。
## 撃った本数を返す（撃たなければ 0）
func update(track: PartTrack, from: float, to: float, sword: SwordWeapon) -> int:
	var events := []
	for part in sword.charge_parts:
		for time in track.onsets_in(part, from, to):
			events.append([time, false])
	for time in track.onsets_in(sword.release_part, from, to):
		events.append([time, true])
	events.sort()
	var released := 0
	var capacity := sword.capacity()
	for event in events:
		if not event[1]:
			count = mini(count + sword.level, capacity)
		elif count >= capacity:
			released += count
			count = 0
	return released
