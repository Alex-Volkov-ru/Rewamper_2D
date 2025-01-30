extends Sprite2D

@onready var parent_button = $".."
var pressing = false

@export var max_length = 50  # Максимальное расстояние, на которое может двигаться джойстик
var deadzone = 15  # Радиус мертвой зоны, где джойстик не будет двигаться

func _ready():
	# Устанавливаем начальные значения
	deadzone = parent_button.rect_min_size.x / 4
	max_length = parent_button.rect_min_size.x / 2

func _process(delta):
	if pressing:
		# Получаем текущую позицию касания
		var touch_pos = get_global_mouse_position()
		if touch_pos.distance_to(parent_button.global_position) <= max_length:
			global_position = touch_pos
		else:
			var angle = parent_button.global_position.angle_to_point(touch_pos)
			global_position.x = parent_button.global_position.x + cos(angle) * max_length
			global_position.y = parent_button.global_position.y + sin(angle) * max_length
		calculate_vector()
	else:
		global_position = lerp(global_position, parent_button.global_position, delta * 10)

# Функция для расчета вектора перемещения
func calculate_vector():
	if global_position.distance_to(parent_button.global_position) >= deadzone:
		var direction = (global_position - parent_button.global_position).normalized()
		parent_button.pos_vector = direction * (global_position.distance_to(parent_button.global_position) / max_length)
	else:
		parent_button.pos_vector = Vector2.ZERO

func _on_button_pressed():
	pressing = true

func _on_button_released():
	pressing = false
