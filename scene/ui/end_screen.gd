extends CanvasLayer
class_name EndScreen

@onready var name_label = %NameLabel
var has_watched_ad: bool = false  # Флаг, следил ли игрок рекламу

func _ready():
	get_tree().paused = true
	Save_Manager_Progress.check_new_record()
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_state_changed"))

	

func change_to_victory():
	name_label.text = "Победа"

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/level/level.tscn")

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/ui/menu.tscn")

# Когда нажимается кнопка рекламы
func _on_advertising_button_pressed():
	if has_watched_ad:
		return
	Bridge.advertisement.show_rewarded()  # Показываем рекламу

# Когда меняется состояние рекламы
func _on_rewarded_state_changed(state: String):
	if state == "rewarded" and not has_watched_ad:  # Если реклама просмотрена и еще не смотрели
		var coin_manager = Global.coin_manager  # Получаем ссылку на CoinManager
		if coin_manager:
			var bonus_coins = coin_manager.current_coins  # Количество монет за сессию
			coin_manager.current_coins += bonus_coins  # Удваиваем их
			Global.emit_coin_collected(bonus_coins)  # Сообщаем об изменении монет
			has_watched_ad = true  # Запрещаем повторный просмотр
