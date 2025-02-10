extends TextureButton
class_name CritSkillNode


@onready var panel = $Panel
@onready var label = $MarginContainer/Label
@onready var line_2d = $Line2D

func _ready():
	if get_parent() is CritSkillNode:
		line_2d.add_point(global_position + size / 2)
		line_2d.add_point(get_parent().global_position + size / 2)
	
	
var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + '/5'


func _on_pressed() -> void:
	level = min(level + 1, 5)
	panel.show_behind_parent = true
	
	line_2d.default_color = Color(1, 1, 0.24705882370472)
	var skills = get_children()
	for skill in skills:
		if skill is CritSkillNode and level == 1:
			skill.disabled = false
