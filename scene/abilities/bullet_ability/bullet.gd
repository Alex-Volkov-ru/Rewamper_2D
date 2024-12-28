extends Area2D

@export var speed: float = 500  # Скорость полёта пули
var direction: Vector2 = Vector2.ZERO  # Направление движения пули

func _ready():
	if direction == Vector2.ZERO:
		return

func _process(delta):
	position += direction * speed * delta
	#if not get_viewport().get_visible_rect().has_point(global_position):
		#queue_free()
