# 
@tool
extends PetState

# signal transition_requested(new_state: String)
# signal lock_state(set_locked: bool)

# var name

# var pet: Pet : set = set_pet


func _init() -> void:
	super(&"sleep")

func enter() -> void:
	pet.target_direction = Vector3.UP

func exit() -> void:
	pass
	

func update_process(delta: float) -> void:
	pass

func update_physics_process(delta: float) -> void:
	pass


func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass


func on_input(event: InputEvent) -> void:
	pass


func on_unhandled_input(event: InputEvent) -> void:
	pass


func set_pet(val: Pet) -> void:
	super(val)

func set_stats(val: Stats) -> void:
	super(val)
