extends Area2D  # Обязательно изменяем на Area2D для работы с коллизиями

@export var weapon_scene: PackedScene  # Сцена оружия для сундука

# Эта функция срабатывает, когда в область входит объект
func _on_area_entered(area: Area2D):
	if area.is_in_group("player"):  # Проверка, если объект принадлежит группе "player"
		var player = area.get_parent()  # Получаем родителя, это должен быть игрок

		if player and player.has_method("add_weapon"):  # Проверяем, есть ли у родителя метод add_weapon
			if weapon_scene:  # Проверка, что сцена оружия установлена
				player.add_weapon(weapon_scene)  # Добавляем оружие в инвентарь игрока
				queue_free()  # Убираем сундук после взаимодействия
