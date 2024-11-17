@tool
class_name ScheduleUI extends VBoxContainer

const SCHEDULE_SLOT_COUNT: int = 4
const BOTTOM_OFFSET: int = 64

@export var weeks_max_size: Vector2i = Vector2i(1200, 256):
	set(val):
		weeks_max_size = val
		queue_redraw()

@export var debug: bool:
	set(val):
		if not val: return
		var method_name:= &"open" if not get_child(0).get_child(0).visible else &"close"
		print("Calling ", method_name)
		call(method_name)


@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var mini_visible: bool = true: set = set_mini_visible

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

func set_mini_visible(val: bool) -> void:
	mini_visible = val
	targets_container.active = val

func set_slots_visible(slot_visible: bool, delay_sec: float = 0.0) -> void:
	for tween_container: Tweak in tweeners:
		if slot_visible: 
			tween_container.open(delay_sec)
		else: 
			tween_container.close()



func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER when mini_visible:
			pass
		
		
		NOTIFICATION_RESIZED:
			pivot_offset = size / Vector2(2.0, 1)
