extends Node
class_name HealthComponent

signal died
signal health_changed
signal damage_received(damage: int, is_critical: bool)  # Сигнал для отображения урона

@export var max_health: float = 10
var current_health: float

func _ready():
	current_health = max_health

func take_damage(damage: int):
	var is_critical = false  # Здесь можно добавить механику критического урона
	current_health = max(current_health - damage, 0)

	damage_received.emit(damage, is_critical)  # Отправляем сигнал о получении урона

	health_changed.emit()  # Уведомляем о смене здоровья
	Callable(check_death).call_deferred()

func heal(amount: float):
	current_health = min(current_health + amount, max_health)
	health_changed.emit()

func get_health_value():
	return current_health / max_health

func check_death():
	if current_health == 0:
		died.emit()  # Сигнал о смерти
