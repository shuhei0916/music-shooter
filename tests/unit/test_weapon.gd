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
