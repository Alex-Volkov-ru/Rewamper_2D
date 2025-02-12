extends TextureButton
class_name SkillNode

signal skill_upgraded(skill_name: String, level: int)

@onready var panel = $Panel
@onready var label = $MarginContainer/Label

func _ready():
	level = Global.get_talent("stamina", 0)  # Загружаем уровень таланта

	
	
var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + '/5'

func _on_pressed() -> void:
	level = min(level + 1, 5)
	Global.set_talent("stamina", level)  # Сохраняем уровень таланта в Global
	panel.show_behind_parent = true

	var skills = get_children()
	for skill in skills:
		if skill is SkillNode and level == 1:
			skill.disabled = false
	
	# Отправляем сигнал в Player.gd
	skill_upgraded.emit("stamina", level)  
