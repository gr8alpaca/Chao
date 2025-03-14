@tool
class_name RadialContainer extends Container


@export_range(0.0, 100.0, 1.0, "or_greater") 
var center_radius: float = 20.0:
	set(val):
		center_radius = val
		update_sort()


@export_range(-180.0, 180.0, 0.5, "radians_as_degrees")
var start_deg: float = -PI/2.0:
	set(val):
		start_deg = val
		update_sort()


@export_range(0.0, 360.0, 0.5, "radians_as_degrees")
var size_deg: float = TAU:
	set(val):
		size_deg = val
		update_sort()

@export_enum("None:0", "Center Expand:1")
var animation_mode: int = 0

@export_range(0.1, 5.0, 0.1, "or_greater", "suffix:s")
var animation_duration_sec: float = 1.0

@export
var tween_trans: Tween.TransitionType = Tween.TransitionType.TRANS_ELASTIC

var tw: Tween

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PRE_SORT_CHILDREN:
			#var child_size: Vector2 = Vector2.ONE * get_largest_child_size()
			for child in get_children():
				if child is Control: 
					child.size = Vector2.ZERO 
			update_minimum_size()
		
		
		NOTIFICATION_SORT_CHILDREN:
			sort_children()
		
		NOTIFICATION_DRAW when Engine.is_editor_hint():
			draw_rect(Rect2(0,0,size.x, size.y), Color.FUCHSIA, false, 1.0)
			


func sort_children() -> void:
	var child_controls: Array[Control]
	for child in get_children():
		if child is Control and child.visible: 
			child_controls.push_back(child)
	
	if child_controls.size() == 1:
		get_child(0).position = Vector2.ZERO
		return
	
	
	var radius: float = get_largest_child_size() / 2.0 + center_radius
	for i: int in child_controls.size():
		var t: float = inverse_lerp(0, child_controls.size(), i)
		var angle: float = start_deg + lerpf(0.0, size_deg, t)
		var child_cpos: Vector2 = size/2.0 + (Vector2.from_angle(angle) * radius)
		
		set_child_position(child_controls[i], child_cpos - (child_controls[i].size / 2.0))
		

func set_child_position(child: Control, pos: Vector2) -> void:
	match animation_mode:
		0: #No animation
			if tw: tw.kill()
			child.position = pos
			
		1:
			if not tw or not tw.is_valid():
				tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_parallel(true)
			tw.tween_property(child, ^"position", pos, animation_duration_sec).from(size/2.0 - child.size/2.0)

func update_sort() -> void:
	notification(NOTIFICATION_PRE_SORT_CHILDREN)
	notification(NOTIFICATION_SORT_CHILDREN)


func _get_minimum_size() -> Vector2:
	match get_child_count():
		0: return Vector2.ZERO
		1: return Vector2.ONE * get_largest_child_size() * 2.0
	return  Vector2.ONE * 2.0 * (get_largest_child_size() + center_radius)


func get_largest_child_size() -> float:
	var max_size: float = 0.0
	for child in get_children():
		if child is Control: 
			var child_min_size: Vector2 = child.get_combined_minimum_size()
			max_size = max(child_min_size.x, child_min_size.y, max_size)
	return max_size
