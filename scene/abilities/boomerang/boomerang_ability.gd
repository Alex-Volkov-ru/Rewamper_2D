extends Node2D
class_name BoomerangAbility

@onready var hit_box_component = $HitBoxComponent

var boomerang_max_radius = 300  # Максимальная дальность полёта
var base_direction = Vector2.RIGHT

func _ready():
	base_direction = base_direction.rotated(randf_range(0, TAU))
	
	var tween = create_tween()
	tween.tween_method(boomerang_animation, 0.0, 2.0, 3.0)  # Фаза полёта вперёд (1.5 сек)
	tween.tween_method(boomerang_animation, 2.0, 0.0, 3.0)  # Фаза возвращения (1.5 сек)
	tween.tween_callback(queue_free)

func boomerang_animation(progress):
	var percent = progress / 2  # От 0 до 1 в первой фазе, от 1 до 0 во второй
	var boomerang_current_radius = percent * boomerang_max_radius
	var boomerang_current_direction = base_direction.rotated(progress * TAU)
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	# Устанавливаем глобальную позицию бумеранга
	global_position = player.global_position + (boomerang_current_direction * boomerang_current_radius)
