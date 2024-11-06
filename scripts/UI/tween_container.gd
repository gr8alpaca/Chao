@tool
class_name TweenContainer extends Container

enum Mode {ELASTIC, LINEAR, SHOWN, HIDE}

@export var tween_mode: Mode = Mode.ELASTIC
@export var side: Side = SIDE_LEFT
@export var children_visible: bool = true : set = set_children_visible

@export var time_sec: float = 1.3:
	set(val):
		var t: float = elapsed/time_sec if time_sec != 0.0 else 1.0
		time_sec = val
		elapsed = time_sec * t

var hide_position: Vector2 = Vector2.ZERO

var elapsed: float = 1.3


func set_children_visible(val: bool) -> void:
	children_visible = val
	
	if children_visible and get_child(0).position != Vector2.ZERO:
		pass

	# if not children_visible and 
	notify_property_list_changed()


func _process(delta: float) -> void:
	return
	for control: Control in get_child_controls():
		
		pass
	# Tween.interpolate_value(
	# 	Vector2.ZERO if children_visible else Vector2.ZERO,
	#	
	# 	)
	
	pass

func set_inactive_position() -> void:
	if not is_inside_tree():
		await tree_entered

	if not get_child_count() == 1:
		hide_position = Vector2.ZERO
		return
	
	Vector2(offset_left, offset_top)

	get_window().size

	match side:
		SIDE_BOTTOM:
			hide_position = Vector2(0, get_offset(SIDE_BOTTOM) + size.y)
		SIDE_TOP:
			hide_position = Vector2(0, get_offset(SIDE_TOP) + size.y)
		SIDE_LEFT:
			hide_position = Vector2(get_offset(SIDE_LEFT) + size.x, 0)
		SIDE_RIGHT:
			hide_position = Vector2(get_offset(SIDE_RIGHT) + size.x, 0)

	Vector2(get_offset(side), 0.0)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0.411765, 0.705882, 0.5), false)

func get_child_controls() -> Array[Control]:
	var childs: Array[Control]
	for child: Node in get_children():
		if not child is Control: continue
		childs.push_back(child as Control)
	return childs

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			var min_size: Vector2 = get_minimum_size()
			size.x = maxf(min_size.x, size.x)
			size.y = maxf(min_size.y, size.y)
			for child: Node in get_child_controls():
				child.size.x = size.x
				child.size.y = size.y
				child.position = Vector2.ZERO
			

func _get_minimum_size() -> Vector2:
	var min_size: Vector2 = Vector2.ZERO
	for control: Control in get_child_controls():
		var control_min: Vector2 = control.get_minimum_size()
		min_size.x = maxf(control_min.x, min_size.x)
		min_size.y = maxf(control_min.y, min_size.y)
	return min_size