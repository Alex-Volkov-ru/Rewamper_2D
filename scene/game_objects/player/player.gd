extends CharacterBody2D

@onready var health_component = $HealthComponent
@onready var grace_period = $GracePeriod
@onready var progress_bar = $ProgressBar
@onready var ability_manager = $AbilityManager
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var bullet_ability_controller = $AbilityManager/BulletAbilityController
@onready var gun = $Gun
@onready var dashDurationTimer = $DashDurationTimer
@onready var dashEffectTimer = $DashEffectTimer

@export var max_speed = 125  # Максимальная скорость персонажа
@export var dash_speed_multiplier = 2  # Множитель скорости для рывка
var acceleration = 0.15  # Ускорение
var enemies_colliding = 0  # Количество столкновений с врагами

var doDash = false  # Флаг для рывка
var dashDirection = Vector2.ZERO  # Направление рывка

func _physics_process(delta):
	var direction = movement_vector().normalized()  # Получаем нормализованный вектор движения
	
	# Логика рывка
	if doDash:
		velocity = dashDirection * max_speed * dash_speed_multiplier  # Ускорение при рывке
	else:
		if direction != Vector2.ZERO:
			velocity = velocity.lerp(direction * max_speed, acceleration)  # Плавное движение
		else:
			velocity = velocity.lerp(Vector2.ZERO, acceleration)  # Если персонаж стоит, скорость уменьшается плавно

	move_and_slide()  # Движение и обработка коллизий

	# Воспроизведение анимации
	if direction != Vector2.ZERO:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	# Поворот спрайта по направлению движения
	if direction.x != 0:
		animated_sprite_2d.flip_h = direction.x < 0

	# Поворот пистолета в сторону мыши
	gun.look_at(get_global_mouse_position())

	# Если нажата клавиша для рывка (dash)
	if Input.is_action_just_pressed('dash'):
		if direction != Vector2.ZERO:
			dashDirection = direction  # Если персонаж двигается, рывок в сторону движения
		else:
			dashDirection = Vector2(-1 if animated_sprite_2d.flip_h else 1, 0)  # Если стоит, рывок в сторону взгляда
		doDash = true
		dashDurationTimer.start()  # Запуск таймера для рывка
		dashEffectTimer.start()    # Запуск эффекта рывка

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
	playerCopyNode.queue_free()  # Удаляем эффект после завершения

# Завершение рывка
func _on_dash_duration_timer_timeout():
	doDash = false  # Завершаем рывок
	dashEffectTimer.stop()  # Останавливаем эффект

func _on_dash_effect_timer_timeout():
	create_dash_effect()  # Создаем эффект рывка


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
