extends GutTest

const Player = preload("res://scenes/characters/player/player.gd")
const Enemy = preload("res://scenes/characters/enemy/enemy.gd")

var player: Player
var enemy


func before_each():
	player = Player.new()
	enemy = Enemy.new()
	
	player.hp = 10
	
	player.horizontal_limit_min = -4.0
	player.horizontal_limit_max = 4.0

func after_each():
	player.free()
	enemy.free()
	
func test_右端を超えた位置は最大値にクランプされる():
	player.position.x = 6.5
	player.clamp_horizontal_position()
	assert_eq(4.0, player.position.x)

func test_左端を超えた位置は最小値にクランプされる():
	player.position.x = -7.2
	player.clamp_horizontal_position()
	assert_eq(-4.0, player.position.x)
	
func test_加算ゲートの効果でHPが加算される() -> void:
	player.apply_gate_effect("add", 5)
	assert_eq(15, player.hp)

func test_乗算ゲートの効果でHPが乗算される() -> void:
	player.apply_gate_effect("multiply", 2)
	assert_eq(20, player.hp)
	
func test_HPが0以下になるとgame_overが呼ばれる() -> void:
	watch_signals(player)
	player.take_damage(10)
	
	assert_true(player.hp <= 0)
	assert_signal_emitted(player, "game_over_signal")
	
func test_敵との衝突でお互いにダメージを与える() -> void:
	enemy.hp = 7
	player._on_enemy_collided(enemy) # 将来的には FakeEnemy に差し替える余地アリ
	assert_eq(3, player.hp)
