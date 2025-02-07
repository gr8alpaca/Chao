@tool
extends EditorScript

func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	print(char(StatInfo.UP_ARROW_UNICODE))
	

func strvec(v: Vector2) -> String:
	return "%1.2v" % v
	
