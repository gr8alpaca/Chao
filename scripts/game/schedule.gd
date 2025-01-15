@tool
class_name Schedule extends Node
const GROUP: StringName = &"Schedule"
const SCHEDULE_SIZE: int = 4

signal changed

var schedule: Array[Activity]: set = set_schedule

func _init() -> void:
	add_to_group(GROUP)
	schedule.resize(SCHEDULE_SIZE)

func add_activity(activity: Activity) -> void:
	for i : int in SCHEDULE_SIZE:
		if schedule[i] != null: continue
		set_activity(i, activity)
		return
	
	set_activity(SCHEDULE_SIZE-1, activity)

func set_activity(week_index: int, activity: Activity) -> void:
	#print("Setting week index %d to %s" % [week_index, activity.name])
	if schedule[week_index] == activity: return
	schedule[week_index] = activity
	changed.emit()

func get_activity(week_index: int) -> Activity:
	return schedule[week_index] if week_index < SCHEDULE_SIZE else null

func remove_last_activity() -> void:
	for i : int in SCHEDULE_SIZE:
		if schedule[SCHEDULE_SIZE - 1 - i] == null: continue
		set_activity(SCHEDULE_SIZE - 1 - i, null)
		return

func clear() -> void:
	set_schedule()

func is_empty() -> bool:
	for i: int in SCHEDULE_SIZE:
		if schedule[i]: return false
	return true

func is_filled() -> bool:
	for i: int in SCHEDULE_SIZE:
		if not schedule[i]: return false
	return true

func set_schedule(val: Array[Activity] = []) -> void:
	schedule.assign(val)
	schedule.resize(SCHEDULE_SIZE)
	changed.emit()
