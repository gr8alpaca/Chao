# 
@tool
class_name PetStateTPose extends PetState

# This state does nothing except stop movement.

func _init() -> void:
	super(&"tpose")

func enter() -> void:
	pet.is_moving = false
	pet.target_position = pet.position

func exit() -> void:
	pass
	
