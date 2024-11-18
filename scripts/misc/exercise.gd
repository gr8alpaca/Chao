@tool
class_name Exercise extends Resource


@export var name: StringName = &"Invalid":
	set(val):
		name = val
		resource_name = val

@export var drag_unicode_code: int = 128170:
	set(val):
		drag_unicode_code = val
		symbol = char(val)
		notify_property_list_changed()

@export_custom(0, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT)
var symbol: String

## All exercises cause fatigue.
@export_enum("Standard:-1", "Double:-2")
var fatigue: int = -1

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var run: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var swim: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var fly: int = 0

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var power: int = 0


func get_drag_preview() -> String:
	return symbol + " " + name

## Does NOT include fatigue!
func get_stat_changes() -> PackedStringArray:
	var stat_changes: PackedStringArray
	for stat: StringName in [&"run", &"swim", &"fly", &"power"]:
		if get(stat) != 0: stat_changes.push_back(stat)
	return stat_changes
