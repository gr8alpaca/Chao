@tool
class_name TweenContainer extends Control

enum Mode {ELASTIC, LINEAR, SHOWN, HIDE}

@export var tween_mode: Mode = Mode.ELASTIC
@export var origin_side: Side = SIDE_LEFT
@export var active: bool = false : set = set_active

@export var time_sec: float = 1.3


var hide_position: Vector2 = Vector2.ZERO


func _init() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(update_configuration_warnings.unbind(1))
	set_process(false)


func _enter_tree() -> void:
	set_notify_local_transform(true)

func _exit_tree() -> void:
	pass


func set_active(val: bool) -> void:
	active = val
	if get_child_count() != 1: return
	
	if active and get_child(0).position != Vector2.ZERO:
		pass

	# if not active and 
	notify_property_list_changed()


func _process(delta: float) -> void:
	# Tween.interpolate_value(
	# 	Vector2.ZERO if active else Vector2.ZERO,
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

	match origin_side:
		SIDE_BOTTOM:
			hide_position = Vector2(0, get_offset(SIDE_BOTTOM) + size.y)
		SIDE_TOP:
			hide_position = Vector2(0, get_offset(SIDE_TOP) + size.y)
		SIDE_LEFT:
			hide_position = Vector2(get_offset(SIDE_LEFT) + size.x, 0)
		SIDE_RIGHT:
			hide_position = Vector2(get_offset(SIDE_RIGHT) + size.x, 0)

	Vector2(get_offset(origin_side), 0.0)


func _on_child_entered_tree(node: Node) -> void:
	update_configuration_warnings()
	if not node is Control: return
	var control: Control = node as Control

	size.x = maxf(size.x, control.size.x)
	size.y = maxf(size.y, control.size.y)
	
	control.visible = active
	

func _on_child_exiting_tree(node: Node) -> void:
	update_configuration_warnings()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0.411765, 0.705882, 0.5), false)


func _get_configuration_warnings() -> PackedStringArray:
	return ["Child count !=1 or child is not of type Control." if get_child_count() != 1 or not get_child(0) else ""]


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			pass
		# NOTIFICATION_ANC