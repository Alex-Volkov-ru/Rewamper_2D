extends Control

@onready var resume_button = $PanelContainer/VBoxContainer/Resume
@onready var quit_button = $PanelContainer/VBoxContainer/Quit
@onready var menu_button = $"../MenuRight"  # Эта кнопка открывает меню паузы
@onready var background_music: AudioStreamPlayer = $AudioStreamPlayer

var is_music_playing = false
var was_music_playing_before_pause = false  # Для отслеживания состояния музыки до паузы

func _ready():
	# Прячем меню при старте
	visible = false
	
	# Подключаем кнопки к методам, если они ещё не подключены
	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)

	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

	if not menu_button.pressed.is_connected(_on_menu_pressed):
		menu_button.pressed.connect(_on_menu_pressed)

	# Запоминаем текущее состояние музыки
	is_music_playing = background_music.playing
	
func _process(_delta):
	# Открытие меню при нажатии Esc
	if Input.is_action_just_pressed("ui_cancel"):  # Это действие для клавиши ESC
		toggle_pause()

func toggle_pause():
	visible = !visible
	get_tree().paused = visible  # Ставим/снимаем паузу
	menu_button.visible = !menu_button.visible  # Включаем/выключаем кнопку Menu
	
	# Остановка/включение фоновой музыки при паузе
	if visible:  # Когда показываем меню паузы
		if not background_music.playing:
			background_music.play()  # Включаем музыку, если она не играет
		was_music_playing_before_pause = is_music_playing  # Запоминаем текущее состояние музыки
	else:  # Когда скрываем меню
		if background_music.playing:
			background_music.stop()  # Останавливаем музыку
		# Восстановление музыки, если она играла до паузы
		if was_music_playing_before_pause:
			background_music.play()

func _on_resume_pressed():
	toggle_pause()  # Просто закрываем меню и снимаем паузу

func _on_quit_pressed():
	get_tree().paused = false  # Снимаем паузу перед выходом
	get_tree().change_scene_to_file("res://scene/ui/menu.tscn")  # Загружаем меню

func _on_menu_pressed() -> void:
	# Эта кнопка открывает меню паузы
	visible = !visible
	get_tree().paused = visible
	
	# Включаем музыку при нажатии кнопки Menu
	if not background_music.playing:
		background_music.play()
