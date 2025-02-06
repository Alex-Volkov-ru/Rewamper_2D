extends Node2D

@onready var bullet_ability_controller: Node = $BulletAbilityController  # Ссылка на BulletAbilityController

func spawn_bullet(direction: Vector2):
	if bullet_ability_controller:
		# Спавним пулю с помощью контроллера
		bullet_ability_controller.spawn_bullet(self, direction)
	else:
		print("Ошибка: BulletAbilityController не найден!")
