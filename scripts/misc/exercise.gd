@tool
class_name Exercise extends Activity

## All exercises cause fatigue.
@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var fatigue: int = -1

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var run: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var swim: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var fly: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var power: int = 0

## Does NOT include fatigue!
func get_stat_changes() -> PackedStringArray:
	var stat_changes: PackedStringArray
	for stat: StringName in [&"run", &"swim", &"fly", &"power"]:
		if get(stat) != 0: stat_changes.push_back(stat)
	return stat_changes
