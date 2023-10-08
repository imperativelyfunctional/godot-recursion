extends Node2D

var turret = preload("res://turret/Turret.tscn")

func _ready():
	EventBus.connect('respawn_turret', Callable(self, '_respawn_turret'))
	
func _respawn_turret(pos: Vector2):
	var t : Turret = turret.instantiate()
	t.position = pos
	add_child(t)
