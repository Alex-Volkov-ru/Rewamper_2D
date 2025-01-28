extends Node

class_name DropManager

signal exp_dropped
signal hp_dropped



@export var exp_drop_percent = 0.5
@export var hp_drop_percent = 0.2

@export var health_component: Node

var drop_value = 0

func _ready():
	(health_component as HealthComponent).died.connect(on_died)


func on_died ():
	
	drop_value = randf()
	if drop_value <= hp_drop_percent:
		hp_dropped.emit()

		return

	drop_value = randf()
	if drop_value <= exp_drop_percent:
		exp_dropped.emit()
		return
	
