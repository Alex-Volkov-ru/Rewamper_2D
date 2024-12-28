extends Node


@export var bullet_ability_scene: PackedScene

var damage = 10

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null:
		return
		
	var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
	
	
	var bullet_ability_instance = bullet_ability_scene.instantiate() as BulletAbility
	front_layer.add_child(bullet_ability_instance)
	
	bullet_ability_instance.global_position = player.global_position
	bullet_ability_instance.hit_box_component.damage = damage
