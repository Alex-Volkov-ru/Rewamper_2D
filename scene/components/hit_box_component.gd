extends Area2D
class_name HitBoxComponent

signal hit(damage: int)  # Сигнал для отслеживания попаданий

var damage: int = 0  # Урон, который будет нанесён

# Установить урон для этой области
func set_damage(amount: int):
	damage = amount

func _ready():
	body_entered.connect(_on_body_entered)  # Подключаем событие столкновения

# Когда объект входит в область
func _on_body_entered(body):
	if body.has_method("take_damage"):  # Проверяем, есть ли метод take_damage()
		body.take_damage(damage)  # Наносим урон
		hit.emit(damage)  # Сигнал о попадании
