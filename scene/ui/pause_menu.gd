extends Control

@onready var resume_button = $PanelContainer/VBoxContainer/Resume
@onready var quit_button = $PanelContainer/VBoxContainer/Quit
@onready var menu_button = $"../MenuRight"

func _ready():
	# Прячем меню при старте
	visible = false
	
	# Подключаем кнопки к методам
	resume_button.pressed.connect(_on_resume_pressed)

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		toggle_pause()

func toggle_pause():
	visible = !visible
	get_tree().paused = visible  # Ставим/снимаем паузу
	menu_button.visible = !menu_button.visible  # Включаем/выключаем кнопку Menu

func _on_resume_pressed():
	toggle_pause()  # Просто закрываем меню и снимаем паузу

func _on_quit_pressed():
	get_tree().paused = false  # Снимаем паузу перед выходом
	get_tree().change_scene_to_file("res://scene/ui/menu.tscn")  # Загружаем меню


func _on_menu_right_pressed() -> void:
	visible = !visible
	get_tree().paused = visible



func _on_menu_pressed() -> void:
	visible = true
	menu_button.visible = false
	get_tree().paused = true
