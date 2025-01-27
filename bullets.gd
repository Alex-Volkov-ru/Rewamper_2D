extends Area2D

var RIGHT = Vector2.RIGHT  # Обычная переменная
export(int) var SPEED: int = 200


func _physics_process(delta):
	var movement = RIGHT.rotated(rotation) * SPEED * delta
	global_position += movement

func destroy():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Bullet_body_entered(body):
	if body.is_in_group("Player"):
		destroy()
