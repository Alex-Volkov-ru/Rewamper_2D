extends TextureButton
class_name DeffensSkillNode

signal skill_upgraded(skill_name: String, level: int)

@onready var panel = $Panel
@onready var label = $MarginContainer/Label

# Подгружаем сцену окна покупки
@onready var talent_popup = preload("res://scene/ui/tallants/TalentPopup.tscn").instantiate()

var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + "/5"

func _ready():
	level = Global.get_talent("defense", 0)

func _on_pressed() -> void:
	# Создаём новое окно перед добавлением
	var talent_popup = preload("res://scene/ui/tallants/TalentPopup.tscn").instantiate()
	
	# Добавляем в текущую сцену
	get_tree().current_scene.add_child(talent_popup)
	
	# Передаём информацию о таланте
	talent_popup.set_talent_info("defense", level, self)

# Функция для обновления уровня после покупки
func upgrade_talent():
	if level < 5:
		level += 1
		Global.set_talent("defense", level)
		panel.show_behind_parent = true

		# Разблокировка зависимых умений (если есть)
		var skills = get_children()
		for skill in skills:
			if skill is DeffensSkillNode and level == 1:
				skill.disabled = false

		# Отправляем сигнал в Player.gd
		skill_upgraded.emit("defense", level)
