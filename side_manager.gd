@tool
class_name SideManager extends Control

class PosData extends RefCounted:
	signal finished
	var control: Control
	
	var trans_type := Tween.TRANS_ELASTIC
	var ease_type := Tween.EASE_IN_OUT
	
	var position_initial: float = 0.0
	var position_delta: float = 0.0
	var is_left_right: bool = true
	
	var duration: float = 1.3
	var elapsed: float = 0.0:
		set(val):
			elapsed = clampf(val, 0.0, duration)
			if elapsed == duration: control.hide()
				
	
	var is_hidden: bool = true:
		set(val):
			is_hidden = val
			if not is_hidden: control.show()
				

	func update_process(delta: float) -> void:
		elapsed = elapsed + delta if is_hidden else elapsed - delta
		if is_left_right:
			control.global_position.x = Tween.interpolate_value(position_initial, position_delta, elapsed, duration, trans_type, ease_type)
		else:
			control.global_position.y = Tween.interpolate_value(position_initial, position_delta, elapsed, duration, trans_type, ease_type)
		if not is_hidden and elapsed <= 0.0:
			# print("Emitting finished...")
			finished.emit()
	
	func get_debug_rect() -> ReferenceRect:
		var debug_rect: ReferenceRect = get_meta(&"debug", ReferenceRect.new())
		debug_rect.global_position = control.global_position
		debug_rect.size = control.size if control else Vector2.ZERO
		debug_rect.border_color = Util.DEBUG_COLOR
		debug_rect.border_width = 2.0
		set_meta(&"debug", debug_rect)
		return debug_rect
	
	func _to_string() -> String:
		return "PosData<%d> Active=%s\tControl: %s" % [get_instance_id(), is_hidden, control.name if control else "<NULL>", ]


var pos_data: Array[PosData]
		

func _ready() -> void:
	top_level = true
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset.call_deferred(Control.PRESET_FULL_RECT, )


func hide_control(item: Control, side: Side = SIDE_LEFT, duration: float = 1.3, trans_type:=Tween.TRANS_ELASTIC, ease_type:=Tween.EASE_IN_OUT, ) -> void:
	var pos: PosData = get_or_add_pos_data(item, side, duration, trans_type, ease_type)
	pos.is_hidden = true
	

func show_control(control: Control, duration: float = 0.0, trans_type:= -1, ease_type:= -1) -> void:
	var pos: PosData = get_pos(control)
	if not pos: return
	
	if trans_type >= 0:
		pos.trans_type = trans_type as Tween.TransitionType
	if ease_type >= 0:
		pos.ease_type = ease_type as Tween.EaseType


	if duration > 0.0:
		var t: float = pos.elapsed / pos.duration if duration > 0.0 else 1.0
		pos.duration = duration
		pos.elapsed = duration * t
		
	pos.is_hidden = false

func get_or_add_pos_data(item: Control, side: Side = SIDE_LEFT, duration: float = 1.3, trans_type:=Tween.TRANS_ELASTIC, ease_type:=Tween.EASE_IN_OUT, ) -> PosData:
	var pos: PosData = get_pos(item)
	if pos: return pos
	pos = PosData.new()
	pos.control = item
	pos.duration = duration
	pos.trans_type = trans_type
	pos.ease_type = ease_type
	pos.is_left_right = side % 2 == 0
	pos.position_initial = item.global_position.x if pos.is_left_right else item.global_position.y
	match side:
		SIDE_TOP:
			pos.position_delta = -item.size.y - pos.position_initial
		SIDE_LEFT:
			pos.position_delta = -item.size.x - pos.position_initial
		SIDE_BOTTOM:
			pos.position_delta = size.y - pos.position_initial
		SIDE_RIGHT:
			pos.position_delta = size.x - pos.position_initial
			
		
	pos.finished.connect(_on_pos_finished.bind(pos))
	if Engine.is_editor_hint():
		add_child(pos.get_debug_rect())
	pos_data.push_back(pos)
	return pos


func _on_pos_finished(pos: PosData) -> void:
	# print("POS FINISHED:\n-\t%s" % pos)
	pos_data.erase(pos)
	var rect: ReferenceRect = pos.get_meta(&"debug")
	if rect:
		remove_child(rect)
		rect.free()


func _process(delta: float) -> void:
	for pos: PosData in pos_data:
		pos.update_process(delta)
		
		
func get_pos(control: Control) -> PosData:
	for pos_data: PosData in pos_data:
		if pos_data.control == control: return pos_data
	return null
