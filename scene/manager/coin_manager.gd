extends Node
class_name CoinManager

signal coins_updated(current_coins)  # Сигнал обновления монет

var current_coins: int = 0  # Количество монет

# Путь к UI с монетами

func _ready():
	print("Подключаю сигнал coin_collected в CoinManager...")
	if Global.coin_collected.is_connected(on_coin_collected):
		print("Сигнал уже был подключён!")
	else:
		Global.coin_collected.connect(on_coin_collected)
		print("Сигнал coin_collected успешно подключён!")

func on_coin_collected(coin: int):
	print("CoinManager: Получен сигнал. Добавляем монеты:", coin)
	current_coins += coin  # Увеличиваем монеты
	print("Обновлено: текущие монеты:", current_coins)
	coins_updated.emit(current_coins)  # Эмитируем сигнал обновления

# Метод для очистки монет
func clear_coins():
	print("Очистка монет...")
	current_coins = 0  # Обнуляем количество монет
	print("Монеты очищены. Текущий счет:", current_coins)  # Для отладки
	coins_updated.emit(current_coins)  # Эмитируем сигнал с новым значением монет
