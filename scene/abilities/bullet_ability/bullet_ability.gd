extends Node2D
class_name BulletAbility

@export var speed: float = 400
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent
@onready var area2d = $Area2D

var direction: Vector2

func _ready():
	direction = Vector2.ZERO

	# Подключаем сигналы через Callable
	area2d.connect("body_entered", Callable(self, "_on_body_entered"))
	area2d.connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	# Если столкновение с врагом
	if area.get_parent().is_in_group("enemy"):
		queue_free()

func _on_body_entered(body: PhysicsBody2D) -> void:
	# Если столкновение с врагом
	if body.is_in_group("enemy"):
		queue_free()
