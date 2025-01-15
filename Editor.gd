@tool
extends EditorScript

func _run() -> void:
	print("Running...")
	var scene: Node = get_scene()
	
	const MIN:= 30.0
	const MAX:= 165.0
	
	const EXHAUSTION_STRESS: float = 1.0
	const EXHAUSTION_FATIGUE: float = 3.0
	
	var stress: int = 50
	var fatigue: int = 8
	
	var exhaustion: float = stress * EXHAUSTION_STRESS + fatigue * EXHAUSTION_FATIGUE
	
	const MAX_PENALTY: float = 0.8
	
	#for i in 11:
		#fatigue = i*10
		#print("%d: %0.3f" % [fatigue, clampf(ease(fatigue/ 100.0, 1.4) * MAX_PENALTY, 0.0, MAX_PENALTY)])
	var lbl: MonoLabel = scene.level_label
	print(lbl.get_max_size())
	#lbl.text = "0000"
	#
	#printt("0000", strvec(lbl.get_combined_minimum_size()))
	#lbl.text = "8888"
	#printt("8888", strvec(lbl.get_combined_minimum_size()))
	
	
	#var s:= ""
	#var t: float = inverse_lerp(MIN, MAX, clampf(exhaustion, MIN, MAX))
	#s += "%0.3f" % t
	#t = ease(t, 1.6)
	#s += " -> %0.3f" % t
	#print(s)

func strvec(v: Vector2) -> String:
	return "%1.2v" % v
