@tool
class_name EdgeContainer extends Container

@export_custom(0,"", PROPERTY_USAGE_EDITOR)
var enabled: bool = true: set = set_enabled
	
@export var side: Side = SIDE_LEFT:
	set(val):
		side = val
		axis = Vector2.AXIS_X if side % 2 == 0 else Vector2.AXIS_Y
		calculate_delta()

@export var tween_scale: bool = false
@export var min_scale: float = 0.1
@export var max_scale: float = 1.0


@export_range(0.1, 5.0, 0.1, "or_greater", "suffix:s", ) var duration: float = 1.5
@export var show_trans: Tween.TransitionType = Tween.TRANS_BACK
@export var show_ease: Tween.EaseType = Tween.EASE_IN_OUT

## Multiply delta by this value to speed up animation...
@export_range(0.1, 3.0, 0.05, "or_greater", "suffix:%", ) 
var hide_duration_modifier: float = 1.5
@export var hide_trans: Tween.TransitionType = Tween.TRANS_BACK
@export var hide_ease: Tween.EaseType = Tween.EASE_IN_OUT

@export var debug_rect_color: Color = Color(Color.HOT_PINK, 0.85):
	set(val): debug_rect_color = val; queue_redraw()
		
@export var child_rect_color: Color = Color(Color.DIM_GRAY, 0.85):
	set(val): child_rect_color = val; queue_redraw()

var vp_size:Vector2 = Vector2(ProjectSettings["display/window/size/viewport_width"], ProjectSettings["display/window/size/viewport_height"]):
	set(val):
		vp_size = val
		calculate_delta()
	
var axis: int = Vector2.AXIS_X
var hide_delta: float = 0.0

@export_custom(0,"", PROPERTY_USAGE_EDITOR)
var elapsed: float = 0.0: set = set_elapsed

func _process(delta: float) -> void:
	elapsed = elapsed - delta if enabled else elapsed + (delta * hide_duration_modifier)
	if elapsed == duration or elapsed == 0.0:
		set_process(false)
		queue_redraw()
		
func set_elapsed(val: float) -> void:
	elapsed = clampf(val, 0.0, duration)
	for child: Control in get_controls():
		child.visible = elapsed != duration
		var opposite_axis: int = abs(axis - 1)
		child.position[opposite_axis] = 0.0
		child.position[axis] = Tween.interpolate_value(0.0, hide_delta, elapsed, duration, show_trans if enabled else hide_trans, show_ease if enabled else hide_ease)
		if tween_scale:
			child.scale[opposite_axis] = max_scale
			child.scale[axis] = Tween.interpolate_value(max_scale, min_scale - max_scale, elapsed, duration, show_trans if enabled else hide_trans, show_ease if enabled else hide_ease)
			
		
	
func set_enabled(val: bool) -> void:
	enabled = val
	set_process(true)
	create_tween().tween_callback(queue_redraw).set_delay(0.1)



func calculate_delta() -> void:
	hide_delta = -global_position[axis] - size[axis] if side < 2 else vp_size[axis] - global_position[axis]
	elapsed = elapsed
	
func _get_minimum_size() -> Vector2:
	var min_size: Vector2 = custom_minimum_size
	for child: Control in get_controls():
		min_size.x = maxf(min_size.x, child.get_minimum_size().x)
		min_size.y = maxf(min_size.y, child.get_minimum_size().y)
	return min_size


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_POST_ENTER_TREE:
			set_notify_transform(true)
			set_notify_local_transform(true)
			
		NOTIFICATION_SORT_CHILDREN:
			for child: Control in get_controls():
				child.size.x = size.x
				child.size.y = size.y
			elapsed = elapsed
			
		NOTIFICATION_READY when Engine.is_editor_hint():
			calculate_delta()
			
		NOTIFICATION_READY:
			var viewport:= get_viewport()
			viewport.size_changed.connect(_on_viewport_size_changed.bind(viewport))
			_on_viewport_size_changed(viewport)
			
		NOTIFICATION_LOCAL_TRANSFORM_CHANGED, NOTIFICATION_TRANSFORM_CHANGED:
			calculate_delta()
			queue_redraw()
			
		
		
		NOTIFICATION_DRAW:
			if elapsed != duration: return
			draw_rect(Rect2(0,0, size.x, size.y), Color.HOT_PINK, false, )
			if Engine.is_editor_hint():
				for control: Control in get_controls():
					draw_rect(control.get_rect(), Color(Color.DIM_GRAY, 0.85), false, )
			

func _on_viewport_size_changed(viewport: Viewport) -> void:
	vp_size = viewport.size
	calculate_delta()

func get_controls() -> Array[Control]:
	var controls: Array[Control]
	for child: Node in get_children():
		if child is Control: controls.push_back(child as Control)
	return controls
	
