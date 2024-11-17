@tool
class_name ScheduleSlot extends Panel

const LABEL_Y_OFFSET: int = 16

var label: Label = Label.new()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	custom_minimum_size = Vector2(200, 200)
	label.custom_minimum_size = Vector2(custom_minimum_size.x, 32)
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "Week 1"
	
	add_child(label, false, INTERNAL_MODE_FRONT)
	label.resized.connect(position_label, CONNECT_DEFERRED)


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	pass


func _get_drag_data(at_position: Vector2) -> Variant:
	return null



func set_label_week(week_index: int) -> void:
	label.text = "Week %d" % maxi(week_index, 1)
	
	

func position_label() -> void:
	label.position = Vector2(0.0, size.y + LABEL_Y_OFFSET)
	

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			position_label()

		NOTIFICATION_PARENTED:
			label.text = "Week %d" % (get_index() + 1)
