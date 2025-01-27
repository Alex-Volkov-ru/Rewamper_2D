extends Node2D
class_name BulletWogol

@export var speed: float = 250
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent
@onready var area2d = $Area2D

var direction: Vector2
var is_destroyed = false  # Флаг, чтобы отслеживать, уничтожена ли пуля
var distance_travelled: float = 0  # Расстояние, которое прошла пуля
var max_distance: float = 200  # Фиксированное расстояние полета пули (200 пикселей)


func _ready():
	direction = Vector2.ZERO
	# Подключаем сигналы через Callable
	area2d.connect("body_entered", Callable(self, "_on_body_entered"))
	area2d.connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	if direction != Vector2.ZERO and !is_destroyed:  # Двигаем пулю только если она не уничтожена
		# Двигаем пулю
		global_position += direction * speed * delta
		
		# Увеличиваем пройденное расстояние
		distance_travelled += speed * delta
		
		# Проверяем, преодолела ли пуля максимальное расстояние (200 пикселей)
		if distance_travelled >= max_distance:
			destroy_bullet()  # Уничтожаем пулю, если она прошла 200 пикселей

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		destroy_bullet()

func _on_body_entered(body: PhysicsBody2D) -> void:
	# Проверяем, является ли объект врагом
	if body.is_in_group("player"):
		var health_component = body.get_node("HealthComponent") if body.has_node("HealthComponent") else null
		if health_component != null and health_component.current_health > 0:
			# Наносим урон, если здоровье больше 0
			health_component.take_damage(hit_box_component.damage)
			destroy_bullet()  # Уничтожаем пулю

# Функция для уничтожения пули
func destroy_bullet():
	if !is_destroyed:
		is_destroyed = true  # Останавливаем движение пули
		queue_free()  # Удаляем пулю из сцены
