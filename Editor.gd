@tool
extends EditorScript


func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	var stats:= Stats.new()
	var s:= ""
	for key: String in stats.ranks:
		s += "%s - %s | " % [key, stats.get_grade(key)] 
	print(s.trim_suffix("| "))
	#RNG.instance = RandomNumberGenerator.new()
	#RNG.instance.randomize()
	#printt(RNG.instance.seed, RNG.instance.state)
	#RNG.save()
	#
	#var fa:= FileAccess.open(RNG.SAVE_PATH, FileAccess.READ)
	#var s:= str(fa.get_64())
	#s += "\t" + str(fa.get_64())
	#fa.close()
	#print(s)
