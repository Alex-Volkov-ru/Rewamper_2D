extends Node
class_name HpManager

@onready var player_health_component: HealthComponent = null

func _ready():
	# Находим игрока и его компонент здоровья
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_health_component = player.get_node_or_null("HealthComponent")

	# Подключаем обработчик сигнала сбора колбы здоровья
	Global.hp_bottle_collected.connect(on_hp_bottle_collected)

func on_hp_bottle_collected(hp):
	if player_health_component:
		player_health_component.heal(hp)  # Восстанавливаем здоровье игрока
