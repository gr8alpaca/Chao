@tool
class_name ActivityScene extends Node3D

signal activity_finished

var pet: Pet  : set = set_pet
var activity: Activity

func init(pet: Pet, activity: Activity) -> ActivityScene:
	assert(pet and activity)
	self.activity = activity
	self.pet = pet
	return self

func start() -> void:
	pass


func set_pet(val: Pet) -> void:
	pet = val
	add_child(val, true)
	if activity.name == &"Rest":
		pet.emit_signal(StateMachine.SIGNAL_STATE, &"sleep")
