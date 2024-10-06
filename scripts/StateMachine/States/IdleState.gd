@tool
extends PetState

# signal transition_requested(new_state: String)
# signal lock_state(set_locked: bool)

# var name

# var pet: Pet : set = set_pet


@export var max_wander_distance: float = 1.5
@export var min_interval: float = 1.5
@export var max_interval: float = 4.5

func _init() -> void:
	super(&"idle")

func enter() -> void:
	pass

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