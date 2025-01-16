@tool
class_name Activity extends Resource

## Anything that fills a week slot in the schedule
const DEFAULT_ACTIVITY_SCENE: PackedScene = preload("res://scenes/Activities/activity_scene.tscn")

## For stat modifier ranges
const MAX_DELTA: int = 2

## For stat rolls
const XP_DELTA_MAX: int = 2

const XP_DELTA_BASE: PackedInt32Array = [0, 3, 6, -2, -4]


@export var name: StringName = &"Invalid":
	set(val):
		name = val
		resource_name = val

@export_range(-MAX_DELTA, MAX_DELTA, 1) var fatigue: int = 1

@export var scene: PackedScene

@export var drag_unicode_code: int = 128170

func get_drag_preview() -> String:
	return char(drag_unicode_code) + " " + name
	
func get_stat_changes() -> PackedStringArray:
	return PackedStringArray()

func get_delta(property_name: StringName, default: int = 0) -> int:
	return get(property_name) if get(property_name) else default
	
func _get_base_xp_change(value: int = 0) -> int:
	
	return XP_DELTA_BASE[value]

func get_scene() -> PackedScene:
	return scene if scene else DEFAULT_ACTIVITY_SCENE

func _get_property_list() -> Array[Dictionary]:
	return [{name = &"symbol", type = TYPE_STRING}]
func _get(property: StringName) -> Variant:
	return char(drag_unicode_code) if property ==  &"symbol" else null
func _set(property: StringName, value: Variant) -> bool:
	if property != &"symbol" or not value: return false
	drag_unicode_code = value.unicode_at(0)
	notify_property_list_changed()
	return true
