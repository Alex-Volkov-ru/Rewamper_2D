extends Node

@export var bullet_ability_scene: PackedScene
var damage = 2

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		spawn_bullet()

func spawn_bullet():
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null:
		return

	var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
	var bullet_ability_instance = bullet_ability_scene.instantiate() as BulletAbility
	front_layer.add_child(bullet_ability_instance)

	# Устанавливаем начальную позицию пули
	bullet_ability_instance.global_position = player.global_position

	# Получаем мировую позицию мыши с учётом камеры
	var mouse_position_world = player.get_global_mouse_position()

	# Рассчитываем направление от пули (её стартовой позиции) к позиции мыши
	var direction = (mouse_position_world - bullet_ability_instance.global_position).normalized()

	# Устанавливаем направление и урон
	bullet_ability_instance.direction = direction
	bullet_ability_instance.hit_box_component.damage = damage
