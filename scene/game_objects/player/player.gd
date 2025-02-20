extends CharacterBody2D


signal skill_upgraded(skill_name: String, level: int)

# Компоненты
@onready var health_component = $HealthComponent
@onready var grace_period = $GracePeriod
@onready var progress_bar = $ProgressBar
@onready var ability_manager = $AbilityManager
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var gun = $Gun
@onready var dashDurationTimer = $DashDurationTimer
@onready var dashEffectTimer = $DashEffectTimer
@onready var joystick = $JoysticMoveCanvasLayer/joystick
@onready var dash_touch_button = $SkillsPlayer/DashScreenButton
@onready var dashCooldownTimer = $DashCooldownTimer
@onready var shooting_area = $ShootingArea

# Параметры
@export var max_speed: float = 60
var base_max_speed: float  # Базовая скорость передвижения
@export var dash_speed_multiplier: float = 2
@export var health_value: float = 100  # Начальное значение здоровья игрока

# Локальные переменные
var acceleration: float = 0.15
var enemies_colliding: int = 0
var can_shoot: bool = true
var doDash: bool = false
var dashDirection: Vector2 = Vector2.ZERO
var canDash: bool = true

# Уровень таланта "Выносливость"
var stamina_talent_level: int = 0
# Таблица бонусов к здоровью (0 - без таланта, 5 - максимальный уровень)
var stamina_health_bonus := [0.0, 0.10, 0.20, 0.30, 0.40, 0.50]

# Уровень таланта "Скорость передвижения"
var movement_talent_level: int = 0
# Таблица бонусов к скорости передвижения (0 - без таланта, 5 - максимальный уровень)
var movement_bonus := [0.0, 0.02, 0.05, 0.10, 0.15, 0.20]
var defense_reduction: float = 0.0 

var defense_talent_level: int = 0
var defense_bonus := [0.0, 0.02, 0.05, 0.10, 0.15, 0.20]

# Новый список оружия
var weapons = []

# Обработчик сигнала улучшения таланта
func _on_skill_upgraded(skill_name: String, level: int):
	if skill_name == "stamina":
		stamina_talent_level = level
		apply_stamina_talent()
	elif skill_name == "movement":
		movement_talent_level = level
		apply_movement_talent()  # Применяем бонус к скорости
	elif skill_name == 'defense':
		defense_talent_level = level
		apply_defense_talent()  # Применяем бонус к скорости

func apply_defense_talent():
	defense_reduction = defense_bonus[defense_talent_level]


func apply_movement_talent():
	var bonus = movement_bonus[movement_talent_level]
	var bonus_speed = base_max_speed * bonus  # Бонус к скорости от базовой скорости
	max_speed = base_max_speed + bonus_speed  # Устанавливаем новую скорость

func apply_stamina_talent():
	var bonus = stamina_health_bonus[stamina_talent_level]
	var bonus_percent = health_value * bonus  # Учитываем базовое здоровье
	health_value += bonus_percent
	health_component.max_health = health_value
	health_component.current_health = health_value

# Добавление оружия в инвентарь игрока
func add_weapon(weapon_scene: PackedScene):
	# Создаем экземпляр оружия
	var weapon_instance = weapon_scene.instantiate()
	
	# Добавляем оружие в инвентарь
	weapons.append(weapon_instance)
	add_child(weapon_instance)

	# Рассчитываем угол для нового оружия, увеличиваем его на 45 градусов за каждый предмет
	var angle = weapons.size() * (PI / 4)  # 45 градусов = PI / 4 радиан

	# Позиционируем оружие по часовой стрелке относительно игрока
	weapon_instance.position = Vector2(cos(angle), sin(angle)) * 30  # 30 - радиус расположения оружия вокруг игрока


# Стрельба всеми оружиями
func shoot_all_weapons():
	for weapon in weapons:
		if weapon.has_method("spawn_bullet"):
			# Получаем ближайшего врага для каждого оружия
			var closest_enemy = get_closest_enemy()
			if closest_enemy:
				var direction = (closest_enemy.global_position - weapon.global_position).normalized()  # Направление к врагу
				weapon.spawn_bullet(direction)  # Спауним пулю в этом направлении

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
		velocity = velocity.lerp(direction * max_speed, acceleration) if direction != Vector2.ZERO else velocity.lerp(Vector2.ZERO, acceleration)

	move_and_slide()

	# Управление анимацией
	if direction != Vector2.ZERO:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	if direction.x != 0:
		animated_sprite_2d.flip_h = direction.x < 0
	
	# Логика рывка по нажатию кнопки
	if Input.is_action_just_pressed("dash"):
		perform_dash()

	# Логика автоматической стрельбы
	shoot_all_weapons()
	shoot_bullet()

	# Поворот оружия в сторону ближайшего врага
	var closest_enemy = get_closest_enemy()
	if closest_enemy:
		for weapon in weapons:
			weapon.look_at(closest_enemy.global_position)  # Поворот оружия в сторону врага

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

	# Определяем направление рывка
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
	base_max_speed = max_speed  # Сохраняем базовую скорость
	stamina_talent_level = Global.get_talent("stamina", 0)  # Загружаем сохраненный уровень
	movement_talent_level = Global.get_talent("movement", 0)
	defense_talent_level = Global.get_talent("defense", 0)
	
	apply_stamina_talent()
	apply_movement_talent()
	apply_defense_talent()

	# Подписываемся на сигнал улучшения таланта
	for skill_node in get_tree().get_nodes_in_group("skills"):
		if skill_node is SkillNode or skill_node is SpeedSkillNode or skill_node is DeffensSkillNode:
			skill_node.skill_upgraded.connect(_on_skill_upgraded)
	
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

	# Управление анимацией
	if direction.x != 0 or direction.y != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

# Обработка повреждений

func check_if_damaged(damage):
	if enemies_colliding == 0 or not grace_period.is_stopped():
		return
	# Применяем уменьшение урона
	var reduced_damage = damage * (1.0 - defense_reduction)
	health_component.take_damage(reduced_damage)
	grace_period.start()

# Обновление здоровья
func health_update():
	progress_bar.value = health_component.get_health_value()

# Обработка столкновений с врагами
func _on_player_hurt_box_area_entered(area):
	var damage = 5
	if area.get_parent().is_in_group("bullet"):
		damage = area.get_parent().hit_box_component.damage
	enemies_colliding += 1
	check_if_damaged(damage)

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
	check_if_damaged(5)

# Обработчик улучшений
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade is NewAbility:
		return
	var new_ability = upgrade as NewAbility
	ability_manager.add_child(new_ability.new_ability_scene.instantiate())

# Стрельба
func shoot_bullet():
	var bodies_in_area = shooting_area.get_overlapping_bodies()  # Получаем все объекты в области
	var enemy_in_area = false  # Переменная для отслеживания, есть ли враг в области

	# Проверяем, есть ли враг среди объектов в области
	for body in bodies_in_area:
		if body.is_in_group("enemy"):  # Проверяем, является ли объект врагом
			enemy_in_area = true
			break  # Прерываем цикл, если нашли врага

	# Если в области есть враг, начинаем стрелять
	if enemy_in_area:
		var closest_enemy = get_closest_enemy()  # Получаем ближайшего врага
		if closest_enemy:
			var direction = (closest_enemy.global_position - gun.global_position).normalized()  # Направление к врагу
			gun.spawn_bullet(direction)  # Спауним пулю

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
