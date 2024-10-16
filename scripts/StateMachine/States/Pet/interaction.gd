# 
@tool
extends PetState


@export_range(0.1, 2.0, 0.1, "suffix:secs")
var look_time: float = 0.5


func _init() -> void:
	name = &"interaction"


func enter() -> void:
	pet.is_moving = false
	pet.connect(Interactable.SIGNAL_ENABLED, _on_enable_input, CONNECT_ONE_SHOT)
	look_camera()


func _on_enable_input(is_enabled: bool) -> void:
	emit_signal(&"transition_requested", &"idle")


func exit() -> void:
	pet.create_tween().tween_property(pet, ^"rotation:x", 0.0, look_time / 1.5)
	pet.create_tween().tween_property(pet, ^"rotation:z", 0.0, look_time / 1.5)
	

func look_camera() -> void:
	pet.rotate_towards_position(pet.get_viewport().get_camera_3d().global_position, look_time)
