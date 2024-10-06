@tool
extends EditorScript


func _run() -> void:
	var scene: Node = get_scene()
	var waypoint: Waypoint = scene.get_node_or_null(^"%Waypoint1")
	if waypoint:
		const PATH:= "res://resources/debug_material.tres"
		var mat: StandardMaterial3D = waypoint.mesh_instance.mesh.material
		var err:= ResourceSaver.save(mat, PATH)
		print("Resource saved at %s -> %s" % [PATH, error_string(err)])
