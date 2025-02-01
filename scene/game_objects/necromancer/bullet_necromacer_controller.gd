extends Node

@export var bullet_ability_scene: PackedScene
@export var damage: int = 5  # Урон от пули

# Функция для спавна пули
func spawn_bullet(start_position: Vector2, target_position: Vector2):
	# Проверяем наличие сцены пули
	if bullet_ability_scene == null:
		print("Ошибка: bullet_ability_scene не задан!")
		return

	# Находим front_layer для размещения пули
	var front_layer = get_tree().get_first_node_in_group("front_layer") as Node2D
	if front_layer == null:
		print("Ошибка: Front Layer не найден!")
		return

	# Создаём экземпляр пули
	var bullet_instance = bullet_ability_scene.instantiate() as Node2D  # Убедитесь, что это Node2D
	if bullet_instance == null:
		print("Ошибка: не удалось инстанцировать пулю!")
		return

	front_layer.add_child(bullet_instance)

	# Устанавливаем начальную позицию и направление пули
	bullet_instance.position = start_position  # Используем position, а не global_position
	bullet_instance.direction = (target_position - start_position).normalized()

	# Устанавливаем урон
	bullet_instance.hit_box_component.damage = damage
