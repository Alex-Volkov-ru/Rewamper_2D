extends Node

# Экспортируемые переменные (настраиваемые в инспекторе)
@export var bullet_ability_scene: PackedScene  # Сцена пули
@export var damage: int = 2  # Базовый урон пули
@export var max_bullets: int = 15  # Максимальное количество патронов в магазине

# Локальные переменные
var current_bullets: int = max_bullets  # Текущее количество патронов
var is_reloading: bool = false  # Флаг процесса перезарядки

# Ссылки на узлы
@onready var reload_timer = $ReloadTimer  # Таймер перезарядки

func _ready():
	# Подписка на глобальный сигнал улучшений
	Global.ability_upgrade_added.connect(on_upgrade_added)

# --- Функции стрельбы и перезарядки ---

# Создаёт и выпускает пулю из оружия
func spawn_bullet(gun: Node2D):
	# Проверяем, не идет ли процесс перезарядки
	if is_reloading:
		print("Перезарядка, подождите...")
		return

	# Проверяем наличие пуль
	if current_bullets > 0:
		# Проверяем, задана ли сцена пули
		if bullet_ability_scene == null:
			print("Ошибка: bullet_ability_scene не задан!")
			return

		# Получаем ссылку на передний слой, куда будем добавлять пулю
		var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
		if front_layer == null:
			print("Ошибка: Front Layer не найден!")
			return

		# Создаём экземпляр пули
		var bullet_instance = bullet_ability_scene.instantiate() as BulletAbility
		front_layer.add_child(bullet_instance)

		# Устанавливаем начальную позицию пули
		bullet_instance.global_position = gun.global_position

		# Рассчитываем направление стрельбы (в сторону мыши)
		var direction = (gun.get_global_mouse_position() - gun.global_position).normalized()
		bullet_instance.direction = direction

		# Передаём урон пули
		bullet_instance.hit_box_component.damage = damage

		# Уменьшаем количество пуль в магазине
		current_bullets -= 1  

		# Если патроны закончились, инициируем перезарядку
		if current_bullets == 0:
			start_reload()
	else:
		print("Пули закончились! Перезарядка...")
		start_reload()

# Запуск процесса перезарядки
func start_reload():
	if not is_reloading:
		is_reloading = true
		print("Перезарядка началась...")
		reload_timer.start()  # Запуск таймера перезарядки


# Обработчик завершения перезарядки
func _on_reload_timer_timeout():
	# Восстанавливаем количество патронов
	current_bullets = max_bullets
	is_reloading = false
	print("Перезарядка завершена, пули восстановлены.")

# --- Функция обработки улучшений ---

func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	# Улучшение урона оружия
	if upgrade.id == "gun_attack":
		var upgrade_amount = current_upgrades["gun_attack"]["quantity"]
		damage += 5  # Увеличиваем урон пули

	# Улучшение скорости перезарядки
	if upgrade.id == "cooldown":
		var upgrade_amount = current_upgrades["cooldown"]["quantity"]
		
		# Уменьшаем время ожидания перезарядки, но не меньше 0.3 сек
		reload_timer.wait_time = max(0.3, reload_timer.wait_time * 0.9)
	
	# Улучшение размера магазина
	if upgrade.id == "magazine_clip":
		var upgrade_amount = current_upgrades["magazine_clip"]["quantity"]
		max_bullets += 5  # Увеличиваем вместимость магазина
