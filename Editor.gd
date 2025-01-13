@tool
extends EditorScript
signal bar
var d = {
		"foo": {
			"bar": "val"
		}
	}

func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	#if scene is StatInfo:
		##var stat_info : StatInfo = scene
		#scene.stats.add_xp(&"run", 8)
		#print("XP ADDED")
	
	if bar.is_connected(foo):
		bar.disconnect(foo)
	bar.connect(foo.bind(14))
	print(bar.is_connected(foo))
	
	#stats.add_xp("swim", 14)
	#var err:= ResourceSaver.save(stats, "res://resources/stats/player/test.tres",)
	#print("Save => ", error_string(err))
	#print(s.trim_suffix("| "))


func foo(val: Variant) -> void:
	print(val)
