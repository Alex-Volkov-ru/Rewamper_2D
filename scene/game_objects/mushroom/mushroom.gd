extends CharacterBody2D  # Наследуемся от CharacterBody2D для работы с передвижением и физикой

# Привязываем узлы и компоненты, которые будут использоваться в скрипте
@onready var health_component = $HealthComponent  # Компонент здоровья
@onready var animated_sprite_2d = $AnimatedSprite2D  # Спрайт анимации
@onready var movement_component = $MovementComponent  # Компонент движения
@onready var damage_numbers = get_tree().get_first_node_in_group("damage_layer")  # Узел для отображения урона

# Экспортируем параметры, чтобы их можно было настроить в редакторе
@export var death_scecene: PackedScene  # Сцена для отображения эффекта смерти
@export var sprite: CompressedTexture2D  # Спрайт для эффекта смерти
@export var health_value: float = 10  # Начальное значение здоровья моба

# Функция, которая вызывается при старте сцены
func _ready():
	# Устанавливаем максимальное и текущее здоровье моба
	health_component.max_health = health_value
	health_component.current_health = health_value
	
	# Подключаем сигналы для смерти и получения урона
	health_component.died.connect(on_died)
	health_component.damage_received.connect(on_damage_received)  # Подключаем обработку урона

# Основной процесс обновления игры
func _process(delta):
	# Получаем направление движения от компонента движения
	var direction = movement_component.get_direction()
	
	# Двигаем моба в сторону игрока
	movement_component.move_to_player(self)

	# Включаем анимацию в зависимости от направления движения
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("run")  # Запуск анимации бега
	else:
		animated_sprite_2d.play("idle")  # Запуск анимации стояния

	# Поворачиваем спрайт в зависимости от направления движения по оси X
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign  # Меняем направление взгляда

# Обрабатываем отображение урона
func on_damage_received(damage: float):
	if damage_numbers:
		# Если урон критический, передаем true
		damage_numbers.display_number(damage, global_position + Vector2(0, -30))  # Отображаем урон на экране

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
