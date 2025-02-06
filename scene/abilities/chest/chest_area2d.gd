extends Area2D

@export var weapon_scene: PackedScene  # Сцена оружия для сундука
@export var arena_time_manager: ArenaTimeManager

# Эта функция срабатывает, когда в область входит объект
func _on_area_entered(area: Area2D):
	# Проверяем, что в область вошел игрок
	if area.is_in_group("player"):
		# Получаем родителя области (это должен быть игрок)
		var player = area.get_parent()

		# Проверяем, что у игрока есть метод для добавления оружия
		if player and player.has_method("add_weapon"):
			if weapon_scene:  # Проверка, что сцена оружия установлена
				player.add_weapon(weapon_scene)  # Добавляем оружие в инвентарь игрока

		# Убираем сундук после взаимодействия
		queue_free()
