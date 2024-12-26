@tool
class_name ActivityScene extends Node3D

signal apply_stats

var pet: Pet: set = set_pet
var activity: Activity: set = set_activity

var light_tween: Tween

func open(pet: Pet, activity: Activity) -> ActivityScene:
	assert(pet and activity)
	self.activity = activity
	self.pet = pet
	pet.emit_signal(StateMachine.SIGNAL_STATE, &"sleep")
	add_child(pet, true)
	pet.apply_floor_snap()
	return self

func play() -> void:
	const MIN_ENERGY: float = 6.0
	const MAX_ENERGY: float = 10.0
	const LIGHT_FLICKER_DURATION_SEC: float = 1.8
	var tw: Tween = create_tween().set_loops().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT_IN)
	tw.tween_callback(func randomize_speed_scale() -> void: tw.set_speed_scale(randf_range(0.2, 5.0)))
	tw.tween_property(%SpotLight3D, ^"light_energy", MIN_ENERGY, LIGHT_FLICKER_DURATION_SEC).from(MAX_ENERGY)
	tw.tween_property(%SpotLight3D, ^"light_energy", MAX_ENERGY, LIGHT_FLICKER_DURATION_SEC).from(MIN_ENERGY)


func apply_activity_deltas(act: Activity) -> void:
	var deltas: Dictionary = ActivityXP.roll_exercise(activity)
	for stat: StringName in deltas.keys():
		pet.stats.add_experience(stat, deltas[stat])


func set_pet(val: Pet) -> void:
	pet = val

func set_activity(val: Activity) -> void:
	activity = val
