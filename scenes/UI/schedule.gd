@tool
class_name ScheduleUI extends Container

const MIN_SIZE: Vector2i = Vector2i(1200, 256)
const SCHEDULE_SLOT_COUNT: int = 4
const BOTTOM_OFFSET: int = 64

@export var weeks_max_size: Vector2i = Vector2i(1200, 256):
	set(val):
		weeks_max_size = val
		queue_redraw()


var schedule_visible: bool


@export var debug: bool:
	set(val):
		if not val: return
		initialize_schedule_slots()


func _init() -> void:
	custom_minimum_size = MIN_SIZE


func show_schedule() -> void:
	const DURATION: float = 2.2
	const INTERVAL: float = 0.4
	schedule_visible = true
	var slots: Array[ScheduleSlot] = get_slots()
	var rects: Array[Rect2] = get_slot_rects()
	var bottom_offset: float = size.y + BOTTOM_OFFSET
	for i: int in slots.size():
		slots[i].pivot_offset = slots[i].size / Vector2(2.0, 1.0)
		slots[i].visible = false
		create_tween().tween_callback(Util.tween_position.bind(slots[i], Vector2(slots[i].position.x, bottom_offset), rects[i].position, DURATION)).set_delay(i * INTERVAL)


func hide_schedule() -> void:
	for slot: ScheduleSlot in get_slots():
		Util.tween_fade(slot)
	schedule_visible = false


func initialize_schedule_slots() -> void:
	for slot: ScheduleSlot in get_slots():
		slot.free()
	
	for i: int in SCHEDULE_SLOT_COUNT:
		var slot: ScheduleSlot = ScheduleSlot.new()
		# var con: EdgeContainer = EdgeContainer.new()
		# con.side = SIDE_BOTTOM

		# con.add_child(slot)
		add_child(slot)
		slot.name = "Slot%d" % (i + 1)
		slot.owner = owner

	position_slots()
	

func position_slots() -> void:
	var slots: Array[ScheduleSlot] = get_slots()
	var rects: Array[Rect2] = get_slot_rects()
	for i: int in slots.size():
		slots[i].position = rects[i].position


func get_slot_rects() -> Array[Rect2]:
	var rects: Array[Rect2]
	var slots: Array[ScheduleSlot] = get_slots()
	var slot_size: Vector2 = Vector2(size.x / slots.size(), size.y)
	for i: int in slots.size():
		rects.push_back(Rect2(slot_size.x * i + (slot_size.x - slots[i].size.x) / 2.0, (slot_size.y - slots[i].size.y) / 2.0, slots[i].size.x, slots[i].size.y))
	return rects


func get_screen_size() -> Vector2i:
	return Vector2i(ProjectSettings.get("display/window/size/viewport_width"), ProjectSettings.get("display/window/size/viewport_height")) if Engine.is_editor_hint() else get_viewport().size


func get_slots() -> Array[ScheduleSlot]:
	var slots: Array[ScheduleSlot]
	for child: Node in get_children():
		if not child is ScheduleSlot: continue
		slots.push_back(child as ScheduleSlot)
	return slots

func _get_minimum_size() -> Vector2:
	return Vector2i(1200, 256)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			position_slots()
		
		NOTIFICATION_RESIZED:
			print("Resize called... @%1.02f sec" % (Time.get_ticks_msec() / 1000))
			var screen_size: Vector2i = get_screen_size()
			position.x = (screen_size.x - size.x) / 2.0
			position.y = screen_size.y - size.y - BOTTOM_OFFSET
			pivot_offset = size / Vector2(2.0, 1)
