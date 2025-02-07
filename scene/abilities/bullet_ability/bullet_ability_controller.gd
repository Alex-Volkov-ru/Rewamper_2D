extends Node

# --- Экспортируемые переменные (настраиваемые в инспекторе) ---
@export var bullet_ability_scene: PackedScene  # Сцена пули, используется для создания пули
@export var damage: float = 10  # Базовый урон одной пули
@export var critical_chance: float = 0.1  # Шанс критического удара (10%)
@export var critical_multiplier: float = 1.5  # Множитель урона при критическом ударе
@export var shooting_interval: float = 0.3  # Интервал между выстрелами

# --- Локальные переменные ---
var can_shoot: bool = true  # Флаг возможности стрельбы

# --- Ссылки на узлы ---
@onready var attack_timer: Timer = $AttackTimer  # Таймер для ограничения скорости стрельбы

# Эта функция вызывается, когда узел готов
func _ready():
	Global.ability_upgrade_added.connect(on_upgrade_added)
	attack_timer.wait_time = shooting_interval  # Устанавливаем интервал

	# Убедитесь, что сигнал не подключен дважды
	attack_timer.timeout.disconnect(_on_attack_timer_timeout)  # Отключаем сигнал, если он был подключен ранее
	attack_timer.timeout.connect(_on_attack_timer_timeout)  # Подключаем сигнал заново


# --- Функции стрельбы ---
func spawn_bullet(gun: Node2D, direction: Vector2):
	# Если нельзя стрелять, выходим из функции
	if not can_shoot:
		return

	# Проверка, что сцена пули задана
	assert(bullet_ability_scene != null, "Сцена пули не задана!")

	# Получаем ссылку на слой, куда будем добавлять пули
	var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
	if not front_layer:
		print("Ошибка: Front Layer не найден!")
		return

	# Создаем экземпляр пули
	var bullet_instance = bullet_ability_scene.instantiate() as BulletAbility
	front_layer.add_child(bullet_instance)

	# Устанавливаем позицию и направление пули
	bullet_instance.global_position = gun.global_position
	bullet_instance.direction = direction

	# Вычисляем и передаем урон
	bullet_instance.hit_box_component.damage = get_final_damage()

	# Блокируем возможность стрельбы до окончания интервала
	can_shoot = false
	attack_timer.start()

# Функция, которая разрешает стрельбу после задержки
func _on_attack_timer_timeout():
	can_shoot = true

# Функция для вычисления итогового урона (с учетом критического удара)
func get_final_damage() -> float:
	var final_damage = damage
	if randf() < critical_chance:
		final_damage *= critical_multiplier
	return final_damage

# --- Функция обработки улучшений ---
func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "gun_attack":
		damage += 5

	if upgrade.id == "cooldown":
		# Уменьшаем время между выстрелами, но не ниже 0.3
		shooting_interval = max(0.1, shooting_interval * 0.9)
		attack_timer.wait_time = shooting_interval
