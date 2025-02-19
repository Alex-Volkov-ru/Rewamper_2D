extends Control

@onready var title = $Panel/VBoxContainer/Title
@onready var description = $Panel/VBoxContainer/Description
@onready var cost_label = $Panel/VBoxContainer/Cost
@onready var button_yes = $Panel/VBoxContainer/ButtonYes
@onready var button_no = $Panel/VBoxContainer/ButtonNo

var talent_name: String
var current_level: int
var talent_node  # Узел, который вызвал окно

const COST_PER_LEVEL = 100  # Цена улучшения
const MAX_LEVEL = 5  # Максимальный уровень таланта


# Словарь с переводами талантов
var talent_names_rus = {
	"defense": "Защиту",
	"movement": "Скорость передвижения",
	"stamina": "Выносливость"
}
# Функция принимает 3 аргумента
func set_talent_info(name: String, level: int, node):
	talent_name = name
	current_level = level
	talent_node = node  # Сохраняем переданный узел

	# Обновляем текст
	title.text = "Улучшение таланта"
	if current_level >= MAX_LEVEL:
		# Если уровень максимальный, скрываем кнопку и меняем описание
		description.text = "Талант прокачан на максимум!"
		cost_label.text = ""
		button_yes.visible = false
	else:
		# Если уровень не максимальный, показываем стоимость улучшения
		description.text = "Вы хотите улучшить " + talent_names_rus.get(talent_name, talent_name) + "?"
		cost_label.text = "Стоимость: " + str(COST_PER_LEVEL * (current_level + 1)) + " монет"

func _ready():
	button_yes.pressed.connect(_on_confirm)
	button_no.pressed.connect(_on_cancel)

func _on_confirm():
	if current_level < MAX_LEVEL:
		var cost = COST_PER_LEVEL * (current_level + 1)
		if Global.get_coins() >= cost:
			if Global.spend_coins(cost):  # Если покупка прошла успешно
				talent_node.upgrade_talent()  # Улучшаем талант
				queue_free()  # Закрываем окно
		else:
			description.text = "Недостаточно монет!"  # Сообщение игроку

func _on_cancel():
	queue_free()  # Закрываем окно
