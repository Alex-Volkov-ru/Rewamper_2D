extends Control

@onready var title = $Panel/VBoxContainer/Title
@onready var description = $Panel/VBoxContainer/Description
@onready var cost_label = $Panel/VBoxContainer/Cost
@onready var button_yes = $Panel/VBoxContainer/ButtonYes
@onready var button_no = $Panel/VBoxContainer/ButtonNo

var talent_name: String
var current_level: int
var talent_node  # Узел, который вызвал окно

const COSTS = [50, 200, 400, 600, 1000]  # Стоимость улучшения для каждого уровня
const MAX_LEVEL = 5  # Максимальный уровень таланта

# Словарь с русскими названиями талантов
var talent_names_rus = {
	"defense": "Защиту",
	"movement": "Скорость передвижения",
	"stamina": "Выносливость",
	"regen": "Регенерация"
}

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
		# Получаем стоимость улучшения с учетом уровня
		var cost = COSTS[current_level]  # Берем стоимость из массива по индексу уровня
		description.text = "Вы хотите улучшить " + talent_names_rus.get(talent_name, talent_name) + "?"
		cost_label.text = "Стоимость: " + str(cost) + " монет"

func _ready():
	button_yes.pressed.connect(_on_confirm)
	button_no.pressed.connect(_on_cancel)

func _on_confirm():
	if current_level < MAX_LEVEL:
		var cost = COSTS[current_level]  # Берем соответствующую стоимость улучшения
		if Global.get_coins() >= cost:
			if Global.spend_coins(cost):  # Если покупка прошла успешно
				talent_node.upgrade_talent()  # Улучшаем талант
				queue_free()  # Закрываем окно
		else:
			description.text = "Недостаточно монет!"  # Сообщение игроку

func _on_cancel():
	queue_free()  # Закрываем окно
