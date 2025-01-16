@tool
class_name RadialProgressBar extends Control
const CIRCULAR_PROGRESS_BAR : Shader = preload("res://scripts/shaders/circular_progress_bar.gdshader")
signal filled
const FILL_COLOR: Color = Color(0.723, 0.701, 0.252, 1.0)


@export var value: int = 0: set = set_value
@export var drawn_value: float: set = set_drawn_value

@export_range(1, 100, 1, "or_greater") var segments: int = 8
#@export_range(0.0, 0.5, 0.01) var radius: float = 0.475
#@export_range(0.0, 0.5, 0.01) var hollow_radius: float = 0.0
#@export_range(0.0, 1.0, 0.01) var margin: float = 0.1

@export_range(1.0, 10.0, 0.25, "suffix:segment/sec")
var fill_speed: float = 1.0



func init_value(val: float) -> void:
	drawn_value = val
	value = val
	#print("Bar value set: Drawn - %1.1f | Value - %1.1f" % [drawn_value, value])


func _process(delta: float) -> void:
	if value == drawn_value:
		if value == segments:
			level_up()
			return
		set_process(false)
		return
	
	drawn_value = move_toward(drawn_value, value, delta * fill_speed) if drawn_value < value else float(value)


func add_value(val: int) -> void:
	while val > segments - value:
		val -= (segments - value)
		value += (segments - value)
		await filled
	
	value += val


func level_up() -> void:
	clear()
	filled.emit()


func clear() -> void:
	value = 0.0
	drawn_value = 0.0


func set_value(val: int) -> void:
	value = clampi(val, 0, segments)
	set_process(value != drawn_value)


func set_drawn_value(val: float) -> void:
	drawn_value = val
	queue_redraw()


func _get_minimum_size() -> Vector2:
	return Vector2(16, 8)
	

#


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)
	#draw_circle(size/2.0, maxf(size.x/2.0, size.y/2.0), bg_color) # Background
	
func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"material":
			property.usage = 0
			pass

func _get_property_list() -> Array:
	
	return material.shader.get_shader_uniform_list() if material and material.shader else []

func _get(property: StringName) -> Variant:
	return material.get_shader_parameter(property) if material else null

func _set(property: StringName, value: Variant) -> bool:
	if not material or not material.shader: return false
	if property in material.shader.get_shader_uniform_list().map(func(d:Dictionary) -> StringName: return d.name):
		material.set_shader_parameter(property, value)
		return true
	return false

func _property_can_revert(property: StringName) -> bool:
	if not material or not material.shader: return false
	if property in material.shader.get_shader_uniform_list().map(func(d:Dictionary) -> StringName: return d.name):
		material.set_shader_parameter(property, value)
		return true
	return false
