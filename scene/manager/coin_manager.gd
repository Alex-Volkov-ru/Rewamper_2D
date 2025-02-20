extends Node
class_name CoinManager

signal coins_updated(current_coins)

var current_coins: int = 0  # Текущее количество монет

func _ready():
	# Подключаем сигнал, если он еще не подключен
	if not Global.coin_collected.is_connected(on_coin_collected):
		Global.coin_collected.connect(on_coin_collected)

# Обработчик сбора монеты
func on_coin_collected(coin: int):
	current_coins += coin  # Увеличиваем количество монет
	coins_updated.emit(current_coins)  # Отправляем обновленное количество монет
	print('Количество монет за сессию ', current_coins)

# Метод для очистки монет (сброс текущего количества монет)
func clear_current_coins():
	current_coins = 0  # Обнуляем текущее количество монет
	coins_updated.emit(current_coins)  # Отправляем обновленное количество монет
