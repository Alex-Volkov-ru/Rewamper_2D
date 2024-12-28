extends Node2D
class_name BulletAbility

@onready var hit_box_component: HitBoxComponent = $HitBoxComponent

@export var speed: float = 500  # Скорость пули
var direction: Vector2 = Vector2.ZERO  # Направление пули

func _ready():
	# Рассчитываем направление от текущей позиции до позиции мыши
	var mouse_position = get_global_mouse_position()
	direction = (mouse_position - global_position).normalized()

	# Настраиваем урон пули
	if hit_box_component:
		hit_box_component.damage = 10

func _process(delta):
	# Двигаем пулю в рассчитанном направлении
	position += direction * speed * delta

	# Если пуля выходит за пределы экрана, удаляем её
	if not get_viewport().get_visible_rect().has_point(global_position):
		queue_free()
