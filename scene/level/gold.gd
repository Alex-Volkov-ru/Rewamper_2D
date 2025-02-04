extends Label



func _process(delta: float) -> void:
	text = "GOLD: " + str(round(%Player.health_component.current_health))
