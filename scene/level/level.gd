extends Node

@export var end_screen_scene: PackedScene

@onready var player = %Player

func _ready():
	player.health_component.died.connect(on_died)
	Global.coin_manager.clear_current_coins()  # Очищаем монеты перед стартом уровня

func on_died():
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	add_child(end_screen_instance)
