extends Node2D


func _on_texture_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/level/level.tscn")

func _on_texture_talents_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/ui/tallants/talents_menu.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/ui/settings/settings.tscn")
