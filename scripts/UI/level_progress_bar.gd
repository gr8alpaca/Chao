@tool
class_name LevelProgressBar extends Control

signal level_hit


const MAX_VALUE: int = 8
const MIN_VALUE: int = 0
const FILL_COLOR: Color = Color(0.723, 0.701, 0.252, 1.0)


@export var value: int = 2: set = set_value
@export_custom(0, "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY)
var drawn_value: float: set = set_drawn_value

@export var test_add_value: int:
	set(val):
		add_value(val)

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


@export var rect_border_width: float = 2.0:
	set(val):
		rect_border_width = val
		queue_redraw()

@export_range(-180, 180, 1.0, "suffix:°") var skew_degrees: float:
	set(val):
		skew_degrees = (val)
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



func _process(delta: float) -> void:
	if value == drawn_value:
		if value == MAX_VALUE:
			level_up()
			return
		set_process(false)
		return
	
	drawn_value = move_toward(drawn_value, value, delta * fill_speed) if drawn_value < value else float(value)


func add_value(val: int) -> void:
	while val > MAX_VALUE - value:
		val -= (MAX_VALUE - value)
		value += (MAX_VALUE - value)
		await level_hit

	value += val


func set_value(val: int) -> void:
	value = clampi(val, MIN_VALUE, MAX_VALUE)
	set_process(value != drawn_value)


func level_up() -> void:
	clear()
	level_hit.emit()
	var text_pop := TextPop.new().set_fade(TextPop.FADE_NORMAL | TextPop.FADE_COLOR).set_fs(font_size).set_alt_col(text_color) \
	.set_pos(Vector2(size.x, 0) + level_draw_offset).set_txt("Level Up").set_vel(text_velocity)
	add_child(text_pop)
	text_pop.start(text_duration, )


func clear() -> void:
	value = 0.0
	drawn_value = 0.0


func set_drawn_value(val: float) -> void:
	drawn_value = val
	queue_redraw()


func _get_minimum_size() -> Vector2:
	return Vector2(16, 8)
	

func draw_bar() -> void:
	var rads := deg_to_rad(skew_degrees)
	var segement_width: float = size.x / MAX_VALUE
	var bound_offsets: Vector2 = Vector2(0, size.y).rotated(rads)
	
	var x_ratio: float = abs(bound_offsets.x + size.x) / size.x
	var y_component: float = (size.y / bound_offsets.y) * size.y
	draw_set_transform_matrix(Transform2D(rotation, scale * Vector2(x_ratio, 1.0) * scale, rads, Vector2(-bound_offsets.x + rect_border_width, 0.0)))

	draw_rect(Rect2(0, 0, size.x, y_component), bg_color)
	draw_rect(Rect2(0, 0, drawn_value * segement_width, y_component), fill_color)
	for i: int in MAX_VALUE:
		draw_rect(Rect2(i * segement_width, 0, segement_width, y_component), border_color, false, rect_border_width, false)


func _draw() -> void:
	# draw_level_text(get_theme_default_font())

	draw_bar()

	
# func create_textpop(font: Font) -> TextPop:
# 	if not font or not text_alpha: return
