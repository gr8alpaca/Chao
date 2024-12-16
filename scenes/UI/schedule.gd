@tool
class_name ScheduleUI extends VBoxContainer

const SCHEDULE_SLOT_COUNT: int = 4
const BOTTOM_OFFSET: int = 64

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


func open(delay_sec: float = 0.0) -> void:
	set_mini_visible(true)
	set_slots_visible(true, delay_sec)

func close() -> void:
	set_slots_visible(false)
	set_mini_visible(false)

func add_activity(activity: Exercise) -> void:
	for slot: ScheduleSlot in slots:
		if slot.activity==null or slots[-1] == slot:
			slot.activity = activity
			break

func remove_last_activity() -> void:
	for i: int in slots.size():
		i = slots.size() - 1 - i
		if slots[i].activity != null:
			slots[i].activity = null
			break

func set_mini_visible(val: bool) -> void:
	mini_visible = val
	targets_container.active = val

func set_slots_visible(slot_visible: bool, delay_sec: float = 0.0) -> void:
	for tween_container: Tweak in tweeners:
		if slot_visible: 
			tween_container.open(delay_sec)
		else: 
			tween_container.close()

func _on_schedule_activity(activity: Exercise) -> void:
	add_activity(activity)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event.is_action_pressed(&"back"):
		remove_last_activity()
		accept_event()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			Event.schedule_activity.connect(_on_schedule_activity)
		
		NOTIFICATION_MOUSE_ENTER when mini_visible:
			pass
		
		NOTIFICATION_RESIZED:
			pivot_offset = size / Vector2(2.0, 1)
