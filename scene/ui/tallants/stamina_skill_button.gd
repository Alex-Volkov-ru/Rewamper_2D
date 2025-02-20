extends TextureButton
class_name SkillNode

signal skill_upgraded(skill_name: String, level: int)

@onready var panel = $Panel
@onready var label = $MarginContainer/Label

# Загружаем сцену окна покупки
var talent_popup_scene = preload("res://scene/ui/tallants/TalentPopup.tscn")

var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + "/5"

func _ready():
	add_to_group("TalentNode")  # Добавляем узел в группу
	update_talent_ui()  # Загружаем уровень из глобальных данных

func _on_pressed() -> void:
	# Создаём новое окно перед добавлением
	var talent_popup = talent_popup_scene.instantiate()

	# Добавляем в текущую сцену
	get_tree().current_scene.add_child(talent_popup)
	
	# Передаём информацию о таланте
	talent_popup.set_talent_info("stamina", level, self)

# Функция для обновления уровня после покупки
func upgrade_talent():
	level = Global.get_talent("stamina", 0)
	if level < 5:
		level += 1
		Global.set_talent("stamina", level)  # Обновляем уровень таланта
	update_talent_ui()  # Обновляем UI после покупки

	# Разблокировка зависимых умений (если есть)
	for skill in get_children():
		if skill is SkillNode and level == 1:
			skill.disabled = false

	# Отправляем сигнал в Player.gd
	skill_upgraded.emit("stamina", level)

# 🔄 Функция обновления UI (вызывается при сбросе талантов)
func update_talent_ui():
	level = Global.get_talent("stamina", 0)  # Загружаем уровень после сброса
	label.text = str(level) + "/5"
	panel.show_behind_parent = (level > 0)  # Показываем панель, если талант не 0
