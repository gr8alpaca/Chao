@tool
class_name ScheduleUI extends VBoxContainer

const SCHEDULE_SLOT_COUNT: int = 4
const BOTTOM_OFFSET: int = 64

@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var mini_visible: bool: set = set_mini_visible

@export_group("Node References")
@export var start_week_tweak: Tweak

var schedule: Schedule

func open(delay_sec: float = 0.0) -> void:
	const START_BUTTON_BONUS_DELAY: float = 2.0
	set_mini_visible(true)
	set_slots_visible(true, delay_sec)
	create_tween().tween_callback(update_start_button).set_delay(delay_sec + START_BUTTON_BONUS_DELAY)

func close() -> void:
	set_slots_visible(false)
	set_mini_visible(false)
	update_start_button()


func remove_last_activity() -> void:
	schedule.remove_last_activity()


func update_start_button() -> void:
	if not $SlotsTweak.active:
		start_week_tweak.close()
		return
	
	if schedule.is_filled():
		start_week_tweak.open()
	else:
		start_week_tweak.close()


func set_mini_visible(val: bool) -> void:
	mini_visible = val
	$TargetsContainer.active = val


func set_slots_visible(slot_visible: bool, delay_sec: float = 0.0) -> void:
	set_process_unhandled_input(slot_visible)
	if slot_visible: 
		$SlotsTweak.open(delay_sec)
	else:
		$SlotsTweak.close()


func _on_start_week_closing(start_week_button: BaseButton) -> void:
	start_week_button.disabled = true
	if start_week_button.has_focus(): 
		start_week_button.release_focus()
	start_week_button.focus_mode = Control.FOCUS_NONE

func _on_start_week_opened(start_week_button: BaseButton) -> void:
	start_week_button.disabled = false
	start_week_button.focus_mode = Control.FOCUS_ALL


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event.is_action_pressed(&"back"):
		remove_last_activity()
		accept_event()

func get_slots() -> Array[ScheduleSlot]:
	var slots: Array[ScheduleSlot]
	slots.assign(%Slots.get_children())
	return slots


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			schedule = get_tree().get_first_node_in_group(Schedule.GROUP)
			if Engine.is_editor_hint():
				return
			assert(start_week_tweak != null, "No start week tweak set!")
			var start_week_button: BaseButton = start_week_tweak.get_child(0)
			start_week_tweak.close()
			start_week_tweak.opened.connect(_on_start_week_opened.bind(start_week_button))
			start_week_tweak.closing.connect(_on_start_week_closing.bind(start_week_button))
			schedule.changed.connect(update_start_button)
			
			
		NOTIFICATION_MOUSE_ENTER when mini_visible:
			pass
		
		NOTIFICATION_RESIZED:
			pivot_offset = size / Vector2(2.0, 1.0)
		
