extends Node


@export var drop_percent = 0.2
@export var hp_bottle_scene: PackedScene
@export var health_component: Node


func _ready():
	(health_component as HealthComponent).died.connect(on_died)
	
	
func on_died ():
	if randf() < drop_percent:
		return
	
	if hp_bottle_scene == null:
		return
		
	if not owner is Node2D:
		return
		
	var spawn_pos = (owner as Node2D).global_position
	var hp_bottle_instance = hp_bottle_scene.instantiate() as Node2D
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	back_layer.add_child(hp_bottle_instance)
	hp_bottle_instance.global_position = spawn_pos
