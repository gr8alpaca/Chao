@tool
extends EditorScript


func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	print(scene.start_scene)
