@tool
class_name ActivityScene extends Node3D

signal apply_stats

var pet: Pet: set = set_pet
var activity: Activity: set = set_activity

func open(pet: Pet, activity: Activity) -> ActivityScene:
	assert(pet and activity)
	self.activity = activity
	self.pet = pet
	pet.emit_signal(StateMachine.SIGNAL_STATE, &"sleep")
	add_child(pet, true)
	#pet.process_mode = Node.PROCESS_MODE_DISABLED
	return self

func play() -> void:
	pass


func apply_activity_deltas(act: Activity) -> void:
	var deltas: Dictionary = ActivityXP.roll_exercise(activity)
	for stat: StringName in deltas.keys():
		pet.stats.add_experience(stat, deltas[stat])


func set_pet(val: Pet) -> void:
	pet = val

func set_activity(val: Activity) -> void:
	activity = val
