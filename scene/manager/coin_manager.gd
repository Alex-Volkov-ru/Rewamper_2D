extends Node
class_name CoinManager

signal coins_updated(current_coins)  # Сигнал обновления количества монет

var current_coins: int = 0  # Текущее количество монет

func _ready():
	# Подключаем сигнал сбора монет, если он ещё не подключён
	if not Global.coin_collected.is_connected(on_coin_collected):
		Global.coin_collected.connect(on_coin_collected)

# Обработчик сигнала сбора монеты
func on_coin_collected(coin: int):
	current_coins += coin  # Увеличиваем счётчик монет
	coins_updated.emit(current_coins)  # Отправляем обновлённое значение монет

# Метод для очистки монет
func clear_coins():
	current_coins = 0  # Обнуляем количество монет
	coins_updated.emit(current_coins)  # Сообщаем о сбросе монет
