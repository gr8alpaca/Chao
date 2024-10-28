@tool
class_name ScheduleUI extends Control

const WEEK_COUNT: int = 4
const BOTTOM_OFFSET: int = 64

@export var weeks_max_size: Vector2i = Vector2i(200, 100):
	set(val):
		weeks_max_size = val
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2i((size.x-weeks_max_size.x)/2, size.y - BOTTOM_OFFSET - weeks_max_size.y, weeks_max_size.x, weeks_max_size.y), Util.DEBUG_COLOR, false, 2.0)