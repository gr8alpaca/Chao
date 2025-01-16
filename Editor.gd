@tool
extends EditorScript

func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	#for d in scene.material.get_property_list():
		#printt(d)
	#
	var arr = [0,0,0]
	var err = arr.insert(-1, 45)
	print(arr)
	#print(scene.get_indexed(^"material:shader").get_shader_uniform_list())

func strvec(v: Vector2) -> String:
	return "%1.2v" % v
