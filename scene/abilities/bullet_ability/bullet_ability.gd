extends Node2D
class_name BulletAbility

@export var speed: float = 400
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent

var direction: Vector2

func _ready():
	direction = Vector2.ZERO

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta
