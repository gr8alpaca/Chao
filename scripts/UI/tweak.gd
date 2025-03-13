@tool
class_name Tweak extends Container

signal opening
signal opened

signal closing
signal closed

signal activity_changed(is_active: bool)

const RECT_COLOR := Color(1, 0.411765, 0.705882, 0.5)
const TARGET_RECT_COLOR := Color(Color.FUCHSIA, 0.5)

enum Mode {ELASTIC, LINEAR, SHOWN, HIDE}


@export var active: bool = true: set = set_active 

@export var target: Control : set = set_target
@export var side: Side = SIDE_LEFT: set = set_side


@export_enum("None:0", "Hide Alpha:1", "Hide Visibility:2") 
var hide_mode: int = 1: set = set_hide_mode

@export_category("Tweening")

@export_range(0.1, 5.0, 0.1, "or_greater", "suffix:s", )
var duration_sec: float = 1.0:
	set(val): duration_sec = val; set_elapsed(elapsed_sec);

@export_range(0.1, 3.0, 0.1, "or_greater",)
var hide_time_scale: float = 1.0:
	set(val): hide_time_scale = val; set_elapsed(elapsed_sec);

@export_group("Scale")

@export var auto_adjust_pivot: bool = true:
	set(val): auto_adjust_pivot = val; if val: update_pivot()


@export var scale_enabled: bool = true:
	set(val): scale_enabled = val; calculate_delta(); notify_property_list_changed();


@export var base_scale: Vector2 = Vector2.ONE:
	set(val): base_scale = val; calculate_delta();
@export var target_scale: Vector2 = Vector2.ONE:
	set(val): target_scale = val; calculate_delta();


@export_group("Transitions & Easing")

@export var trans_type_show: Tween.TransitionType = Tween.TRANS_BACK
@export var trans_type_hide: Tween.TransitionType = Tween.TRANS_BACK
@export var ease_type_show: Tween.EaseType = Tween.EASE_IN_OUT
@export var ease_type_hide: Tween.EaseType = Tween.EASE_IN_OUT


@export_category("Debug")
@export var debug_rect_visible: bool = true:
	set(val): debug_rect_visible = val; queue_redraw();
@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var target_rect_visible: bool:
	set(val): target_rect_visible = val; queue_redraw();


var screen: Vector2 = Vector2(ProjectSettings["display/window/size/viewport_width"], ProjectSettings["display/window/size/viewport_height"])


var target_position_delta: Vector2 = Vector2.ZERO

var elapsed_sec: float = 1.3 : set = set_elapsed
var delay_sec: float = 0.0


func open(delay_sec: float = 0.0) -> void:
	self.delay_sec = delay_sec
	active = true
func close() -> void:
	active = false


func _process(delta: float) -> void:
	if delay_sec > 0.0:
		delay_sec = maxf(0.0, delay_sec - delta)
		return
	
	elapsed_sec = elapsed_sec - delta if active else elapsed_sec + (delta * hide_time_scale)
	
	if (active and elapsed_sec == 0.0) or (not active and elapsed_sec == duration_sec):
		set_process(false)
		emit_signal(&"opened" if active else &"closed")


func _physics_process(delta: float) -> void:
	if not target or elapsed_sec < duration_sec: return
	set_elapsed(elapsed_sec)


func set_hide_mode(val: int) -> void:
	if hide_mode == val: return
	
	hide_mode = val


func set_side(val: Side) -> void:
		side = val
		calculate_delta()
		set_elapsed(elapsed_sec)


func set_active(val: bool) -> void:
	active = val
	set_process(true)
	emit_signal(&"opening" if val else &"closing")


func set_target(val: Control) -> void:
	target = val
	set_elapsed(elapsed_sec)
	set_physics_process(val != null)


func set_elapsed(val: float) -> void:
	elapsed_sec = clampf(val, 0.0, duration_sec)
	
	if not is_node_ready(): return
	
	var tween_trans: Tween.TransitionType = trans_type_show if visible else trans_type_hide
	var tween_ease: Tween.EaseType = ease_type_show if visible else ease_type_hide
	
	for child: Control in get_child_controls():
		if hide_mode == 1:
			modulate.a = float(elapsed_sec != duration_sec or Engine.is_editor_hint() or not hide_mode)
		if hide_mode == 2:
			visible = elapsed_sec != duration_sec or Engine.is_editor_hint() or not hide_mode
		
		var position_delta: Vector2 = target.global_position - global_position if target else target_position_delta
		var scale_delta: Vector2 = get_target_scale() - base_scale
		
		child.position = Tween.interpolate_value(Vector2(), position_delta, elapsed_sec, duration_sec, tween_trans, tween_ease)
		
		if scale_enabled: 
			child.scale = Tween.interpolate_value(base_scale, scale_delta, elapsed_sec, duration_sec, tween_trans, tween_ease)
		if target:
			child.rotation = Tween.interpolate_value(rotation, target.rotation - rotation, elapsed_sec, duration_sec, tween_trans, tween_ease)


func _notification(what: int) -> void:
	match what:
		
		NOTIFICATION_READY:
			mouse_filter = MOUSE_FILTER_PASS
			set_notify_transform.call_deferred(true)
			if not Engine.is_editor_hint():
				var viewport:= get_viewport()
				viewport.size_changed.connect(_on_viewport_size_changed)
				screen = get_viewport_rect().size
			
		NOTIFICATION_TRANSFORM_CHANGED:
			calculate_delta()
		
		
		
		NOTIFICATION_INTERNAL_PROCESS when target:
			set_elapsed(elapsed_sec)
		
		NOTIFICATION_PRE_SORT_CHILDREN:
			var new_size: Vector2 = Vector2(maxf(size.x, get_combined_minimum_size().x), maxf(size.y, get_combined_minimum_size().y))
			set_size.call_deferred(new_size)
			#size.x = maxf(size.x, get_combined_minimum_size().x)
			#size.y = maxf(size.y, get_combined_minimum_size().y)
			
			for child: Control in get_child_controls():
				child.size.x = new_size.x
				child.size.y = new_size.y
			
		NOTIFICATION_SORT_CHILDREN:
			for child: Control in get_child_controls():
				child.position = Vector2.ZERO
			calculate_delta()


func calculate_delta() -> void: 
	var scaled_size: = size * (Vector2.ONE - (base_scale - target_scale)) 
	match side:
		SIDE_LEFT: 
			target_position_delta.x = -global_position.x - scaled_size.x
			target_position_delta.y = (base_scale.x - target_scale.x) * size.x / 2.0
		SIDE_RIGHT:
			target_position_delta.x = screen.x - global_position.x
		SIDE_TOP:
			target_position_delta.y = -global_position.y - scaled_size.y
		SIDE_BOTTOM:
			target_position_delta.y = screen.y - global_position.y
	
	var axis:= Vector2.AXIS_Y if side % 2 == 0 else Vector2.AXIS_X
	target_position_delta[axis] = -(target_scale[axis] - base_scale[axis]) * size[axis] / 2.0 
	#print("Target Position Delta: %01.01v" % target_position_delta)
	set_elapsed(elapsed_sec)


func get_target_scale() -> Vector2:
	var tscale: Vector2 = target_scale
	if target:
		tscale.x = (target.size.x * target.scale.x)/maxf(size.x, 0.01)
		tscale.y = (target.size.y * target.scale.y)/maxf(size.y, 0.01)
	return tscale


func update_pivot() -> void:
	if not auto_adjust_pivot: return
	var pivot_vector:= Vector2()
	if target:
		const SQRT_HALF: float = 0.70710678118654752
		var dir:Vector2 = (global_position + size/2.0).direction_to(target.global_position + target.size/2.0 )
		pivot_vector.x = lerpf(0.0,  size.x, clampf(inverse_lerp(-SQRT_HALF, SQRT_HALF, dir.x), 0.0, 1.0)) 
		pivot_vector.y = lerpf(0.0,  size.y, clampf(inverse_lerp(-SQRT_HALF, SQRT_HALF, dir.y), 0.0, 1.0))
	
	else:
		pivot_vector.x = size.x * 0.5 if side % 2 == 1 else size.x * float(side == SIDE_RIGHT)
		pivot_vector.y = size.y * 0.5 if side % 2 == 0 else size.y * float(side == SIDE_BOTTOM)
		
	for child: Control in get_child_controls():
		child.pivot_offset = pivot_vector


func _on_viewport_size_changed() -> void:
	if not is_inside_tree(): return
	screen = get_viewport_rect().size
	

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	if debug_rect_visible: 
		draw_rect(Rect2(Vector2.ZERO, size), RECT_COLOR, false)
	if target_rect_visible:
		draw_set_transform(target.global_position - global_position if target else target_position_delta, target.rotation - rotation if target else rotation, get_target_scale())
		draw_rect(Rect2(0,0,size.x, size.y), TARGET_RECT_COLOR, false, 2.0)


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


func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return PackedInt32Array()
func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return PackedInt32Array()

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"delay_sec":
			property.usage |= PROPERTY_USAGE_EDITOR
	
		&"elapsed_sec":
			property.usage |= PROPERTY_USAGE_EDITOR
			property.hint = PROPERTY_HINT_RANGE
			property.hint_string = "0.0,%01.01f,0.1,suffix:sec," % duration_sec
			
		&"side", &"target_scale" when target:
			property.usage &= ~(PROPERTY_USAGE_EDITOR)
		
		&"scale_target_side", &"target_scale_delta",&"base_scale", &"target_scale" when not scale_enabled:
			property.usage &= ~(PROPERTY_USAGE_EDITOR)
			
			
