extends Area2D

@export var speed = 300  # Скорость пули

func _process(delta):
	position += Vector2(cos(rotation), sin(rotation)) * speed * delta
