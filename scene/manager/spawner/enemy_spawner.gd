extends Node

@onready var timer = $Timer

@export var arena_time_manager: ArenaTimeManager


@export var mushroom_scene: PackedScene
@export var ork_masked_scene: PackedScene
@export var ork_warrior_scene: PackedScene
@export var goblin_scene: PackedScene
@export var skelet_scene: PackedScene
@export var swampy_scene: PackedScene
@export var tiny_zombie_scene: PackedScene
@export var lizard_scene: PackedScene
@export var ogr_scene: PackedScene



@export var chort_scene: PackedScene
@export var ice_zombie_scene: PackedScene
@export var pumpkin_scene: PackedScene
@export var demon_scene: PackedScene
@export var zombie_scene: PackedScene
@export var ork_shaman_scene: PackedScene
@export var wogol_scene: PackedScene
@export var necromancer_scene: PackedScene




var base_spawn_time
var min_spawn_time = 0.2
var difficulty_multiplier = 0.01
var enemy_pool = EnemyPool.new() 

func _ready():
	enemy_pool.add_mod(mushroom_scene, 10)
	base_spawn_time = timer.wait_time
	arena_time_manager.difficulty_increased.connect(on_difficulty_increased)
	
	
func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var random_distance = randi_range(380, 500)
	
	for i in 24:
		spawn_position = player.global_position + (random_direction * random_distance)
		var raycast = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
		var intersection = get_tree().root.world_2d.direct_space_state.intersect_ray(raycast)
		
		if intersection.is_empty():
			break
		
		else:
			random_direction = random_direction.rotated(deg_to_rad(15))
	
	return spawn_position

func _on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var chosen_mob = enemy_pool.pick_mob()
	var enemy = chosen_mob.instantiate() as Node2D
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	back_layer.add_child(enemy)
	
	enemy.global_position = get_spawn_position()
	
	
func on_difficulty_increased(difficulty_level: int):
	var new_spawn_time = max(min_spawn_time, (base_spawn_time - (difficulty_level * difficulty_multiplier)))
	timer.wait_time = new_spawn_time
	print('начальный уровень сложности(difficulty_level) с 0 минуты = ', difficulty_level)
	# Появление на 1-й минуте
	if difficulty_level == 1:
		enemy_pool.add_mod(zombie_scene, 50)
	
	# Появление на 2-й минуте
	if difficulty_level == 24:
		enemy_pool.add_mod(goblin_scene, 50)
		enemy_pool.add_mod(skelet_scene, 40)

	# Появление на 3-й минуте
	if difficulty_level == 35:
		enemy_pool.add_mod(ork_masked_scene, 70)
		enemy_pool.add_mod(zombie_scene, 60)
		
	# Появление на 4-й минуте
	if difficulty_level == 45:
		enemy_pool.add_mod(ork_warrior_scene, 80)
		enemy_pool.add_mod(chort_scene, 40)

	# Появление на 5-й минуте
	if difficulty_level == 55:
		enemy_pool.add_mod(demon_scene, 100)
		enemy_pool.add_mod(ice_zombie_scene, 60)
		enemy_pool.add_mod(ork_shaman_scene, 60)

	# Появление на 6-й минуте
	if difficulty_level == 70:
		enemy_pool.add_mod(necromancer_scene, 80)
		enemy_pool.add_mod(ork_shaman_scene, 60)

	# Появление на 7-й минуте
	if difficulty_level == 80:
		enemy_pool.add_mod(lizard_scene, 80)
		enemy_pool.add_mod(wogol_scene, 60)
		
	# Все мобы на поле к 8-й минуте
	if difficulty_level == 90:
		enemy_pool.add_mod(pumpkin_scene, 100)
		enemy_pool.add_mod(swampy_scene, 80)
		enemy_pool.add_mod(ogr_scene, 80)
		enemy_pool.add_mod(ork_shaman_scene, 70)
		enemy_pool.add_mod(necromancer_scene, 100)
	
