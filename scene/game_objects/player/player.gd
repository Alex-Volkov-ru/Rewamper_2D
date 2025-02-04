extends CharacterBody2D

# Компоненты
@onready var health_component = $HealthComponent
@onready var grace_period = $GracePeriod
@onready var progress_bar = $ProgressBar
@onready var ability_manager = $AbilityManager
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var bullet_ability_controller = $AbilityManager/BulletAbilityController
@onready var gun = $Gun
@onready var dashDurationTimer = $DashDurationTimer
@onready var dashEffectTimer = $DashEffectTimer
@onready var joystick = $JoysticMoveCanvasLayer/joystick
@onready var joystick_attack = $JoystickAttackCanvasLayer/JoystickAttack
@onready var dash_touch_button = $SkillsPlayer/DashScreenButton
@onready var dashCooldownTimer = $DashCooldownTimer
@onready var shooting_area = $ShootingArea

# Параметры
@export var max_speed: float = 60
@export var dash_speed_multiplier: float = 2

# Локальные переменные

var acceleration: float = 0.15
var enemies_colliding: int = 0
var can_shoot: bool = true
var doDash: bool = false
var dashDirection: Vector2 = Vector2.ZERO
@export var health_value: float = 25  # Начальное значение здоровья player
var canDash: bool = true
# Обработчик нажатия кнопки для рывка
func _on_dash_screen_button_pressed() -> void:
	perform_dash()

# Определяем направление движения игрока
func movement_vector() -> Vector2:
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var keyboard_direction = Vector2(movement_x, movement_y)

	var joystick_direction = joystick.posVector if joystick else Vector2.ZERO
	if joystick_direction != Vector2.ZERO:
		return joystick_direction.normalized()
	return keyboard_direction.normalized()

# Физический процесс (обновление физики)
func _physics_process(delta):
	var direction = movement_vector().normalized()

	# Логика рывка
	if doDash:
		velocity = dashDirection * max_speed * dash_speed_multiplier
	else:
		if direction != Vector2.ZERO:
			velocity = velocity.lerp(direction * max_speed, acceleration)
		else:
			velocity = velocity.lerp(Vector2.ZERO, acceleration)

	move_and_slide()

	# Управление анимацией
	if direction != Vector2.ZERO:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	if direction.x != 0:
		animated_sprite_2d.flip_h = direction.x < 0

	# Поворот пистолета в сторону мыши
	gun.look_at(get_global_mouse_position())

	# Стрельба при нажатии кнопки
	if Input.is_action_just_pressed("shoot"):
		shoot_bullet()
		can_shoot = false
	# Логика рывка по нажатию кнопки
	if Input.is_action_just_pressed("dash"):
		perform_dash()
	
	# Стрельба с использованием второго джойстика
	if joystick_attack.posVector.length() > 0.1 and can_shoot:
		gun.look_at(global_position + joystick_attack.posVector * 100)
		shoot_bullet()
		can_shoot = false

	# Логика автоматической стрельбы

	shoot_bullet()  # Стреляем


# Завершение рывка
func _on_dash_duration_timer_timeout():
	doDash = false
	dashEffectTimer.stop()

# Создание эффекта рывка
func create_dash_effect():
	var playerCopyNode = animated_sprite_2d.duplicate()
	get_parent().add_child(playerCopyNode)
	playerCopyNode.global_position = global_position

	var animationTime = dashDurationTimer.wait_time / 3
	await get_tree().create_timer(animationTime).timeout
	playerCopyNode.modulate.a = 0.4
	await get_tree().create_timer(animationTime).timeout
	playerCopyNode.modulate.a = 0.2
	await get_tree().create_timer(animationTime).timeout
	playerCopyNode.queue_free()

# Создание эффекта рывка по таймеру
func _on_dash_effect_timer_timeout():
	create_dash_effect()

# Выполнение рывка
func perform_dash():
	if not canDash:  # Проверяем, можно ли использовать рывок
		return

	if movement_vector().length() > 0:
		dashDirection = movement_vector().normalized()
	else:
		dashDirection = Vector2(-1 if animated_sprite_2d.flip_h else 1, 0)

	doDash = true
	canDash = false  # Отключаем возможность рывка
	dashDurationTimer.start()
	dashEffectTimer.start()
	dashCooldownTimer.start()  # Запускаем кулдаун

# Завершение кулдауна рывка
func _on_dash_cooldown_timer_timeout():
	canDash = true  # Возвращаем возможность делать рывок

# Готовность сцены
func _ready():
	# Устанавливаем максимальное и текущее здоровье
	health_component.max_health = health_value
	health_component.current_health = health_value

	health_component.died.connect(on_died)
	health_component.health_changed.connect(on_health_changed)
	Global.ability_upgrade_added.connect(on_ability_upgrade_added)
	health_update()

# Основной процесс
func _process(delta):
	var closest_enemy = get_closest_enemy()
	if closest_enemy:
		gun.look_at(closest_enemy.global_position)

	var direction = movement_vector().normalized()
	var target_velocity = max_speed * direction
	velocity = velocity.lerp(target_velocity, acceleration)
	move_and_slide()

	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

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

# Обработка смерти игрока
func on_died():
	queue_free()

# Обновление здоровья
func on_health_changed():
	health_update()

# Таймер для неуязвимости
func _on_grace_period_timeout():
	check_if_damaged()

# Обработчик улучшений
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade is NewAbility:
		return
	var new_ability = upgrade as NewAbility
	ability_manager.add_child(new_ability.new_ability_scene.instantiate())

# Стрельба
func shoot_bullet():
	var bodies_in_area = shooting_area.get_overlapping_bodies()
	
	for body in bodies_in_area:
		if body.is_in_group("enemy"):
			var direction = (body.global_position - gun.global_position).normalized()
			bullet_ability_controller.spawn_bullet(gun, direction)



# Получение ближайшего врага
func get_closest_enemy() -> Node2D:
	var closest_enemy: Node2D = null
	var min_distance = INF  # Используем бесконечность для первого сравнения

	# Перебираем все узлы в группе "enemies"
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Node2D:
			# Вычисляем расстояние от игрока до врага
			var distance = global_position.distance_to(enemy.global_position)

			# Если этот враг ближе, обновляем ближайшего врага
			if distance < min_distance:
				closest_enemy = enemy
				min_distance = distance

	# Возвращаем ближайшего врага или null, если врагов не найдено
	return closest_enemy
