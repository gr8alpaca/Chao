@tool
extends Label

func _get_minimum_size() -> Vector2:
	return get_theme_font(&"font").get_string_size("8888", 0, -1, get_theme_font_size(&"font_size")) 
