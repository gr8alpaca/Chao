@tool
class_name LevelProgressBar extends Control

signal level_hit

const MAX_VALUE: int = 8
const MIN_VALUE: int = 0
const FILL_COLOR: Color = Color(0.723, 0.701, 0.252, 1.0)

@export_tool_button("Test Add", "ProgressBar")
var add_callable: Callable = add_value.bind(3)

@export var value: int = 2: set = set_value
@export_custom(0, "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY)
var drawn_value: float: set = set_drawn_value

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

@export_range(-90.0, 90.0, 0.5, "radians_as_degrees") var skew: float = PI/4.0:
	set(val):
		skew = val
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

var current_text_delta: int  = 0

func init_value(val: float) -> void:
	drawn_value = val
	value = val
	#print("Bar value set: Drawn - %1.1f | Value - %1.1f" % [drawn_value, value])


func _process(delta: float) -> void:
	if value == drawn_value:
		if value == MAX_VALUE:
			level_up()
			return
		set_process(false)
		return
	
	var previous_drawn_value: float = drawn_value
	drawn_value = move_toward(drawn_value, value, delta * fill_speed) if drawn_value < value else float(value)
	
	if floori(previous_drawn_value) != floori(drawn_value):
		print("Subtracting ")
		current_text_delta = maxi(current_text_delta - 1, 0)



func add_value(val: int) -> void:
	current_text_delta += val
	
	while val > MAX_VALUE - value:
		val -= (MAX_VALUE - value)
		value += (MAX_VALUE - value)
		await level_hit
	
	value += val


func level_up() -> void:
	clear()
	emit_signal.call_deferred(&"level_hit")


func clear() -> void:
	value = 0.0
	drawn_value = 0.0


func set_value(val: int) -> void:
	value = clampi(val, MIN_VALUE, MAX_VALUE)
	set_process(value != drawn_value)


func set_drawn_value(val: float) -> void:
	drawn_value = val
	queue_redraw()



func _draw() -> void:
	draw_bar()


func draw_bar() -> void:
	var segement_width: float = size.x / MAX_VALUE
	var bound_offsets: Vector2 = Vector2(0, size.y).rotated(skew)
	
	var x_ratio: float = abs(bound_offsets.x + size.x) / size.x
	var y_component: float = (size.y / bound_offsets.y) * size.y
	draw_set_transform_matrix(Transform2D(rotation, scale * Vector2(x_ratio, 1.0) * scale, skew, Vector2(-bound_offsets.x + rect_border_width, 0.0)))
	
	draw_rect(Rect2(0, 0, size.x, y_component), bg_color)
	draw_rect(Rect2(0, 0, drawn_value * segement_width, y_component), fill_color)
	
	for i: int in MAX_VALUE:
		draw_rect(Rect2(i * segement_width, 0, segement_width, y_component), border_color, false, rect_border_width, false)
	
	draw_set_transform(Vector2.ZERO)
	#draw_increase_text()

const UP_ARROW_UNICODE: int = 11014

func draw_increase_text() -> void:
	if not current_text_delta: return
	
	const OUTLINE_COLOR: Color = Color.BLACK
	const FONT_COLOR: Color = Color(0.70, 1.0, 0.70, 1.0)
	
	
	const MARGIN_RATIO: float = 0.85
	const OUTLINE_SIZE: int = 1
	
	var font: Font = get_theme_default_font()
	var text: String = char(UP_ARROW_UNICODE) + " %d" % current_text_delta
	
	var font_size: int = 1
	#var string_size: Vector2 = font.get_string_size(text, 0, -1, font_size,)
	while font.get_string_size(text, 0, -1, font_size,).y < (size.y * MARGIN_RATIO):
		font_size += 1
	
	
	var string_position: Vector2 = (size - font.get_string_size(text, font_size,)) / 2.0 - (size * Vector2.UP)
	
	
	
	draw_string_outline(font, string_position , text , 0, -1, font_size, OUTLINE_SIZE, OUTLINE_COLOR)
	draw_string(font, string_position , text , 0, -1, font_size, FONT_COLOR)




func _get_minimum_size() -> Vector2:
	return Vector2(16, 8)
