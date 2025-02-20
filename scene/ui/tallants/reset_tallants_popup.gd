extends Control

@onready var label_question: Label = $Panel/VBoxContainer/Cost
@onready var button_yes: Button = $Panel/VBoxContainer/ButtonYes
@onready var button_no: Button = $Panel/VBoxContainer/ButtonNo
@onready var blocking_panel: PanelContainer = $BlockingPanel  # Блокирующая панель

func _ready():
	# Проверяем, что все элементы корректно подключены
	if label_question == null:
		print("Не удалось найти label_question!")
	if button_yes == null:
		print("Не удалось найти button_yes!")
	if button_no == null:
		print("Не удалось найти button_no!")

	# Изначально блокирующая панель скрыта
	blocking_panel.visible = false
	blocking_panel.mouse_filter = MOUSE_FILTER_STOP  # Ожидаем блокировку кликов

# Метод для показа окна подтверждения
func show_popup():
	if label_question:
		label_question.text = "Вы уверены, что хотите сбросить таланты?"
	if button_yes:
		button_yes.pressed.connect(_on_yes_pressed)
	if button_no:
		button_no.pressed.connect(_on_no_pressed)

	self.visible = true  # Показываем окно
	blocking_panel.visible = true  # Показываем блокирующую панель
	blocking_panel.mouse_filter = MOUSE_FILTER_PASS  # Блокируем ввод на остальные элементы интерфейса

func _on_yes_pressed():
	Global.reset_talents()  # Сбрасываем таланты
	_queue_free()  # Закрываем окно

func _on_no_pressed():
	_queue_free()  # Закрываем окно

# Метод для скрытия окна и разблокировки интерфейса
func _queue_free():
	self.visible = false
	blocking_panel.visible = false  # Скрываем блокирующую панель
	blocking_panel.mouse_filter = MOUSE_FILTER_STOP  # Снимаем блокировку с интерфейса

	# Отключаем соединения с кнопками
	if button_yes:
		button_yes.pressed.disconnect(_on_yes_pressed)
	if button_no:
		button_no.pressed.disconnect(_on_no_pressed)
