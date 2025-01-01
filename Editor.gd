@tool
extends EditorScript


func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	printt(Main.PATH.keys())
	#print(scene.start_scene)
