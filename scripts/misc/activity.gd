@tool
class_name Activity extends Resource
## Anything that fills a week slot in the schedule


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


func get_drag_preview() -> String:
	return symbol + " " + name
