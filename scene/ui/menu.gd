extends Node2D






func _on_texture_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/level/level.tscn")


func _on_texture_talents_pressed() -> void:
	get_tree().change_scene_to_file('res://scene/ui/tallants/talents_menu.tscn')


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file('res://scene/ui/settings/settings.tscn')


func _on_lead_board_pressed() -> void:
	var options

	match Bridge.platform.id:
		"y8":
			options = {
				"table": "leader"
			}

	Bridge.leaderboard.show_native_popup(options, Callable(self, "_on_show_native_popup_completed"))

func _on_show_native_popup_completed(success):
	if success:
		print("Таблица лидеров успешно открыта.")
	else:
		print("Ошибка при открытии таблицы лидеров.")
