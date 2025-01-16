@tool
class_name RadialProgressBar extends Control

signal filled
const FILL_COLOR: Color = Color(0.723, 0.701, 0.252, 1.0)


@export var value: int = 0: set = set_value
@export var drawn_value: float: set = set_drawn_value

@export var test_add_value: int:
	set(val): add_value(val)

@export_range(1, 100, 1, "or_greater") var segment_count: int = 8

@export_range(1.0, 10.0, 0.25, "suffix:segment/sec")
var fill_speed: float = 1.0

@export_group("Theme Settings")

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


@export_range(0.0, 8.0, 0.5, "or_greater", "suffix:px") var circle_border_width: float = 2.0:
	set(val):
		circle_border_width = val
		queue_redraw()


@export_subgroup("Level Text")

@export var level_draw_offset: Vector2 = Vector2(4, 0)

@export_color_no_alpha var text_color: Color = Color.WHITE_SMOKE:
	set(val):
		text_color = val
		queue_redraw()


@export var font_size: int = 20
@export var text_velocity: Vector2

@export_range(1.0, 5.0, 0.2, "suffix:sec")
var text_duration: float = 2.5


func init_value(val: float) -> void:
	drawn_value = val
	value = val
	#print("Bar value set: Drawn - %1.1f | Value - %1.1f" % [drawn_value, value])


func _process(delta: float) -> void:
	if value == drawn_value:
		if value == segment_count:
			level_up()
			return
		set_process(false)
		return
	
	drawn_value = move_toward(drawn_value, value, delta * fill_speed) if drawn_value < value else float(value)


func add_value(val: int) -> void:
	while val > segment_count - value:
		val -= (segment_count - value)
		value += (segment_count - value)
		await filled
	
	value += val


func level_up() -> void:
	clear()
	filled.emit()


func clear() -> void:
	value = 0.0
	drawn_value = 0.0


func set_value(val: int) -> void:
	value = clampi(val, 0, segment_count)
	set_process(value != drawn_value)


func set_drawn_value(val: float) -> void:
	drawn_value = val
	queue_redraw()


func _get_minimum_size() -> Vector2:
	return Vector2(16, 8)
	

#


func _draw() -> void:
	draw_circle(size/2.0, maxf(size.x/2.0, size.y/2.0), bg_color) # Background
	

#func draw_bar() -> void:
	#var segement_width: float = size.x / segment_count
	#var bound_offsets: Vector2 = Vector2(0, size.y).rotated(skew)
	#
	#var x_ratio: float = abs(bound_offsets.x + size.x) / size.x
	#var y_component: float = (size.y / bound_offsets.y) * size.y
	#draw_set_transform_matrix(Transform2D(rotation, scale * Vector2(x_ratio, 1.0) * scale, skew, Vector2(-bound_offsets.x + circle_border_width, 0.0)))
#
	#draw_rect(Rect2(0, 0, size.x, y_component), bg_color)
	#draw_rect(Rect2(0, 0, drawn_value * segement_width, y_component), fill_color)
	#for i: int in segment_count:
		#draw_rect(Rect2(i * segement_width, 0, segement_width, y_component), border_color, false, circle_border_width, false)
