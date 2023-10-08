extends Sprite2D
class_name Turret
 
@export var health = 10
var _rectangles = []
var sprite_data = []
var _dead = false
@onready var hit_box = $HitBox
@onready var explosion = $Sprite2D
@onready var explosion_player = $AnimationPlayer
@onready var shader = preload("res://main/vanishing.gdshader")
var gravity = ProjectSettings.get_setting('physics/2d/default_gravity')
func _ready():
	EventBus.connect('receive_damages_from_player', Callable(self, '_receive_damanges'))
	_divide_rectangle(Rect2(Vector2.ZERO, texture.get_size()))
	
func _receive_damanges(damages: int):
	health -= damages
	if health <= 0 && !_dead:
		explosion.visible = true
		explosion_player.play("explosion")
		_dead = true

func _on_animation_player_animation_finished(_anim_name):
	remove_child(hit_box)
	visible = false
	var max_time = 0
	for rect in _rectangles:
		var new_sprite = Sprite2D.new()
		new_sprite.texture = texture
		new_sprite.region_enabled = true
		new_sprite.region_rect = rect
		new_sprite.top_level = true
		
		var y_velocity = clamp(randf() * gravity * 0.1, 10, 100)
		var removal_time = randf() * 6
		max_time = max(max_time, removal_time)
		var shader_material = ShaderMaterial.new()
		shader_material.set_shader_parameter("time_to_fade", removal_time)
		shader_material.shader = shader

		new_sprite.material = shader_material
		
		new_sprite.position = position - texture.get_size()/2 + rect.position + (rect.size / 2)
		get_tree().root.add_child(new_sprite)
		
		sprite_data.append({"sprite": new_sprite, "y_velocity": y_velocity, "removal_time": removal_time, "removed": false})
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = max_time
	timer.connect('timeout', Callable(self, '_kill'))
	self.add_child(timer)

func _kill():
	queue_free()
	EventBus.emit_signal('respawn_turret', position)
	
func _process(delta):
	for sprite_map in sprite_data.filter(func(sprite_map): return sprite_map['removed'] == false):
		var y_velocity = sprite_map["y_velocity"]
		sprite_map['sprite'].position.y += y_velocity * delta

		sprite_map["y_velocity"] += 3 * delta

		sprite_map['removal_time'] -= delta
		if sprite_map['removal_time'] <= 0:
			sprite_map['removed'] = true
			sprite_map['sprite'].queue_free()

func _divide_rectangle(rect: Rect2):
	var width = rect.size.x
	var height = rect.size.y
	var min_width = randf() * 10
	var min_height = randf() * 20
	if width > min_width and height > min_height:
		if randf() < 0.5:
			var cut_x = rect.position.x + min_width + randf() * (width - 2 * min_width)
			var left_rect = Rect2(rect.position, Vector2(cut_x - rect.position.x, height))
			var right_rect = Rect2(Vector2(cut_x, rect.position.y), Vector2(rect.end.x - cut_x, height))
			_divide_rectangle(left_rect)
			_divide_rectangle(right_rect)
		else:
			var cut_y = rect.position.y + min_height + randf() * (height - 2 * min_height)
			var top_rect = Rect2(rect.position, Vector2(width, cut_y - rect.position.y))
			var bottom_rect = Rect2(Vector2(rect.position.x, cut_y), Vector2(width, rect.end.y - cut_y))
			_divide_rectangle(top_rect)
			_divide_rectangle(bottom_rect)
	elif width > min_width:
			var cut_x = rect.position.x + min_width + randf() * (width - 2 * min_width)
			var left_rect = Rect2(rect.position, Vector2(cut_x - rect.position.x, height))
			var right_rect = Rect2(Vector2(cut_x, rect.position.y), Vector2(rect.end.x - cut_x, height))
			_divide_rectangle(left_rect)
			_divide_rectangle(right_rect)
	elif height > min_height:
			var cut_y = rect.position.y + min_height + randf() * (height - 2 * min_height)
			var top_rect = Rect2(rect.position, Vector2(width, cut_y - rect.position.y))
			var bottom_rect = Rect2(Vector2(rect.position.x, cut_y), Vector2(width, rect.end.y - cut_y))
			_divide_rectangle(top_rect)
			_divide_rectangle(bottom_rect)
	else:
		_rectangles.append(rect)
