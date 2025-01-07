@tool
extends EditorScript


func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	var stats:= Stats.new()
	var s:= ""
	print(stats.data)
	stats.add_xp("swim", 14)
	var err:= ResourceSaver.save(stats, "res://resources/stats/player/test.tres",)
	print("Save => ", error_string(err))
	#print(s.trim_suffix("| "))
