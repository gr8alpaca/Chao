@tool
class_name Activity extends Resource

## Anything that fills a week slot in the schedule
const DEFAULT_ACTIVITY_SCENE: PackedScene = preload("res://scenes/Activities/activity_scene.tscn")

@export var name: StringName = &"Invalid":
	set(val):
		name = val
		resource_name = val

@export_enum("DownDouble:-2", "DownSingle:-1", "None:0", "UpSingle:1", "UpDouble:2")
var fatigue: int = 1

@export var scene: PackedScene

@export var drag_unicode_code: int = 128170:
	set(val):
		drag_unicode_code = val
		symbol = char(val)
		notify_property_list_changed()


@export_custom(0, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_DEFAULT)
var symbol: String

func get_drag_preview() -> String:
	return symbol + " " + name
	
func get_stat_changes() -> PackedStringArray:
	return PackedStringArray()

func get_scene() -> PackedScene:
	return scene if scene else DEFAULT_ACTIVITY_SCENE
