@tool
class_name LevelProgressBar extends Control



@export var max_value: int = 8: set = set_max_value
@export var min_value: int = 0: set = set_min_value

@export var value: int = 2: set = set_value
var drawn_value: float : set = set_drawn_value

@export_category("Theme Settings")

@export var fill_color: Color = Color.LIGHT_YELLOW:
	set(val):
		fill_color = val
		queue_redraw()
@export var bg_color: Color = Color.DIM_GRAY:
	set(val):
		bg_color = val
		queue_redraw()	 
@export var border_color: Color = Color.BLACK:
	set(val):
		border_color = val
		queue_redraw()

@export var rect_border_width: float = 2.0:
	set(val):
		rect_border_width = val
		queue_redraw()

@export_range(-180, 180, 1.0, "suffix:°") var skew_degrees: float:
	set(val):
		skew_degrees = (val)
		queue_redraw()

@export_category("Animation Settings")
@export var tween_duration: float = 0.75
@export var tween_trans: Tween.TransitionType = Tween.TRANS_ELASTIC
@export var tween_ease: Tween.EaseType = Tween.EASE_OUT


func _draw() -> void:
	var width: float = size.x/max_value
	draw_set_transform_matrix(Transform2D(rotation, scale, deg_to_rad(skew_degrees), Vector2.ZERO))
	draw_rect(Rect2(0, 0, size.x, size.y), bg_color)
	draw_rect(Rect2(0, 0, drawn_value*width, size.y), fill_color)
	for i: int in max_value:
		draw_rect(Rect2(i*width, 0, width, size.y), border_color, false, rect_border_width, false)
	



func set_max_value(val: int) -> void:
	max_value = maxi(val, min_value)
	queue_redraw()


func set_min_value(val: int) -> void:
	min_value = mini(val, max_value)
	queue_redraw()

func set_value(val: int) -> void:
	value = clampi(val , min_value, max_value)

	if drawn_value < value: 
		create_tween().set_trans(tween_trans).set_ease(tween_ease).tween_method(set_drawn_value, drawn_value, float(value), get_tween_duration(float(value) - drawn_value))
	else:
		create_tween().tween_method(set_drawn_value, 0.0, 0.0, 0.1)

	queue_redraw()

func set_drawn_value(val: float) -> void:
	drawn_value = val
	queue_redraw()

func get_tween_duration(drawn_value_delta: float) -> float:
	const MINIMUM_TWEEN_TIME: float = 0.2
	const SEGMENT_DURATION: float = 0.4
	return  MINIMUM_TWEEN_TIME + (SEGMENT_DURATION * drawn_value_delta)

func _get_minimum_size() -> Vector2:
	return Vector2(16, 8)
	