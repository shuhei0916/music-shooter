extends GutTest

const Weapon = preload("res://scenes/objects/weapons/weapon.gd")
const TIMEBASE = 480
const BAR = TIMEBASE * 4

var weapon: Weapon


func before_each():
	weapon = Weapon.new()


func after_each():
	weapon.free()


func test_Lv1の武器は小節頭のノートで発射する():
	weapon.level = 1
	assert_true(weapon.is_on_grid(BAR * 2, TIMEBASE))


func test_Lv1の武器は小節頭以外の4分音符位置のノートでは発射しない():
	weapon.level = 1
	assert_false(weapon.is_on_grid(BAR * 2 + TIMEBASE, TIMEBASE))


func test_Lv2の武器は4分音符位置のノートで発射する():
	weapon.level = 2
	assert_true(weapon.is_on_grid(BAR * 2 + TIMEBASE, TIMEBASE))


func test_Lv2の武器は8分音符位置のノートでは発射しない():
	weapon.level = 2
	assert_false(weapon.is_on_grid(BAR * 2 + TIMEBASE / 2, TIMEBASE))


func test_Lv3の武器は8分音符位置のノートで発射する():
	weapon.level = 3
	assert_true(weapon.is_on_grid(BAR * 2 + TIMEBASE / 2, TIMEBASE))


func test_最大レベルの武器はグリッドから外れたノートでも発射する():
	weapon.level = Weapon.MAX_LEVEL
	assert_true(weapon.is_on_grid(BAR * 2 + 7, TIMEBASE))
