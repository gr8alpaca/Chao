@tool
extends EditorScript

func _run() -> void:
	print("Running...")
	#var scene: Node = get_scene()
	print(ProjectSettings.get_setting_with_override(&"display/window/size/viewport_height"))
	

func strvec(v: Vector2) -> String:
	return "%1.2v" % v
