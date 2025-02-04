extends Label

@onready var coin_manager = Global.coin_manager  # Получаем ссылку на CoinManager

func _ready():
	# Подключаем сигнал для обновления монет
	coin_manager.connect("coins_updated", Callable(self, "_on_coins_updated"))
	# Устанавливаем начальное значение монет
	_update_gold_label()

# Метод для обновления текста в Label
func _on_coins_updated(current_coins: int):
	_update_gold_label()

# Обновляем текст в Label с количеством монет
func _update_gold_label():
	text = "GOLD: " + str(coin_manager.current_coins)
