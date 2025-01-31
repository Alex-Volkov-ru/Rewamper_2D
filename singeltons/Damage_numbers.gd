extends Node

func _ready():
	add_to_group("damage_layer")  # Добавляем в группу

func display_number(value: int, position: Vector2, is_critical: bool = false):
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 100
	number.label_settings = LabelSettings.new()

	# Загрузка пользовательского шрифта
	var font = load("res://fonts/GreenHillSans-Italic v1.01.ttf")  # Укажи путь к своему шрифту
	number.label_settings.font = font

	# Меняем цвет, если урон критический
	var color = "#FFFFFF"
	if is_critical:
		color = "#FF0000"

	number.label_settings.font_color = color
	number.label_settings.font_size = 15  # Можно увеличить размер
	number.label_settings.outline_color = "#000000"
	number.label_settings.outline_size = 2  # Увеличиваем толщину обводки

	call_deferred('add_child', number)

	# Анимация появления и исчезновения
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 50, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "modulate:a", 0, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)

	await tween.finished
	number.queue_free()
