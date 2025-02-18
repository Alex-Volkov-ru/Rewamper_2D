extends Node

@export var attack_ability: PackedScene  # Сцена атаки (например, меча)

@export var mili_damage = 1  # Базовый урон
@export var critical_chance: float = 0.05  # 5% шанс критического удара
@export var critical_multiplier: float = 1.5  # Множитель урона для крита


func try_attack():
	# Находим врага
	var enemy = get_tree().get_first_node_in_group("enemy") as Node2D
	if enemy == null:
		return
	
	# Позиция врага
	var enemy_pos = enemy.global_position
	
	# Находим игрока
	var player_nodes = get_tree().get_nodes_in_group("player")  # Проверяем, есть ли игрок
	if player_nodes.is_empty():  # FIX: заменено `if player == null:` на `is_empty()`
		print("Ошибка: Игрок не найден!")
		return
	var player_pos = player_nodes[0].global_position
	
	# Определяем шанс критического удара
	var is_critical = randf() < critical_chance
	var final_damage = mili_damage * (critical_multiplier if is_critical else 1.0)
	
	# Создаем экземпляр атаки
	var attack_instance = attack_ability.instantiate() as MiliDamage
	var front_layer = get_tree().get_first_node_in_group("front_layer")
	front_layer.add_child(attack_instance)
	
	attack_instance.hit_box_component.damage = final_damage  # Устанавливаем урон
	print(final_damage)

	# Располагаем атаку между врагом и игроком
	attack_instance.global_position = (enemy_pos + player_pos) / 2
	attack_instance.look_at(player_pos)  # Направляем атаку в сторону игрока
