@tool
class_name ScheduleSlot extends Panel

const LABEL_Y_OFFSET: int = 16

var label: Label = Label.new()

@export var activity: Exercise: set = set_activity


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
	return data is Exercise


func _drop_data(at_position: Vector2, data: Variant) -> void:
	activity = data


func _get_drag_data(at_position: Vector2) -> Variant:
	return activity


func _draw() -> void:
	if not activity: return
	const MARGINS_SIZE: int = 8
	const FONT_OUTLINE_SIZE: int = 4
	var font:= get_theme_default_font()
	var font_size:= get_theme_default_font_size()
	
	var activity_string: String = activity.get_drag_preview()
	var string_size:= font.get_string_size(activity_string, 0, -1, font_size)
	
	while font_size > 0 and string_size.x > size.x - MARGINS_SIZE:
		font_size -= 1
		string_size = font.get_string_size(activity_string, 0, -1, font_size)
		
	var draw_pos: Vector2 = (size - string_size)/Vector2(2, 2)
	#print("SIZE: %01.01v\t|\tDRAW POS: %01.01v" % [ssize, draw_pos])
	#draw_set_transform(draw_pos)
	draw_string_outline(font, draw_pos, activity_string, 0, -1, font_size, FONT_OUTLINE_SIZE, Color.BLACK)
	draw_string(font, draw_pos, activity_string, 0, -1, font_size)

func set_activity(val: Exercise) -> void:
	activity = val
	queue_redraw()


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
