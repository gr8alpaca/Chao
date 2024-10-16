class_name State extends Resource

signal transition_requested(new_state: String)
signal lock_state(set_locked: bool)

signal parallel_started
signal parallel_ended

@export var name: StringName = &"STATE":
	set(val): name = val; resource_name = val;

func _init(state_name: StringName = &"STATE") -> void:
	resource_local_to_scene = true
	name = state_name

func enter() -> void:
	pass

func exit() -> void:
	pass


## State Machine Functions
func update_process(delta: float) -> void:
	pass

func update_physics_process(delta: float) -> void:
	pass

func on_input(event: InputEvent) -> void:
	pass

func on_gui_input(event: InputEvent) -> void:
	pass

func on_unhandled_input(event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_focus_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass

func on_focus_exited() -> void:
	pass

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_POSTINITIALIZE:
			resource_local_to_scene = true
#/