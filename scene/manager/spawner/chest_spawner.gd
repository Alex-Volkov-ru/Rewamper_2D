extends Node

@onready var timer = $Timer  # Таймер для отслеживания времени
@export var chest_scene: PackedScene  # Сцена сундука, которую мы будем инстанцировать
@export var arena_time_manager: ArenaTimeManager  # Ссылка на менеджер времени арены

var spawned_at_20 = false  # Флаг для отслеживания спавна сундука на уровне 20
var spawned_at_40 = false  # Флаг для отслеживания спавна сундука на уровне 40

func _ready():
	# Проверяем, что таймер существует, и начинаем отсчет времени
	if timer.is_stopped():
		timer.start()

	# Подключаем сигнал изменения сложности
	arena_time_manager.difficulty_increased.connect(on_difficulty_increased)

# Функция для отслеживания изменения сложности
func on_difficulty_increased(difficulty_level: int):
	# Проверка, если сложность достигла 20, и сундук еще не был спавнен
	if difficulty_level >= 20 and not spawned_at_20:
		spawn_chest()  # Спавним сундук
		spawned_at_20 = true  # Устанавливаем флаг, чтобы не спавнить сундук снова на уровне 20

	# Проверка, если сложность достигла 40, и сундук еще не был спавнен
	if difficulty_level >= 40 and not spawned_at_40:
		spawn_chest()  # Спавним сундук
		spawned_at_40 = true  # Устанавливаем флаг, чтобы не спавнить сундук снова на уровне 40

func spawn_chest():
	# Инстанцируем сундук
	if chest_scene:
		var chest = chest_scene.instantiate()  # Создаем объект сундука
		# Получаем игрока и спавним сундук рядом с ним
		var player = get_tree().get_first_node_in_group("player") as Node2D
		if player:
			chest.position = player.global_position + Vector2(100, 0)  # Сундук появляется рядом с игроком
			get_parent().add_child(chest)  # Добавляем сундук в сцену
			print("Сундук спавнен рядом с игроком на позиции: ", chest.position)
		else:
			print("Игрок не найден! Сундук не может быть спавнен.")
