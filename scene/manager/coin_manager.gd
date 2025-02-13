extends Node
class_name CoinManager

signal coins_updated(current_coins)

var current_coins: int = 0  # Текущее количество монет

func _ready():
	# Подключаем сигнал, если он еще не подключен
	if not Global.coin_collected.is_connected(on_coin_collected):
		Global.coin_collected.connect(on_coin_collected)
	
	# Логируем, чтобы убедиться, что CoinManager загружен
	print("CoinManager готов")

# Обработчик сбора монеты
func on_coin_collected(coin: int):
	print("Собрана монета:", coin)  # Логируем, сколько монет собрано
	current_coins += coin  # Увеличиваем количество монет
	print("Текущее количество монет:", current_coins)  # Логируем текущие монеты
	coins_updated.emit(current_coins)  # Отправляем обновленное количество монет

# Метод для очистки монет (сброс текущего количества монет)
func clear_current_coins():
	print("Монеты очищаются!")  # Логируем этот момент
	current_coins = 0  # Обнуляем текущее количество монет
	print("Текущее количество монет после очистки:", current_coins)  # Логируем после очистки
	coins_updated.emit(current_coins)  # Отправляем обновленное количество монет
