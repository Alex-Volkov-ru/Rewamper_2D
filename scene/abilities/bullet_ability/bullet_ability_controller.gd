extends Node

@export var bullet_ability_scene: PackedScene
var damage = 2

# Вызывается для выстрела
func spawn_bullet():
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null:
		print("Ошибка: Игрок не найден!")
		return

	# Найдём Marker2D в Pistolet2D (пистолет)
	var gun_marker = player.get_node("GunCast2D/Marker2D") as Marker2D
	if gun_marker == null:
		print("Ошибка: Gun Marker не найден!")
		return

	var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
	if front_layer == null:
		print("Ошибка: Front Layer не найден!")
		return

	# Создаём экземпляр пули
	var bullet_ability_instance = bullet_ability_scene.instantiate() as BulletAbility
	front_layer.add_child(bullet_ability_instance)

	# Устанавливаем начальную позицию пули из Gun Marker
	bullet_ability_instance.global_position = gun_marker.global_position

	# Рассчитываем направление от пистолета к мыши
	var mouse_position_world = player.get_global_mouse_position()
	var direction = (mouse_position_world - gun_marker.global_position).normalized()

	# Устанавливаем направление и урон
	bullet_ability_instance.direction = direction
	bullet_ability_instance.hit_box_component.damage = damage
