@tool
class_name Exercise extends Activity


@export_range(-MAX_DELTA, MAX_DELTA, 1) var run: int = 0
@export_range(-MAX_DELTA, MAX_DELTA, 1) var swim: int = 0
@export_range(-MAX_DELTA, MAX_DELTA, 1) var fly: int = 0
@export_range(-MAX_DELTA, MAX_DELTA, 1) var power: int = 0


func get_stat_changes() -> PackedStringArray:
	var stat_changes: PackedStringArray
	for stat: StringName in [&"run", &"swim", &"fly", &"power"]:
		if get(stat) != 0: stat_changes.push_back(stat)
	return stat_changes
