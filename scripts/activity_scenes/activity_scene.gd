@tool
class_name ActivityScene extends Node3D

@export var initial_pet_state: StringName = &"sleep"
#var activity: Activity

func open(stats: Stats, activity: Activity) -> void:
	var pet: Pet = %Pet
	assert(stats and pet and activity)
	pet.stats = stats
	if initial_pet_state: 
		pet.emit_signal(StateMachine.SIGNAL_STATE, initial_pet_state)


func play() -> void:
	if not has_node(^"%SpotLight3D"): return
	const MIN_ENERGY: float = 6.0
	const MAX_ENERGY: float = 10.0
	const LIGHT_FLICKER_DURATION_SEC: float = 1.8
	var tw: Tween = create_tween().set_loops().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT_IN)
	tw.tween_callback(func randomize_speed_scale() -> void: tw.set_speed_scale(randf_range(0.2, 5.0)))
	tw.tween_property(%SpotLight3D, ^"light_energy", MIN_ENERGY, LIGHT_FLICKER_DURATION_SEC).from(MAX_ENERGY)
	tw.tween_property(%SpotLight3D, ^"light_energy", MAX_ENERGY, LIGHT_FLICKER_DURATION_SEC).from(MIN_ENERGY)
