extends Control

@onready var gold_label: Label = $CountLabel  # Получаем ссылку на Label, который показывает монеты
@onready var reset_talents: TextureButton = $ResetTalents
var reset_talents_popup = preload('res://scene/ui/tallants/ResetTallantsPopup.tscn')  # Загружаем сцену, а не скрипт
@onready var blocking_panel: Panel = $BlockingPanel

# Функция для обновления монет в интерфейсе
func update_coin_display():
	var total_coins = Save_Manager_Progress.save_data.get("coins", 0)
	gold_label.text = "Общее количество монет: " + str(total_coins)

func _ready():
	# Получаем общее количество монет из сохранённых данных
	update_coin_display()  # Инициализируем отображение монет

	# Подписываемся на сигнал обновления монет
	Global.coin_collected.connect(_on_coin_collected)

func _on_coin_collected(amount: int):
	# Обновляем текст в Label с новым количеством монет
	update_coin_display()

func _on_texture_quit_pressed() -> void:
	get_tree().change_scene_to_file('res://scene/ui/menu.tscn')

# Отписка от сигнала при выходе из сцены
func _exit_tree():
	Global.coin_collected.disconnect(_on_coin_collected)

func _on_reset_talents_pressed() -> void:
	# Создаём экземпляр окна подтверждения
	var popup_instance = reset_talents_popup.instantiate()  # Используем instantiate вместо instance
	add_child(popup_instance)  # Добавляем в текущую сцену
	popup_instance.show_popup()  # Показываем окно
