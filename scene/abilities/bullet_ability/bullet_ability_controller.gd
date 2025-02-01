extends Node

# --- Экспортируемые переменные (настраиваемые в инспекторе) ---

@export var bullet_ability_scene: PackedScene  # Сцена пули, используемая для стрельбы
@export var damage: float = 10  # Базовый урон одной пули
@export var max_bullets: int = 10  # Максимальное количество патронов в магазине
# Настройки критического удара
@export var critical_chance: float = 0.2 # 20% шанс крита
@export var critical_multiplier: float = 1.5  # Урон увеличивается в 1.5 раза
# --- Локальные переменные ---

var current_bullets: int = max_bullets  # Текущее количество патронов в магазине
var is_reloading: bool = false  # Флаг процесса перезарядки (true, если идет перезарядка)

# --- Ссылки на узлы ---

@onready var reload_timer = $ReloadTimer  # Таймер, отвечающий за время перезарядки

func _ready():
	# Подписка на глобальный сигнал улучшений (при получении улучшения вызывается обработчик)
	Global.ability_upgrade_added.connect(on_upgrade_added)

# --- Функции стрельбы и перезарядки ---

# Создаёт и выпускает пулю из оружия
func spawn_bullet(gun: Node2D):
	# Проверяем, идет ли процесс перезарядки
	if is_reloading:
		return

	# Проверяем, есть ли патроны в магазине
	if current_bullets > 0:
		# Проверяем, задана ли сцена пули (иначе выдаем ошибку)
		if bullet_ability_scene == null:
			return

		# Получаем ссылку на передний слой, куда будем добавлять пулю
		var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
		if front_layer == null:
			print("Ошибка: Front Layer не найден!")
			return

		# Создаём экземпляр пули
		var bullet_instance = bullet_ability_scene.instantiate() as BulletAbility
		front_layer.add_child(bullet_instance)

		# Устанавливаем начальную позицию пули (там, где находится оружие)
		bullet_instance.global_position = gun.global_position

		# Определяем направление стрельбы (в сторону курсора)
		var direction = (gun.get_global_mouse_position() - gun.global_position).normalized()
		bullet_instance.direction = direction

		# Проверяем, произошел ли критический удар
		var final_damage = damage
		if randf() < critical_chance:  # Генерируем случайное число, если оно меньше критического шанса
			final_damage *= critical_multiplier  # Увеличиваем урон на множитель критического удара
			print("Критический удар! Урон: ", final_damage)  # Принт для отладки
		else:
			print("Обычный удар. Урон: ", final_damage)  # Принт для отладки

		# Передаем итоговый урон пуле
		bullet_instance.hit_box_component.damage = final_damage

		# Уменьшаем количество пуль в магазине
		current_bullets -= 1  

		# Если магазин пуст, начинаем перезарядку
		if current_bullets == 0:
			start_reload()
	else:
		start_reload()

# Запуск процесса перезарядки
func start_reload():
	if not is_reloading:
		is_reloading = true  # Устанавливаем флаг "перезарядка началась"
		reload_timer.start()  # Запускаем таймер перезарядки

# Обработчик завершения перезарядки (срабатывает, когда таймер перезарядки заканчивается)
func _on_reload_timer_timeout():
	# Полностью восстанавливаем магазин
	current_bullets = max_bullets
	is_reloading = false  # Сбрасываем флаг перезарядки



# --- Функция обработки улучшений ---


# Обрабатывает улучшения, полученные игроком
func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	# Улучшение урона оружия
	if upgrade.id == "gun_attack":
		var upgrade_amount = current_upgrades["gun_attack"]["quantity"]
		
		# Каждый апгрейд увеличивает урон пули на 5
		damage += 5  

	# Улучшение скорости перезарядки
	if upgrade.id == "cooldown":
		var upgrade_amount = current_upgrades["cooldown"]["quantity"]
		
		# Уменьшаем время ожидания перезарядки на 10% за каждое улучшение
		# Но время перезарядки не может быть меньше 0.3 секунды
		reload_timer.wait_time = max(0.3, reload_timer.wait_time * 0.9)

	# Улучшение размера магазина
	if upgrade.id == "magazine_clip":
		# Увеличиваем максимальный размер магазина на 5 пуль за каждое улучшение
		# Но не более 50 пуль в магазине
		max_bullets = min(50, max_bullets + 3)
