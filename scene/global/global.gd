extends Node

signal coin_collected(coin)
signal experience_bottle_collected(experience)
signal hp_bottle_collected(hp)
signal ability_upgrade_added (upgrade: AbilityUpgrade, current_upgrades: Dictionary)

var coin_manager: CoinManager
var talents = {}

func _ready():
	# Загружаем сохранённые данные
	Save_Manager_Progress._load_data()  # Добавлено!
	
	# Загружаем таланты
	talents = Save_Manager_Progress.load_talents()
	print("Таланты загружены:", talents)

	# Проверяем, есть ли CoinManager
	if get_tree().get_nodes_in_group("CoinManager").is_empty():
		call_deferred("_create_coin_manager")

func get_talent(talent_name: String, default_value: int = 0) -> int:
	return talents.get(talent_name, default_value)

func set_talent(talent_name: String, value: int):
	talents[talent_name] = value
	Save_Manager_Progress.save_talents(talents)

func emit_coin_collected(coin: int):
	coin_collected.emit(coin)
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
		print("Игра закрывается, сохраняем данные...")
		Save_Manager_Progress.save()
		
