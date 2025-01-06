extends Node2D
class_name BulletAbility

@export var speed: float = 400
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent
@onready var area2d = $Area2D

var direction: Vector2
var is_destroyed = false  # Флаг, чтобы отслеживать, уничтожена ли пуля

func _ready():
	direction = Vector2.ZERO
	# Подключаем сигналы через Callable
	area2d.connect("body_entered", Callable(self, "_on_body_entered"))
	area2d.connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	if direction != Vector2.ZERO and !is_destroyed:  # Двигаем пулю только если она не уничтожена
		global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemy"):
		destroy_bullet()

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("enemy"):
		destroy_bullet()

# Функция для уничтожения пули
func destroy_bullet():
	if !is_destroyed:
		is_destroyed = true  # Останавливаем движение пули
		queue_free()  # Удаляем пулю из сцены
