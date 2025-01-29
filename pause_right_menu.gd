extends Control

@onready var menu_button = $PanelContainer/VBoxContainer/MENU

func _ready():
	# Подключаем кнопку к методу
	menu_button.pressed.connect(_on_menu_pressed)

func _on_menu_pressed():
	# Ищем существующую ноду PauseMenu в сцене
	var pause_menu = get_node_or_null("/root/lvl/CanvasLayer/PauseMenu")
	
	if pause_menu:
		pause_menu.toggle_pause()  # Открываем или закрываем меню
