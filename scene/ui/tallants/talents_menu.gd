extends Control

@onready var gold_label: Label = $CountLabel  # Получаем ссылку на Label, который показывает монеты


func _on_texture_quit_pressed() -> void:
	get_tree().change_scene_to_file('res://scene/ui/menu.tscn')


func _ready():
	# Получаем общее количество монет из сохранённых данных
	var total_coins = Save_Manager_Progress.save_data.get("coins", 0)
	
	# Устанавливаем текст в Label
	gold_label.text = "Общее количество монет: " + str(total_coins)
