extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@export var coin = 1  # Количество монет

func tween_coin(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group('player') as Node2D
	if player == null:
		return
		
	global_position = start_position.lerp(player.global_position, percent)
	
	var direction = player.global_position - start_position
	var direction_degrees = rad_to_deg(direction.angle())
	
	rotation = lerp_angle(rotation, direction_degrees, 0.05)

func coin_collected():
	print("Монета подобрана, передаю сигнал на увеличение монет.")
	Global.emit_coin_collected(coin)  # Отправляем сигнал в Global
	queue_free()  # Удаляем монету

func disable_collision():
	collision_shape_2d.disabled = true


func _on_area_2d_area_entered(area):
	Callable(disable_collision).call_deferred()
	var tween = create_tween()
	tween.tween_method(tween_coin.bind(global_position), 0.0, 1.0, 0.5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_callback(coin_collected)
