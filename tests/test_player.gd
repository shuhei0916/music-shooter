extends GutTest

var gate
var player
var enemy 

func before_each():
	gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	enemy = preload("res://scenes/characters/enemy/enemy.tscn").instantiate()
	
	add_child_autofree(gate)
	add_child_autofree(player)
	add_child_autofree(enemy)
	
	player.horizontal_limit_min = -4.0
	player.horizontal_limit_max = 4.0

func after_each():
	player.free()

func test_右端を超えた位置は最大値にクランプされる():
	player.position.x = 6.5
	player.clamp_horizontal_position()
	assert_eq(4.0, player.position.x)

func test_左端を超えた位置は最小値にクランプされる():
	player.position.x = -7.2
	player.clamp_horizontal_position()
	assert_eq(-4.0, player.position.x)

func test_Playerとゲートが衝突するとPlayerのHPが変化する():
	gate.gate_type = "add"
	gate.value = 5
	player.hp = 10
	gate._on_body_entered(player)
	assert_eq(15, player.hp)

func test_HPが変化するとHPLabelも更新される():
	player.hp = 7
	var label: Label3D = player.get_node("HPLabel")
	assert_eq("7", label.text)

func test_敵HP7と衝突するとPlayerのHPは3になり敵は消滅する():
	player.hp = 10
	enemy.hp = 7
	player._on_enemy_collided(enemy)
	assert_eq(3, player.hp)
	assert_true(enemy.is_queued_for_deletion())

func test_PlayerのHPが敵より小さい場合はPlayerが消滅し敵HPが減る():
	player.hp = 7
	enemy.hp = 10
	player._on_enemy_collided(enemy)
	assert_true(player.hp <= 0)
	assert_false(enemy.is_queued_for_deletion())
	assert_eq(3, enemy.hp)
	
func test_Playerと敵のHPが等しいときはどちらも消滅する():
	player.hp = 10
	enemy.hp = 10
	player._on_enemy_collided(enemy)
	assert_true(player.hp <= 0)
	assert_true(enemy.hp <= 0)
	
func test_shootが呼ばれると弾丸がシーンに追加される():
	var bullet_parent = Node3D.new()
	add_child_autofree(bullet_parent)
	
	player.bullet_container = bullet_parent
	player.shoot()
	
	var bullets = bullet_parent.get_children()
	assert_eq(1, bullets.size())
	assert_true(bullets[0].is_in_group("bullet"))
	
