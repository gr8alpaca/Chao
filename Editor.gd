@tool
extends EditorScript

func _run() -> void:
	print("Running...")
	#var scene: Node = get_scene()
	var result: Array[Rect2]
	result.resize(4)
	result[2].position = Vector2(10, 10)
	print(result)
	

func strvec(v: Vector2) -> String:
	return "%1.2v" % v
