extends Node

class_name DropManager

# Сигналы, сообщающие о выпадении награды
signal exp_dropped
signal hp_dropped
signal coin_dropped

# Вероятности выпадения различных наград
@export var exp_drop_percent: float = 0.5
@export var hp_drop_percent: float = 0.1
@export var coin_drop_percent: float = 0.1

@export var health_component: Node  # Компонент здоровья

func _ready():
	# Подключаем обработчик смерти к сигналу компонента здоровья
	(health_component as HealthComponent).died.connect(on_died)

# Вызывается при смерти объекта
func on_died():
	# Проверяем шанс выпадения HP
	if randf() <= hp_drop_percent:
		hp_dropped.emit()
		return

	# Проверяем шанс выпадения EXP
	if randf() <= exp_drop_percent:
		exp_dropped.emit()
		return
	
	# Проверяем шанс выпадения монеты
	if randf() <= coin_drop_percent:
		coin_dropped.emit()
		return
