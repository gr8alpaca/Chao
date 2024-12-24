# 
@tool
extends PetState


func _init() -> void:
	super(&"sleep")

func enter() -> void:
	pet.rotation_degrees = Vector3(90.0, 0.0 , 0.0)


func exit() -> void:
	pet.rotation_degrees = Vector3(0.0, 0.0 , 0.0)


func update_process(delta: float) -> void:
	pet.rotation_degrees = Vector3(90.0, 0.0 , 0.0)

func update_physics_process(delta: float) -> void:
	pass
	
#
#func on_mouse_entered() -> void:
	#pass
#
#func on_mouse_exited() -> void:
	#pass
#
#
#func on_input(event: InputEvent) -> void:
	#pass
#
#
#func on_unhandled_input(event: InputEvent) -> void:
	#pass
