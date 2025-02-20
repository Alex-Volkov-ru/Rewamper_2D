extends Node

signal coin_collected(coin)  # Сигнал для изменения монет
signal experience_bottle_collected(experience)
signal hp_bottle_collected(hp)
signal ability_upgrade_added (upgrade: AbilityUpgrade, current_upgrades: Dictionary)

var coin_manager: CoinManager
var talents = {}
const COSTS = [50, 200, 400, 600, 1000]  # Стоимость улучшения для каждого уровня
const MAX_LEVEL = 5  # Максимальный уровень таланта

func _ready():
	Bridge.platform.send_message("game_ready")
	Bridge.advertisement.show_interstitial()
	Bridge.game.connect("visibility_state_changed", Callable(self, "_on_visibility_state_changed"))
	# Загружаем сохранённые данные
	Save_Manager_Progress._load_data()  # Добавлено!
	
	# Загружаем таланты
	talents = Save_Manager_Progress.load_talents()

	# Проверяем, есть ли CoinManager
	if get_tree().get_nodes_in_group("CoinManager").is_empty():
		call_deferred("_create_coin_manager")

func _on_visibility_state_changed(state):
	if state == "hidden":  # Если состояние "hidden", выключаем музыку
		AudioServer.set_bus_mute(0, true)
	else:  # Если любое другое состояние, включаем
		AudioServer.set_bus_mute(0, false)

func get_talent(talent_name: String, default_value: int = 0) -> int:
	return talents.get(talent_name, default_value)

func set_talent(talent_name: String, value: int):
	talents[talent_name] = value
	Save_Manager_Progress.save_talents(talents)

func emit_coin_collected(coin: int):
	coin_collected.emit(coin)  # Испускаем сигнал
	# Сохраняем монеты при сборе
	Save_Manager_Progress.save_data["coins"] += coin
	Save_Manager_Progress.save()

# Отложенная функция для создания и добавления CoinManager
func _create_coin_manager():
	coin_manager = CoinManager.new()
	get_tree().root.add_child(coin_manager)

# Сохраняем при выходе
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Save_Manager_Progress.save()

func get_coins() -> int:
	return Save_Manager_Progress.save_data.get("coins", 0)

func spend_coins(amount: int) -> bool:
	var current_coins = get_coins()
	if current_coins >= amount:
		Save_Manager_Progress.save_data["coins"] -= amount
		Save_Manager_Progress.save()
		coin_collected.emit(-amount)  # Испускаем сигнал при потере монет
		return true  # Покупка успешна
	return false  # Недостаточно монет

func update_all_talents():
	var talent_nodes = get_tree().get_nodes_in_group("TalentNode")  # Получаем все узлы талантов
	for talent_node in talent_nodes:
		talent_node.update_talent_ui()  # Вызываем у них обновление UI
		
func reset_talents() -> void:
	var total_refunded_coins = 0  # Сумма монет, которые будут возвращены

	# Пройдем по всем талантам и вычислим потраченные монеты
	for talent_name in talents.keys():
		var talent_level = talents[talent_name]
		if talent_level > 0:  # Если талант был улучшен
			# Здесь мы правильно вычисляем стоимость на основе уровня таланта
			for i in range(talent_level):  # Суммируем все улучшения до текущего уровня
				total_refunded_coins += COSTS[i]  # Добавляем стоимость для каждого уровня

	# Сбрасываем все таланты
	for talent_name in talents.keys():
		talents[talent_name] = 0  

	Save_Manager_Progress.save_talents(talents)

	# Возвращаем монеты игроку
	Save_Manager_Progress.save_data["coins"] += total_refunded_coins
	Save_Manager_Progress.save()  # Сохраняем изменения

	# Обновляем UI для всех TalentNode
	for node in get_tree().get_nodes_in_group("TalentNode"):
		if node.has_method("update_talent_ui"):
			node.update_talent_ui()

	# Отправляем сигнал, если нужно
	coin_collected.emit(total_refunded_coins)
