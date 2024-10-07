@tool
class_name LevelProgressBar extends Control

signal level_hit


@export var max_value: int = 8: set = set_max_value
@export var min_value: int = 0: set = set_min_value

@export var value: int = 2: set = set_value
@export_custom(0, "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY)
var drawn_value: float: set = set_drawn_value

@export var test_add_value: int:
	set(val):

		add_value(val)
		
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

@export_category("Level Text")

@export var level_draw_offset: Vector2 = Vector2(4, 0)

@export_color_no_alpha var text_color: Color = Color.WHITE_SMOKE:
	set(val):
		text_color = val
		queue_redraw()


@export var font_size: int = 20
@export var text_velocity: Vector2
@export_range(1.0, 5.0, 0.2, "suffix:sec") var text_duration: float = 2.5

@export_category("Animation Settings")
@export var tween_duration: float = 0.75
@export var tween_trans: Tween.TransitionType = Tween.TRANS_ELASTIC
@export var tween_ease: Tween.EaseType = Tween.EASE_OUT

@export_range(1.0, 10.0, 0.25, "suffix:seg/s")
var fill_speed: float

var tween: Tween


func _process(delta: float) -> void:
	if value == drawn_value:
		if value == max_value:
			level_up()
			return
		set_process(false)
		return

	drawn_value = move_toward(drawn_value, value, delta * fill_speed) if drawn_value < value else float(value)


func set_max_value(val: int) -> void:
	max_value = maxi(val, min_value)
	queue_redraw()


func set_min_value(val: int) -> void:
	min_value = mini(val, max_value)
	queue_redraw()


func add_value(val: int) -> void:
	while val > max_value - value:
		val -= (max_value - value)
		value += (max_value - value)
		await level_hit

	value += val


func set_value(val: int) -> void:
	value = clampi(val, min_value, max_value)
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
	

func draw_bar(width: float = size.x / maxf(0.01, max_value)) -> void:
	draw_set_transform_matrix(Transform2D(rotation, scale, deg_to_rad(skew_degrees), Vector2.ZERO))

	draw_rect(Rect2(0, 0, size.x, size.y), bg_color)
	draw_rect(Rect2(0, 0, drawn_value * width, size.y), fill_color)
	for i: int in max_value:
		draw_rect(Rect2(i * width, 0, width, size.y), border_color, false, rect_border_width, false)


func _draw() -> void:
	# draw_level_text(get_theme_default_font())

	draw_bar(size.x / max_value)

	
# func create_textpop(font: Font) -> TextPop:
# 	if not font or not text_alpha: return
