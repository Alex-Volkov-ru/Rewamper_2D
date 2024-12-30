extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var grace_period = $GracePeriod
@onready var progress_bar = $ProgressBar
@onready var ability_manager = $AbilityManager
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var bullet_ability_controller = $AbilityManager/BulletAbilityController
@onready var gun = $Gun # Указываем путь к ноде GUN

var max_speed = 125
var acceleration = .15
var enemies_colliding = 0

func _ready():
	health_component.died.connect(on_died)
	health_component.health_changed.connect(on_health_changed)
	Global.ability_upgrade_added.connect(on_ability_upgrade_added)
	health_update()

func _process(delta):
	# Обработка движения персонажа
	var direction = movement_vector().normalized()
	var target_velocity = max_speed * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()

	# Воспроизведение анимации в зависимости от движения
	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign
	
	# Поворот пистолета в сторону мыши
	gun.look_at(get_global_mouse_position())

	# Стрельба
	if Input.is_action_just_pressed("shoot"):
		shoot_bullet()

# Вычисление вектора движения
func movement_vector():
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(movement_x, movement_y)

# Обработка повреждений
func check_if_damaged():
	if enemies_colliding == 0 or not grace_period.is_stopped():
		return
	health_component.take_damage(1)
	grace_period.start()

# Обновление здоровья
func health_update():
	progress_bar.value = health_component.get_health_value()

# Обработка столкновений с врагами
func _on_player_hurt_box_area_entered(area):
	enemies_colliding += 1
	check_if_damaged()

func _on_player_hurt_box_area_exited(area):
	enemies_colliding -= 1

# Функция, вызываемая при смерти игрока
func on_died():
	queue_free()

# Обновление здоровья
func on_health_changed():
	health_update()

# Таймаут после получения урона
func _on_grace_period_timeout():
	check_if_damaged()

# Обработчик обновлений способностей
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade is NewAbility:
		return
		
	var new_ability = upgrade as NewAbility
	ability_manager.add_child(new_ability.new_ability_scene.instantiate())

# Стрельба пули
func shoot_bullet():
	# Проверяем BulletAbilityController
	if bullet_ability_controller == null:
		print("Ошибка: BulletAbilityController не найден!")
		return

	# Пытаемся выстрелить
	bullet_ability_controller.spawn_bullet(gun)
