extends TextureButton
class_name SpeedSkillNode

signal skill_upgraded(skill_name: String, level: int)

@onready var panel = $Panel
@onready var label = $MarginContainer/Label
@onready var line_2d = $Line2D

func _ready():
	level = Global.get_talent("movement", 0)  # Загружаем уровень таланта
	if get_parent() is SpeedSkillNode:
		line_2d.add_point(global_position + size / 2)
		line_2d.add_point(get_parent().global_position + size / 2)
	
	
var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + '/5'


func _on_pressed() -> void:
	level = min(level + 1, 5)
	Global.set_talent("movement", level)
	panel.show_behind_parent = true
	
	line_2d.default_color = Color(1, 1, 0.24705882370472)
	var skills = get_children()
	for skill in skills:
		if skill is SpeedSkillNode and level == 1:
			skill.disabled = false
	
	# Отправляем сигнал в Player.gd
	skill_upgraded.emit("movement", level)
