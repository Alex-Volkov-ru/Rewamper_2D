extends Control

var talent_name = ""
var talent_level = 0
var upgrade_cost = 0

func setup(name, level, cost):
	talent_name = name
	talent_level = level
	upgrade_cost = cost
	$Panel/VBoxContainer/Label.text = "Вы уверены, что хотите улучшить " + name + " за " + str(cost) + " монет?"

func _on_yes_pressed():
	if Global.get_talent("coins") >= upgrade_cost:
		Global.set_talent(talent_name, talent_level + 1)
		Global.set_talent("coins", Global.get_talent("coins") - upgrade_cost)
	else:
		print("Недостаточно монет!")

	queue_free()  # Закрываем окно

func _on_no_pressed():
	queue_free()  # Просто закрываем
