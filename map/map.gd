extends Node


@onready var theme : AudioStreamPlayer2D = $Theme

@export var min_width = 30
@export var min_height = 50
var _rectangles = []

func _ready():
	var rect = Rect2(Vector2(0,0), Vector2(100, 200))
	divide_rectangle(rect)
	EventBus.connect('dead', Callable(self, '_stop_music'))

func _stop_music():
	theme.stop()

func divide_rectangle(rect: Rect2):
	var width = rect.size.x
	var height = rect.size.y

	if width > min_width and height > min_height:
		if randf() < 0.5:
			var cut_x = rect.position.x + min_width + randf() * (width - 2 * min_width)
			var left_rect = Rect2(rect.position, Vector2(cut_x - rect.position.x, height))
			var right_rect = Rect2(Vector2(cut_x, rect.position.y), Vector2(rect.end.x - cut_x, height))
			divide_rectangle(left_rect)
			divide_rectangle(right_rect)
		else:
			var cut_y = rect.position.y + min_height + randf() * (height - 2 * min_height)
			var top_rect = Rect2(rect.position, Vector2(width, cut_y - rect.position.y))
			var bottom_rect = Rect2(Vector2(rect.position.x, cut_y), Vector2(width, rect.end.y - cut_y))
			divide_rectangle(top_rect)
			divide_rectangle(bottom_rect)
	else:
		_rectangles.append(rect)
