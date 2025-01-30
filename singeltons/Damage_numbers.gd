extends Node

func _ready():
	add_to_group("damage_layer")  # Добавляем в группу

func display_number(value: int, position: Vector2, is_critical: bool = false):
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 100  # Проверим, что число будет поверх всех объектов
	number.label_settings = LabelSettings.new()

	# Настройка цвета для критического урона
	var color = '#FFF'
	if is_critical:
		color = '#B22'  # Красный для критического
	if value == 0:
		color = '#FFF8'  # Бледный для нулевого урона

	number.label_settings.font_color = color
	number.label_settings.font_size = 18
	number.label_settings.outline_color = '#000'
	number.label_settings.outline_size = 1
	
	call_deferred('add_child', number)  # Добавляем метку с числом урона в сцену

	await number.resized  # Ждём, пока размер метки изменится
	number.pivot_offset = Vector2(number.size / 2)  # Центрируем метку

	# Создаём анимацию
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, 'position:y', number.position.y - 50, 0.5).set_ease(Tween.EASE_OUT)  # Увеличиваем время подъёма
	tween.tween_property(number, 'position:y', number.position.y, 1.0).set_ease(Tween.EASE_IN).set_delay(0.25)  # Делаем анимацию медленной
	tween.tween_property(number, 'scale', Vector2.ZERO, 0.5).set_ease(Tween.EASE_OUT).set_delay(0.25)  # Увеличиваем время исчезновения

	await tween.finished  # Ждём окончания анимации
	number.queue_free()  # Удаляем метку после анимации
