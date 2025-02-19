extends CharacterBody2D  # Наследуем от CharacterBody2D для работы с движением и физикой

# Привязываем компоненты
@onready var health_component = $HealthComponent  # Компонент здоровья
@onready var animated_sprite_2d = $AnimatedSprite2D  # Спрайт анимации
@onready var movement_component = $MovementComponent  # Компонент движения
@onready var bullet_pumpkin_controller: Node = $BulletPumpkinController
@onready var damage_numbers = get_tree().get_first_node_in_group("damage_layer")  # Узел для отображения урона

# Экспортируем параметры, чтобы их можно было настроить в редакторе
@export var death_scecene: PackedScene  # Сцена для эффекта смерти
@export var sprite: CompressedTexture2D  # Спрайт для эффекта смерти
@export var health_value: float = 70  # Начальное значение здоровья


# Функция, вызываемая при старте сцены
func _ready():
	# Устанавливаем максимальное и текущее здоровье моба
	health_component.max_health = health_value
	health_component.current_health = health_value
	
	# Подключаем сигналы для смерти и получения урона
	health_component.died.connect(on_died)

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
	shoot_bullet()  # Стреляем


# Функция для стрельбы пулями
func shoot_bullet():
	# Проверяем наличие контроллера пуль
	if bullet_pumpkin_controller == null:
		print("Ошибка: BulletController не найден!")
		return

	# Находим игрока
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		print("Ошибка: Игрок не найден!")
		return

	# Спавним пулю, направленную в сторону игрока
	bullet_pumpkin_controller.spawn_bullet(global_position, player.global_position)

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
