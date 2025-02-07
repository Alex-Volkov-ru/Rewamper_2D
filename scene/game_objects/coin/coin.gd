extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@export var coin = 1  # Количество монет, которые даёт эта монета

# Анимация движения монеты к игроку
func tween_coin(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null:
		return

	# Интерполяция позиции монеты к игроку
	global_position = start_position.lerp(player.global_position, percent)
	
	# Плавное вращение монеты в направлении игрока
	var direction = player.global_position - start_position
	var direction_degrees = rad_to_deg(direction.angle())
	rotation = lerp_angle(rotation, direction_degrees, 0.05)

# Обработчик сбора монеты
func coin_collected():
	Global.emit_coin_collected(coin)  # Отправляем сигнал в Global
	queue_free()  # Удаляем монету

# Отключение коллизии монеты
func disable_collision():
	collision_shape_2d.disabled = true

# Обработчик входа в зону Area2D
func _on_area_2d_area_entered(area):
	Callable(disable_collision).call_deferred()
	var rng = randi_range(20, 40)
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null:
		return
	var away_point = global_position + (global_position - player.global_position)\
	.normalized() * rng
	var tween_out = create_tween()
	tween_out.tween_property(self, "global_position", away_point, 0.4)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	
	await tween_out.finished
	
	# Создаём анимацию движения монеты к игроку
	var tween = create_tween()
	tween.tween_method(tween_coin.bind(global_position), 0.0, 1.0, 0.5)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
	
	# Удаляем монету после завершения анимации
	tween.tween_callback(coin_collected)
