extends Label



func _process(delta: float) -> void:
	text = "HP: " + str(round(%Player.health_component.current_health))
