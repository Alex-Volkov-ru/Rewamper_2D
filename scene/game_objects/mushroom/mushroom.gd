extends CharacterBody2D


@onready var health_component = $HealthComponent
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var movement_component = $MovementComponent
@onready var damage_numbers = get_tree().get_first_node_in_group("damage_layer")  # Узел для отображения урона

@export var death_scecene: PackedScene
@export var sprite: CompressedTexture2D

func _ready():
	health_component.died.connect(on_died)
	health_component.damage_received.connect(on_damage_received)  # Подключаем обработку урона

func _process(delta):
	var direction = movement_component.get_direction()
	movement_component.move_to_player(self)

	if direction.x != 0 || direction.y != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	var face_sign = sign(direction.x)
	if face_sign != 0:
		animated_sprite_2d.scale.x = face_sign

# Обрабатываем отображение урона
func on_damage_received(damage: int, is_critical: bool):
	if damage_numbers:
		# Если урон критический, передаем true
		damage_numbers.display_number(damage, global_position + Vector2(0, -30), is_critical)


# Обработка смерти моба
func on_died():
	var back_layer = get_tree().get_first_node_in_group('back_layer')
	var death_instance = death_scecene.instantiate() as DeathComp
	back_layer.add_child(death_instance)
	death_instance.gpu_particles_2d.texture = sprite
	death_instance.sprite_offset.position.x = animated_sprite_2d.offset.y
	death_instance.global_position = global_position
	queue_free()
