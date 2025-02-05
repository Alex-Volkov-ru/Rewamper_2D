extends Node

@export var coin_scene: PackedScene  # Префаб (сцена) монеты
@export var drop_component: Node  # Компонент, отвечающий за дроп предметов

func _ready():
	# Подключаем сигнал выпадения монеты
	(drop_component as DropManager).coin_dropped.connect(on_drop)

# Обработчик выпадения монеты
func on_drop():
	# Проверяем, задана ли сцена монеты
	if coin_scene == null:
		return

	# Проверяем, есть ли у текущего узла родитель типа Node2D
	if not owner is Node2D:
		return

	# Определяем позицию спавна
	var spawn_pos = (owner as Node2D).global_position
	
	# Создаём экземпляр монеты
	var coin_instance = coin_scene.instantiate() as Node2D
	
	# Находим слой заднего плана для размещения монеты
	var back_layer = get_tree().get_first_node_in_group("back_layer")
	if back_layer == null:
		return  # Предотвращаем ошибку, если слой не найден
	
	# Добавляем монету в слой заднего плана
	back_layer.add_child(coin_instance)
	
	# Устанавливаем позицию монеты
	coin_instance.global_position = spawn_pos
