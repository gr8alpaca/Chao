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
	
	var s:= ""
	var t: float = inverse_lerp(MIN, MAX, clampf(exhaustion, MIN, MAX))
	s += "%0.3f" % t
	t = ease(t, 1.6)
	s += " -> %0.3f" % t
	print(s)
