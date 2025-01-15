@tool
extends EditorScript

func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()


func strvec(v: Vector2) -> String:
	return "%1.2v" % v
