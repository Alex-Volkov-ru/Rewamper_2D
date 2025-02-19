extends Node

# --- Экспортируемые переменные (настраиваемые в инспекторе) ---
@export var bullet_ability_scene: PackedScene  # Сцена пули, используется для создания пули
@export var damage: int = 5  # Базовый урон одной пули
@export var critical_chance: float = 0.01  # Шанс критического удара
@export var critical_multiplier: float = 1.5  # Множитель урона при критическом ударе
@export var shooting_interval: float = 2.7  # Интервал между выстрелами

# --- Локальные переменные ---
var can_shoot: bool = true  # Флаг возможности стрельбы
@onready var attack_timer: Timer = $AttackTimer  # Таймер для ограничения скорости стрельбы

# Эта функция вызывается, когда узел готов
func _ready():
	attack_timer.wait_time = shooting_interval  # Устанавливаем интервал между выстрелами

	# Убедитесь, что сигнал не подключен дважды
	attack_timer.timeout.connect(_on_attack_timer_timeout)  # Подключаем сигнал заново

# --- Функции стрельбы ---
func spawn_bullet(start_position: Vector2, target_position: Vector2):
	# Если нельзя стрелять, выходим из функции
	if not can_shoot:
		return

	# Проверка, что сцена пули задана
	assert(bullet_ability_scene != null, "Сцена пули не задана!")

	# Получаем ссылку на слой, куда будем добавлять пули
	var front_layer = get_tree().get_first_node_in_group("front_layer") as Node2D
	if front_layer == null:
		print("Ошибка: Front Layer не найден!")
		return

	# Создаем экземпляр пули
	var bullet_instance = bullet_ability_scene.instantiate() as BulletIceZombie # Убедитесь, что это Node2D
	front_layer.add_child(bullet_instance)

	# Устанавливаем начальную позицию пули
	bullet_instance.position = start_position  # Используем position, а не global_position
	bullet_instance.direction = (target_position - start_position).normalized()

	# Устанавливаем урон с учётом критического удара
	bullet_instance.hit_box_component.damage = get_final_damage()
	# Блокируем возможность стрельбы до окончания интервала
	can_shoot = false
	attack_timer.start()  # Запускаем таймер

# Функция, которая разрешает стрельбу после задержки
func _on_attack_timer_timeout():
	can_shoot = true

# Функция для вычисления итогового урона (с учетом критического удара)
func get_final_damage() -> float:
	var final_damage = damage
	if randf() < critical_chance:
		final_damage *= critical_multiplier
	return final_damage
