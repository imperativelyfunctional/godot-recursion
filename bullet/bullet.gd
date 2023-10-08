extends Area2D
class_name Bullet

@export var speed : int = 100
@export var direction: Vector2 = Vector2.ZERO
@export var damage = 1

func _physics_process(delta):
	position += direction * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(_area):
	queue_free()
	EventBus.emit_signal('receive_damages_from_player', damage)
