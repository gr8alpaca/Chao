# 
@tool
class_name PetStateInteraction extends PetState


@export_range(0.1, 2.0, 0.1, "suffix:secs")
var look_time: float = 0.5


func _init() -> void:
	name = &"interaction"


func enter() -> void:
	pet.is_moving = false
	look_camera()


func _on_enable_input(is_enabled: bool) -> void:
	if is_enabled:
		transition_requested.emit(&"idle")


func exit() -> void:
	if pet.rotation.x != 0.0:
		pet.create_tween().tween_property(pet, ^"rotation:x", 0.0, look_time / 1.5)
	if pet.rotation.z != 0.0:
		pet.create_tween().tween_property(pet, ^"rotation:z", 0.0, look_time / 1.5)
	

func look_camera() -> void:
	pet.rotate_towards_position(pet.get_viewport().get_camera_3d().global_position, look_time)


func _on_interaction_started() -> void:
	transition_requested.emit(name)

func _on_interaction_ended() -> void:
	transition_requested.emit(&"idle")


func set_pet(val: Pet) -> void:
	super(val)
	pet.connect(Interactable.SIGNAL_INTERACTION_STARTED, _on_interaction_started)
	pet.connect(Interactable.SIGNAL_INTERACTION_ENDED, _on_interaction_ended)
