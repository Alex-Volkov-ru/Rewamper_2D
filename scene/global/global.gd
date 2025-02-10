extends Node

signal coin_collected(coin)
signal experience_bottle_collected(experience)
signal hp_bottle_collected(hp)
signal ability_upgrade_added (upgrade: AbilityUpgrade, current_upgrades: Dictionary)

var coin_manager: CoinManager
var talents = {}

func _ready():
	# Загружаем таланты при старте игры
	talents = Save_Manager_Progress.load_talents()

	if get_tree().get_nodes_in_group("CoinManager").is_empty():
		call_deferred("_create_coin_manager")

func get_talent(talent_name: String, default_value: int = 0) -> int:
	return talents.get(talent_name, default_value)

func set_talent(talent_name: String, value: int):
	talents[talent_name] = value
	Save_Manager_Progress.save_talents(talents)

func emit_coin_collected(coin: int):
	coin_collected.emit(coin)

# Отложенная функция для создания и добавления CoinManager
func _create_coin_manager():
	coin_manager = CoinManager.new()
	get_tree().root.add_child(coin_manager)
