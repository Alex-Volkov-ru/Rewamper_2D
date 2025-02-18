extends Label

@onready var experience_manager = $"../../ExperienceManager"  # Укажи правильный путь!

func _ready():
	if experience_manager:
		experience_manager.level_up.connect(_update_level_label)
		_update_level_label(experience_manager.current_level)  # Устанавливаем начальный текст

# Обновляем Label, когда уровень меняется
func _update_level_label(current_level):
	text = "Уровень: " + str(current_level)
