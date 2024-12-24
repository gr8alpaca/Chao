@tool
class_name Floater extends Container

@export var active: bool = true : set = set_active

@export_range(0.0, 100.0, 1.0, "or_greater", "suffix:px") var max_x_distance: float = 0.0:
	set(val): max_x_distance = val; queue_redraw();

@export_range(0.0, 100.0, 1.0, "or_greater", "suffix:px") var max_y_distance: float = 0.0:
	set(val): max_y_distance = val ; queue_redraw();

@export_range(0.05, 20.0, 0.05, "suffix:s") var cycle_speed_sec: float = 7.0
@export_range(0.05, 2.0, 0.02, ) var volatility: float = 1.25

@export_range(0.0, 90.0, 1.0, "suffix:°", "hide_slider") var max_rotation_deg: float = 0.5
@export_range(0.05, 20.0, 0.05, "suffix:s") var rotation_cycle_speed_sec: float = 10.0

@export var draw_movement_area : bool = true:
	set(val): draw_movement_area = val; queue_redraw();

var time: float = 0.0
var time_offset = 0.0

func _init(max_x: float = 0.0, max_y: float = 0.0) -> void:
	max_x_distance = max_x
	max_y_distance = max_y
	time_offset = randf()*TAU

func _process(delta: float) -> void:
	time += delta
	
	for c: Control in get_child_controls():
		var time : float = self.time * TAU + time_offset
		c.position = Vector2(sin(time / volatility / cycle_speed_sec), cos((time)/ cycle_speed_sec + PI/2)) * Vector2(max_x_distance ,max_y_distance)
		c.rotation_degrees = sin(time / rotation_cycle_speed_sec) * max_rotation_deg


func set_active(val: bool) -> void:
	active = val
	set_process(val)
	if not val:
		_process(-time)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			mouse_filter = MOUSE_FILTER_PASS
			
		NOTIFICATION_PRE_SORT_CHILDREN:
			size.x = maxf(size.x, get_combined_minimum_size().x)
			size.y = maxf(size.y, get_combined_minimum_size().y)
			
			for child: Control in get_child_controls():
				child.size.x = size.x
				child.size.y = size.y
		
		NOTIFICATION_SORT_CHILDREN:
			for control: Control in get_child_controls():
				control.position = Vector2.ZERO
			
		NOTIFICATION_DRAW when draw_movement_area and Engine.is_editor_hint():
			draw_rect(Rect2(-max_x_distance, -max_y_distance, size.x+2*max_x_distance, size.y + 2*max_y_distance), Color(1, 0.412, 0.706, 0.3), false)


func _get_minimum_size() -> Vector2:
	var min_size: Vector2 = Vector2.ZERO
	for control: Control in get_child_controls():
		var control_min: Vector2 = control.get_combined_minimum_size()
		min_size.x = maxf(control_min.x, min_size.x)
		min_size.y = maxf(control_min.y, min_size.y)
	return min_size


func get_child_controls() -> Array[Control]:
	var childs: Array[Control]
	for child: Node in get_children():
		if child is Control: childs.push_back(child as Control)
	return childs
