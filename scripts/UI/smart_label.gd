@tool
class_name SmartLabel extends Label
## Label that updates it's font size dynamically with it's height.

@export_tool_button("Update Font Size", "Resize")
var update_fs_callable:Callable = update_fs

func update_fs() -> void:
	if not text: return
	var font_size: int = 1
	var font: Font = get_theme_default_font()
	while font.get_string_size(text, horizontal_alignment, visible_characters, font_size, justification_flags).y < size.y:
		font_size += 1
	add_theme_font_size_override(&"font_size", font_size)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			update_fs()
