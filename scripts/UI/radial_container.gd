@tool
class_name RadialContainer extends Container
## A container that arranges it's children in circle formation.


@export
var child_rect_scale: Vector2 = Vector2.ONE : set = set_child_rect_scale



@export_range(-180.0, 180.0, 0.5, "radians_as_degrees")
var start_deg: float = -PI/2.0 : set = set_start_deg

## Amount of the cirle's perimeter to space children across.
@export_range(0.0, 1.0, 0.01, )
var arc_ratio: float = 1.0: set = set_arc_ratio


@export_group("Animation")
@export_enum("None:0", "Center Expand:1")
var animation_mode: int = 0

@export_range(0.1, 5.0, 0.1, "or_greater", "suffix:s")
var animation_duration_sec: float = 1.0

@export
var tween_trans: Tween.TransitionType = Tween.TransitionType.TRANS_ELASTIC

var tw: Tween

func _notification(what: int) -> void:
	match what:
		
		NOTIFICATION_SORT_CHILDREN:
			sort_children()
		
		NOTIFICATION_DRAW when Engine.is_editor_hint():
			draw_rect(Rect2(0,0,size.x, size.y), Color(Color.FUCHSIA, 0.5), false, 1.0)
			draw_circle(size/2.0, 1.0, Color(Color.FUCHSIA, 0.5),)
			
			for rect in get_child_rects():
				draw_rect(rect, Color(Color.GREEN_YELLOW, 0.5), false)


func sort_children() -> void:
	var controls: Array[Control] = get_sortable_children()
	var rects: Array[Rect2] = get_child_rects()
	
	for i: int in controls.size():
		fit_child_in_rect(controls[i], rects[i])
	
	
	if Engine.is_editor_hint():
		queue_redraw()

func get_child_rects() -> Array[Rect2]:
	var childs:= get_sortable_children()
	var count: int = childs.size()
	match count:
		0: return []
		1: return [Rect2(0,0,size.x, size.y)]
	
	
	var result: Array[Rect2]
	result.resize(count)
	
	var rect_size: Vector2 = size / maxf(count, 3.0) * child_rect_scale
	result.fill(Rect2(Vector2(-0.5, -0.5) * rect_size, rect_size)) 
	
	var pos_min: Vector2 = rect_size / 2.0
	var pos_max: Vector2 = size - rect_size / 2.0

	var max_delta_deg: float = minf(TAU - TAU / count,  TAU * arc_ratio)
	var delta_deg: float = max_delta_deg / (count - 1)
	for i: int in count:
		var angle: float = start_deg + delta_deg * i 
		var dir: Vector2 = Vector2.from_angle(angle)
		var child_cpos: Vector2 = Vector2(
			remap(cos(angle), -1.0, 1.0, pos_min.x, pos_max.x),
			remap(sin(angle), -1.0, 1.0, pos_min.y, pos_max.y)
			)
		#- rect_size  / 2.0
		#dir.x = remap()
		result[i].position += child_cpos
		
	
	return result

func set_child_position(child: Control, pos: Vector2) -> void:
	match animation_mode:
		
		0: 	# No animation
			if tw: tw.kill()
			child.position = pos
		
		1: # Center Expand
			if not tw or not tw.is_valid():
				tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_parallel(true)
			tw.tween_property(child, ^"position", pos, animation_duration_sec).from(size/2.0 - child.size/2.0)


func _get_minimum_size() -> Vector2:
	var min_size: Vector2 = custom_minimum_size
	for control: Control in get_sortable_children():
		min_size = min_size.max(control.get_combined_minimum_size())
	return min_size


func get_largest_child_size() -> float:
	var max_size: float = 0.0
	for child: Control in get_sortable_children():
		var child_min_size: Vector2 = child.get_combined_minimum_size()
		max_size = max(child_min_size.x, child_min_size.y, max_size)
	return max_size


func get_sortable_children() -> Array[Control]:
	var sortable_children: Array[Control]
	for child: Node in get_children():
		if child is Control and child.visible:
			sortable_children.push_back(child)
	return sortable_children

#region Simple Setters & Getters

func set_child_rect_scale(val: Vector2) -> void:
	child_rect_scale = val
	sort_children()

func set_start_deg(val: float) -> void:
	start_deg = val
	sort_children()


func set_arc_ratio(val: float) -> void:
	arc_ratio = val
	sort_children()

#endregion Simple Setters & Getters
