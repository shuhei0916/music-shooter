class_name SwordQuiver
extends RefCounted
## プレイヤーのまわりにためる剣。スネアとハイハットが鳴るたびにたまり、
## 上限（PlayerStats.sword_capacity）までたまったら、次のキックでまとめて撃つ

## 剣がたまる項目と、撃つ項目（parts.json の項目の名前）
const CHARGE_PARTS := ["snare", "hihat"]
const RELEASE_PART := "kick"

## いまたまっている剣の本数
var count := 0


## from 秒より後から to 秒までに鳴った音を時刻の順にたどって剣をためる。
## 撃った本数を返す（撃たなければ 0）
func update(track: PartTrack, from: float, to: float, stats: PlayerStats) -> int:
	var events := []
	for part in CHARGE_PARTS:
		for time in track.onsets_in(part, from, to):
			events.append([time, false])
	for time in track.onsets_in(RELEASE_PART, from, to):
		events.append([time, true])
	events.sort()
	var released := 0
	var capacity := stats.sword_capacity()
	for event in events:
		if not event[1]:
			count = mini(count + stats.sword_count, capacity)
		elif count >= capacity:
			released += count
			count = 0
	return released
