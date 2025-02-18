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

# Функция принимает 3 аргумента
func set_talent_info(name: String, level: int, node):
	talent_name = name
	current_level = level
	talent_node = node  # Сохраняем переданный узел

	# Обновляем текст
	title.text = "Улучшение таланта"
	description.text = "Вы хотите улучшить " + talent_name + "?"
	cost_label.text = "Стоимость: " + str(COST_PER_LEVEL * (level + 1)) + " монет"

func _ready():
	button_yes.pressed.connect(_on_confirm)
	button_no.pressed.connect(_on_cancel)

func _on_confirm():
	var cost = COST_PER_LEVEL * (current_level + 1)
	if Global.get_coins() >= cost:
		if Global.spend_coins(cost):  # Если покупка прошла успешно
			talent_node.upgrade_talent()  # Улучшаем талант
			queue_free()  # Закрываем окно
	else:
		description.text = "Недостаточно монет!"  # Сообщение игроку


func _on_cancel():
	queue_free()  # Закрываем окно
