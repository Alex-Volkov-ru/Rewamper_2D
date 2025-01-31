extends CharacterBody2D  # Наследуем от CharacterBody2D для работы с движением и физикой

# Привязываем компоненты
@onready var health_component = $HealthComponent  # Компонент здоровья
@onready var animated_sprite_2d = $AnimatedSprite2D  # Спрайт анимации
@onready var movement_component = $MovementComponent  # Компонент движения
@onready var bullet_controller = $BulletOrkShamanController  # Контроллер для управления пулями
@onready var damage_numbers = get_tree().get_first_node_in_group("damage_layer")  # Узел для отображения урона

# Экспортируем параметры, чтобы их можно было настроить в редакторе
@export var death_scecene: PackedScene  # Сцена для эффекта смерти
@export var sprite: CompressedTexture2D  # Спрайт для эффекта смерти
@export var health_value: float = 15  # Начальное значение здоровья
@export var shooting_interval: float = 3  # Интервал между выстрелами

var time_since_last_shot: float = 0  # Счётчик времени для отслеживания интервала между выстрелами

# Функция, вызываемая при старте сцены
func _ready():
	# Устанавливаем максимальное и текущее здоровье моба
	health_component.max_health = health_value
	health_component.current_health = health_value
	
	# Подключаем сигналы для смерти и получения урона
	health_component.died.connect(on_died)
	health_component.damage_received.connect(on_damage_received)  # Подключаем обработку урона

# Основной процесс обновления игры
func _process(delta):
	# Двигаем моба в сторону игрока
	var direction = movement_component.get_direction()
	movement_component.move_to_player(self)
	
	# Включаем анимацию в зависимости от направления движения
	if direction.x != 0 or direction.y != 0:
		animated_sprite_2d.play("run")  # Запуск анимации бега
	else:
		animated_sprite_2d.play("idle")  # Запуск анимации стояния
	
	# Поворачиваем спрайт в зависимости от направления движения по оси X
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign  # Меняем направление взгляда

	# Логика стрельбы
	time_since_last_shot += delta  # Увеличиваем счётчик времени
	if time_since_last_shot >= shooting_interval:
		shoot_bullet()  # Стреляем
		time_since_last_shot = 0  # Сброс счётчика времени после выстрела

# Функция для стрельбы пулями
func shoot_bullet():
	# Проверяем наличие контроллера пуль
	if bullet_controller == null:
		print("Ошибка: BulletController не найден!")
		return

	# Находим игрока
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		print("Ошибка: Игрок не найден!")
		return

	# Спавним пулю, направленную в сторону игрока
	bullet_controller.spawn_bullet(global_position, player.global_position)

# Обработка смерти моба
func on_died():
	# Получаем слой, на котором будет отображаться эффект смерти
	var back_layer = get_tree().get_first_node_in_group('back_layer')
	
	# Создаем и отображаем эффект смерти
	var death_instance = death_scecene.instantiate() as DeathComp
	back_layer.add_child(death_instance)  # Добавляем эффект в родительский узел
	
	# Устанавливаем спрайт для эффекта смерти
	death_instance.gpu_particles_2d.texture = sprite
	death_instance.sprite_offset.position.x = animated_sprite_2d.offset.y
	death_instance.global_position = global_position  # Размещаем эффект на месте смерти моба
	
	# Удаляем моба из сцены
	queue_free()

# Обрабатываем отображение урона
func on_damage_received(damage: int):
	if damage_numbers:
		# Отображаем урон немного выше моба
		damage_numbers.display_number(damage, global_position + Vector2(0, -30))
