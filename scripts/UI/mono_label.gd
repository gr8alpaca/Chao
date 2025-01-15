@tool
class_name MonoLabel extends Label

## String to verify will be fit when changing font size.
@export var sample_string: String = "8888":
	set(val):
		sample_string = val
		if is_node_ready(): 
			_notification(NOTIFICATION_THEME_CHANGED)
	get:
		return sample_string if sample_string else text

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY, NOTIFICATION_THEME_CHANGED:
			custom_minimum_size = get_theme_font(&"font", theme_type_variation)\
			.get_string_size(sample_string, 0, -1, 
			get_theme_font_size(&"font_size", theme_type_variation)
			)
