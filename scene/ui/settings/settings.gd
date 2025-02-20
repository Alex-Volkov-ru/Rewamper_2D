extends Control


func _on_texture_quit_pressed() -> void:
	get_tree().change_scene_to_file('res://scene/ui/menu.tscn')
