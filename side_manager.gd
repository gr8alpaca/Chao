@tool
class_name SideManager extends Control

class PosData extends RefCounted:
	signal finished
	var control: Control
	var debug_rect: ReferenceRect
	
	var trans_type:= Tween.TRANS_ELASTIC
	var ease_type:= Tween.EASE_IN_OUT 
	
	var position_initial: float = 0.0
	var position_delta: float = 0.0
	var is_left_right: bool = true

	
	var duration: float = 1.3
	var elapsed: float = 0.0:
		set(val): elapsed = clampf(val, 0.0, duration)
	
	var active: bool = false
	
	func update_process(delta: float) -> void:
		elapsed = elapsed - delta if active else elapsed + delta
		if is_left_right:
			control.global_position.x = Tween.interpolate_value(position_initial, position_delta, elapsed, duration, trans_type, ease_type)
		else:
			control.global_position.y = Tween.interpolate_value(position_initial, position_delta, elapsed, duration, trans_type, ease_type)
		if active and elapsed <= 0.0:
			print("Emitting finished...")
			finished.emit()
	
	func get_debug_rect() -> ReferenceRect:
		var debug_rect : ReferenceRect = get_meta(&"debug", ReferenceRect.new())
		debug_rect.global_position = control.global_position
		debug_rect.size = control.size if control else Vector2.ZERO
		debug_rect.border_color = Color.FUCHSIA
		debug_rect.border_width = 2.0
		set_meta(&"debug", debug_rect)
		return debug_rect
	
	func _to_string() -> String:
		return "PosData<%d> Active=%s\tControl: %s" % [get_instance_id(), active, control.name if control else "<NULL>", ]


var pos_data: Array[PosData]

@export var test_hide: Control:
	set(val): if val: hide_control(val)
		
@export var test_show: Control:
	set(val): if val: show_control(val)
		

func _ready() -> void:
	top_level = true
	set_anchors_preset(Control.PRESET_FULL_RECT)


func hide_control(item: Control, side: Side = SIDE_LEFT, duration: float = 1.3, trans_type:=Tween.TRANS_ELASTIC, ease_type:= Tween.EASE_IN_OUT, ) -> void:
	var pos: PosData = get_pos(item)
	if not pos: 
		pos = PosData.new()
		pos.control = item
		pos.duration = 5.0
		pos.trans_type = Tween.TRANS_LINEAR #trans_type
		pos.ease_type = ease_type
		pos.position_initial = item.global_position.y if side % 2 else item.global_position.x
		match side:
			SIDE_TOP: 
				pos.position_delta = size.y - pos.position_initial
			SIDE_LEFT: 
				pos.position_delta = -item.size.x - pos.position_initial
			SIDE_BOTTOM: 
				pos.position_delta = -item.size.y - pos.position_initial
			SIDE_RIGHT:
				pos.position_delta = size.x - pos.position_initial
				
			
		pos.finished.connect(_on_pos_finished.bind(pos))
		add_child(pos.get_debug_rect(), false, Node.INTERNAL_MODE_FRONT)
		pos_data.push_back(pos)
		
	pos.active = false
		

func show_control(control: Control) -> void:
	var pos: PosData = get_pos(control)
	if not pos: return
	pos.active = true


func _on_pos_finished(pos: PosData) -> void:
	print("POS FINISHED:\n-\t%s" % pos)
	pos_data.erase(pos)
	var rect: ReferenceRect = pos.get_meta(&"debug")
	if rect:
		remove_child(rect)
		rect.free()
	
	if pos.debug_rect: pos.debug_rect.free()
	

func _process(delta: float) -> void:
	for pos: PosData in pos_data:
		pos.update_process(delta)
		
		
func get_pos(control: Control) -> PosData:
	for pos_data: PosData in pos_data:
		if pos_data.control == control: return pos_data
	return null
