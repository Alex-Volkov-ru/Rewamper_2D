extends Node

# --- Экспортируемые переменные (настраиваемые в инспекторе) ---
@export var bullet_ability_scene: PackedScene  # Сцена пули, используется для создания пули
@export var damage: float = 10  # Базовый урон одной пули
@export var max_bullets: int = 20  # Максимальное количество патронов в магазине
@export var critical_chance: float = 0.2 # Шанс критического удара (20%)
@export var critical_multiplier: float = 1.5  # Множитель урона при критическом ударе

# --- Локальные переменные ---
var current_bullets: int = max_bullets  # Текущее количество патронов
var is_reloading: bool = false  # Флаг, указывающий на процесс перезарядки

# --- Ссылки на узлы ---
@onready var reload_timer = $ReloadTimer  # Таймер, используемый для отслеживания времени перезарядки
@onready var attack_timer = $AttackTimer
@export var shooting_interval: float = 0.5  # Интервал между выстрелами
var time_since_last_shot: float = 0  # Счётчик времени для автоматической стрельбы

# Эта функция вызывается, когда узел готов
func _ready():
	# Подписываемся на сигнал улучшений, чтобы обрабатывать полученные улучшения
	Global.ability_upgrade_added.connect(on_upgrade_added)

# --- Функции стрельбы и перезарядки ---

# Функция для создания и выпуска пули
func spawn_bullet(gun: Node2D, direction: Vector2):
	# Если идет перезарядка или патроны закончились, начинаем процесс перезарядки
	if is_reloading or current_bullets <= 0:
		start_reload()
		return
	
	# Проверяем, что сцена пули задана
	assert(bullet_ability_scene != null, "Сцена пули не задана!")

	# Получаем ссылку на слой, куда будем добавлять пули (например, передний слой экрана)
	var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
	if not front_layer:
		# Если слой не найден, выводим ошибку
		print("Ошибка: Front Layer не найден!")
		return

	# Создаем экземпляр пули из сцены
	var bullet_instance = bullet_ability_scene.instantiate() as BulletAbility
	front_layer.add_child(bullet_instance)  # Добавляем пулю в игровой мир

	# Устанавливаем начальную позицию пули, где находится оружие
	bullet_instance.global_position = gun.global_position
	# Устанавливаем направление полета пули
	bullet_instance.direction = direction

	# Вычисляем итоговый урон с учетом возможности критического удара
	var final_damage = get_final_damage()

	# Передаем рассчитанный урон пуле
	bullet_instance.hit_box_component.damage = final_damage

	# Уменьшаем количество патронов в магазине
	current_bullets -= 1

	# Если патроны закончились, начинаем процесс перезарядки
	if current_bullets == 0:
		start_reload()

# Функция для вычисления итогового урона (с учетом критического удара)
func get_final_damage() -> float:
	# Начальный урон равен базовому урону
	var final_damage = damage
	# Если выпал критический удар (случайное число меньше шанса)
	if randf() < critical_chance:
		# Увеличиваем урон на множитель критического удара
		final_damage *= critical_multiplier
		# Выводим информацию о критическом ударе в консоль
	else:
		# Если критического удара не было, выводим обычный урон
		final_damage
	return final_damage

# Функция для начала процесса перезарядки
func start_reload():
	# Если перезарядка еще не началась, запускаем её
	if not is_reloading:
		is_reloading = true  # Устанавливаем флаг начала перезарядки
		reload_timer.start()  # Запускаем таймер перезарядки

# Функция, которая вызывается, когда таймер перезарядки завершен
func _on_reload_timer_timeout():
	# Восстанавливаем магазин до максимального размера
	current_bullets = max_bullets
	# Сбрасываем флаг перезарядки
	is_reloading = false

# --- Функция обработки улучшений ---
# Эта функция обрабатывает улучшения, полученные игроком
func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	# Улучшение урона
	if upgrade.id == "gun_attack":
		# Каждый апгрейд увеличивает урон на 5
		damage += 5

	# Улучшение скорости перезарядки
	if upgrade.id == "cooldown":
		# Уменьшаем время перезарядки на 10% за каждое улучшение
		# Но не меньше 0.3 секунд
		reload_timer.wait_time = max(0.3, reload_timer.wait_time * 0.9)

	# Улучшение размера магазина
	if upgrade.id == "magazine_clip":
		# Увеличиваем размер магазина на 5 патронов за каждое улучшение
		# Но не более 50 патронов
		max_bullets = min(50, max_bullets + 5)


func _on_attack_timer_timeout() -> void:
	pass # Replace with function body.
