extends Node

signal coin_collected(coin)  # Сигнал, который будет эмитироваться при сборе монеты
signal experience_bottle_collected(experience)
signal hp_bottle_collected(hp)
signal ability_upgrade_added (upgrade: AbilityUpgrade, current_upgrades: Dictionary)

var coin_manager: CoinManager

func emit_coin_collected(coin: int):
	# Простой способ не проверять сразу. Позволяет избежать проблем с "не видимостью" объекта
	coin_collected.emit(coin)

func _ready():
	if get_tree().get_nodes_in_group("CoinManager").is_empty():
		# Используем call_deferred для того, чтобы добавить CoinManager позже
		call_deferred("_create_coin_manager")
	else:
		print("CoinManager уже существует в дереве!")

# Отложенная функция для создания и добавления CoinManager
func _create_coin_manager():
	coin_manager = CoinManager.new()
	get_tree().root.add_child(coin_manager)
