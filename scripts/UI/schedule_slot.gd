@tool
class_name ScheduleSlot extends Panel

const LABEL_Y_OFFSET: int = 16

var label: Label = Label.new()
var button: Button = Button.new()

var schedule: Schedule

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	label.custom_minimum_size = Vector2(custom_minimum_size.x, 32)
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "Week 1"
	
	
	add_child(label, false, INTERNAL_MODE_FRONT)
	label.resized.connect(position_label, CONNECT_DEFERRED)
	
	add_child(button, false, Node.INTERNAL_MODE_FRONT)
	button.text = "✗"
	button.flat = true
	button.pressed.connect(set_activity.bind(null))
	button.focus_mode = Control.FOCUS_NONE
	button.position = -button.get_combined_minimum_size()/2.0
	button.modulate.a = 0.0
	
	for item: CanvasItem in [label, button, self]:
		item.material = preload("res://resources/materials/float_material.tres").duplicate()
		item.material.set_shader_parameter(&"time_offset", randf() * TAU )

func _ready() -> void:
	schedule = get_tree().get_first_node_in_group(Schedule.GROUP)
	schedule.changed.connect(_on_schedule_changed)

func _on_schedule_changed() -> void:
	const BUTTON_FADE_SEC: float = 0.25
	create_tween().tween_property(button, ^"modulate:a", float(get_activity() != null), BUTTON_FADE_SEC)
	
	if get_activity() != null and button.has_focus():
		button.release_focus()
	
	queue_redraw()


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and "activity" in data


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data.get("source") and not (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_SHIFT)):
		data.source.set_activity(get_activity())
	set_activity(data.activity)
	


func _get_drag_data(at_position: Vector2) -> Variant:
	var activity: Activity = get_activity()
	if activity:
		var lbl := Label.new()
		lbl.text = activity.get_drag_preview()
		set_drag_preview(lbl)
	return {
		activity = activity,
		source = self,
		}

func _draw() -> void:
	var activity: Activity = get_activity()
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
	
	var draw_pos: Vector2 = (size - string_size)/Vector2(2.0, 2.0)  + Vector2(0.0, font.get_ascent(font_size))
	draw_string_outline(font, draw_pos, activity_string, 0, -1, font_size, FONT_OUTLINE_SIZE, Color.BLACK)
	draw_string(font, draw_pos, activity_string, 0, -1, font_size)


func set_label_week(week_index: int) -> void:
	label.text = "Week %d" % maxi(week_index, 1)

func get_activity() -> Activity:
	return schedule.get_activity(get_index()) if schedule else null
func set_activity(activity: Activity) -> void:
	schedule.set_activity(get_index(), activity)
func clear() -> void:
	set_activity(null)

func position_label() -> void:
	label.position = Vector2(0.0, size.y + LABEL_Y_OFFSET)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask&MOUSE_BUTTON_LEFT and event.double_click:
		clear()
		accept_event()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			position_label()
