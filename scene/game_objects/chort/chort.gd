extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var movement_component = $MovementComponent
@onready var bullet_controller = $BulletChortController
@onready var damage_numbers = get_tree().get_first_node_in_group("damage_layer")  # Узел для отображения урона

@export var death_scecene: PackedScene
@export var sprite: CompressedTexture2D
@export var health_value: float = 15  # Начальное значение здоровья
@export var shooting_interval: float = 3  # Интервал между выстрелами
var time_since_last_shot: float = 0  # Счётчик времени

func _ready():
	# Устанавливаем максимальное и текущее здоровье моба
	health_component.max_health = health_value
	health_component.current_health = health_value
	
	
	health_component.died.connect(on_died)
	health_component.damage_received.connect(on_damage_received)  # Подключаем обработку урона

func _process(delta):
	# Движение моба
	var direction = movement_component.get_direction()
	movement_component.move_to_player(self)
	
	if direction.x != 0 or direction.y != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

	# Стрельба
	time_since_last_shot += delta
	if time_since_last_shot >= shooting_interval:
		shoot_bullet()
		time_since_last_shot = 0

func shoot_bullet():
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

func on_died():
	var back_layer = get_tree().get_first_node_in_group('back_layer')
	var death_instance = death_scecene.instantiate() as DeathComp
	back_layer.add_child(death_instance)
	death_instance.gpu_particles_2d.texture = sprite
	death_instance.sprite_offset.position.x = animated_sprite_2d.offset.y
	death_instance.global_position = global_position
	queue_free()

# Обрабатываем отображение урона
func on_damage_received(damage: int):
	if damage_numbers:
		# Отображаем урон немного выше зомби
		damage_numbers.display_number(damage, global_position + Vector2(0, -30))
