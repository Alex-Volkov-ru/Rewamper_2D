extends Control


func _on_TextureButton_pressed():
	# Ищем игрока в родительской сцене
	var player = get_parent().get_parent()
	if player and player.has_method("perform_dash"):
		player.perform_dash()  # Вызываем рывок
