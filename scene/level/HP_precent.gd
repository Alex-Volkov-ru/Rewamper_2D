extends Label



func _process(delta: float) -> void:
	text = "Здоровье: " + str(round(%Player.health_component.current_health))
