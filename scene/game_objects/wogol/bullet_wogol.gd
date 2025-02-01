extends Node2D
class_name BulletWogol

@export var speed: float = 250
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent

var direction: Vector2
var is_destroyed = false  # Флаг, чтобы отслеживать, уничтожена ли пуля
var distance_travelled: float = 0  # Расстояние, которое прошла пуля
var max_distance: float = 200  # Фиксированное расстояние полета пули (200 пикселей)

func _ready():
	direction = Vector2.ZERO
	# Подключаемся к сигналу удара от HitBoxComponent
	hit_box_component.hit.connect(_on_hit)

func _process(delta: float) -> void:
	if direction != Vector2.ZERO and !is_destroyed:  # Двигаем пулю только если она не уничтожена
		# Двигаем пулю
		global_position += direction * speed * delta
		
		# Увеличиваем пройденное расстояние
		distance_travelled += speed * delta
		
		# Проверяем, преодолела ли пуля максимальное расстояние (200 пикселей)
		if distance_travelled >= max_distance:
			destroy_bullet()  # Уничтожаем пулю, если она прошла 200 пикселей

# Обработчик сигнала удара от HitBoxComponent
func _on_hit(damage: float) -> void:
	destroy_bullet()


# Функция для уничтожения пули
func destroy_bullet():
	if !is_destroyed:
		is_destroyed = true  # Останавливаем движение пули
		set_process(false)  # Отключаем обработку движения пули
		hit_box_component.set_deferred("monitoring", false)  # Отключаем обработку столкновений
		queue_free()  # Удаляем пулю из сцены
