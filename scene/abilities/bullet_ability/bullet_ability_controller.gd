extends Node

@export var bullet_ability_scene: PackedScene
var damage = 2


func _ready():
	Global.ability_upgrade_added.connect(on_upgrade_added)
	
# Вызывается для выстрела
func spawn_bullet(gun: Node2D):
	# Проверяем входные данные
	if gun == null:
		print("Ошибка: GUN не передан!")
		return

	# Проверяем наличие сцены пули
	if bullet_ability_scene == null:
		print("Ошибка: bullet_ability_scene не задан!")
		return

	var front_layer = get_tree().get_first_node_in_group('front_layer') as Node2D
	if front_layer == null:
		print("Ошибка: Front Layer не найден!")
		return

	# Создаём экземпляр пули
	var bullet_instance = bullet_ability_scene.instantiate() as BulletAbility
	front_layer.add_child(bullet_instance)

	# Устанавливаем начальную позицию пули из GUN
	bullet_instance.global_position = gun.global_position

	# Рассчитываем направление от GUN к мыши
	var mouse_position = gun.get_global_mouse_position()
	var direction = (mouse_position - gun.global_position).normalized()

	# Устанавливаем направление и урон
	bullet_instance.direction = direction
	bullet_instance.hit_box_component.damage = damage

func on_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "gun_attack":  # Проверяем, что улучшение связано с пулями
		var upgrade_amount = current_upgrades["gun_attack"]["quantity"]
		damage += 5  # Увеличиваем урон на 5 с каждым апгрейдом
		#print("Урон пули увеличен до:", damage)
