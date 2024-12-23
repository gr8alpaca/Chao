@tool
class_name ScheduleSlot extends Panel

const LABEL_Y_OFFSET: int = 16

signal activity_changed

var label: Label = Label.new()
var button: Button = Button.new()

@export var activity: Exercise: set = set_activity
var time_offset: float = 0.0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	label.custom_minimum_size = Vector2(custom_minimum_size.x, 32)
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "Week 1"
	
	add_child(label, false, INTERNAL_MODE_FRONT)
	label.resized.connect(position_label, CONNECT_DEFERRED)
	
	
	time_offset = randf() 
	
	
	add_child(button, false, Node.INTERNAL_MODE_FRONT)
	button.text = "✗"
	button.flat = true
	button.pressed.connect(set_activity.bind(null))
	button.focus_mode = Control.FOCUS_NONE



func _process(delta: float) -> void:
	const MAX_FLOAT_DISTANCE: float = 4.0
	const CYCLE_TIME_SECS: float = 5.0
	
	var time:= Time.get_ticks_msec() / 1000.0 * TAU / CYCLE_TIME_SECS + time_offset * CYCLE_TIME_SECS
	button.modulate.a += delta
	button.position = Vector2(sin(time), cos(1.2*time)) * MAX_FLOAT_DISTANCE - button.size/2.0
	

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and "activity" in data


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data.get("source"):
		data.source.activity = activity
	activity = data.activity
	

func _get_drag_data(at_position: Vector2) -> Variant:
	if activity:
		var lbl := Label.new()
		lbl.text = activity.get_drag_preview()
		set_drag_preview(lbl)
	return {
		activity = activity,
		source = self
		}

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
	
	var draw_pos: Vector2 = (size - string_size)/Vector2(2.0, 2.0)  + Vector2(0.0, font.get_ascent(font_size))
	draw_string_outline(font, draw_pos, activity_string, 0, -1, font_size, FONT_OUTLINE_SIZE, Color.BLACK)
	draw_string(font, draw_pos, activity_string, 0, -1, font_size)
	

func set_activity(val: Exercise) -> void:
	activity = val
	set_process(activity != null)
	button.visible = activity != null
	button.modulate.a = 0.0 if not activity else button.modulate.a
	button.disabled = activity == null
	queue_redraw()
	activity_changed.emit()


func set_label_week(week_index: int) -> void:
	label.text = "Week %d" % maxi(week_index, 1)


func position_label() -> void:
	label.position = Vector2(0.0, size.y + LABEL_Y_OFFSET)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask&MOUSE_BUTTON_LEFT and event.double_click:
		activity = null
		accept_event()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY when not activity and not Engine.is_editor_hint():
			button.modulate.a = 0.0
			set_process(false)
		
		NOTIFICATION_RESIZED:
			position_label()
		
		NOTIFICATION_PARENTED:
			label.text = "Week %d" % (get_index() + 1)
