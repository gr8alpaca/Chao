@tool
class_name ScheduleUI extends VBoxContainer

const SCHEDULE_SLOT_COUNT: int = 4
const BOTTOM_OFFSET: int = 64

signal schedule_changed

@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var mini_visible: bool: set = set_mini_visible

@export_group("Node References")
@export var tweeners: Array[Tweak] 
@export var slots: Array[ScheduleSlot]:
	set(val):
		slots = val
		for i: int in slots.size():
			if slots[i]: slots[i].set_label_week(i+1)


@export var targets_container: Tweak
@export var start_week_tweak: Tweak

func open(delay_sec: float = 0.0) -> void:
	const START_BUTTON_BONUS_DELAY: float = 2.0
	set_mini_visible(true)
	set_slots_visible(true, delay_sec)
	create_tween().tween_callback(update_start_button).set_delay(delay_sec + START_BUTTON_BONUS_DELAY)

func close() -> void:
	set_slots_visible(false)
	set_mini_visible(false)
	update_start_button()

func add_activity(activity: Activity) -> void:
	for slot: ScheduleSlot in slots:
		if slot.activity==null or slots[-1] == slot:
			slot.activity = activity
			schedule_changed.emit()
			break


func remove_activity(index: int) -> void:
	slots[index].clear()
	schedule_changed.emit()


func remove_last_activity() -> void:
	for i: int in slots.size():
		i = slots.size() - 1 - i
		if slots[i].activity != null:
			remove_activity((i))
			break


func clear_slots() -> void:
	for slot: ScheduleSlot in slots:
		slot.clear()


func update_start_button() -> void:
	if not tweeners[0].active:
		start_week_tweak.close()
		return
		
	for slot: ScheduleSlot in slots:
		if slot.activity == null:
			start_week_tweak.close()
			return
	start_week_tweak.open()
	

func set_mini_visible(val: bool) -> void:
	mini_visible = val
	targets_container.active = val


func set_slots_visible(slot_visible: bool, delay_sec: float = 0.0) -> void:
	set_process_unhandled_input(slot_visible)
	for tween_container: Tweak in tweeners:
		if slot_visible: 
			tween_container.open(delay_sec)
		else:
			tween_container.close()


func _on_schedule_activity(activity: Activity) -> void:
	add_activity(activity)

func _on_start_week_closing(start_week_button: BaseButton) -> void:
	start_week_button.disabled = true
	if start_week_button.has_focus(): 
		start_week_button.release_focus()
	start_week_button.focus_mode = Control.FOCUS_NONE
	
func _on_start_week_opened(start_week_button: BaseButton) -> void:
	start_week_button.disabled = false
	start_week_button.focus_mode = Control.FOCUS_ALL

func get_activities() -> Array[Activity]:
	var result: Array[Activity]
	for i: int in slots.size():
		result.push_back(slots[i].activity)
	return result


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event.is_action_pressed(&"back"):
		remove_last_activity()
		accept_event()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			if Engine.is_editor_hint():
				return
			assert(start_week_tweak != null, "No start week tweak set!")
			var start_week_button: BaseButton = start_week_tweak.get_child(0)
			start_week_tweak.close()
			start_week_tweak.opened.connect(_on_start_week_opened.bind(start_week_button))
			start_week_tweak.closing.connect(_on_start_week_closing.bind(start_week_button))
			for slot: ScheduleSlot in slots:
				slot.activity_changed.connect(update_start_button)
			
			
		NOTIFICATION_MOUSE_ENTER when mini_visible:
			pass
		
		NOTIFICATION_RESIZED:
			pivot_offset = size / Vector2(2.0, 1.0)
