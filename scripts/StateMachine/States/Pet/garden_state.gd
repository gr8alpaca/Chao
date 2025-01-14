# 
@tool
class_name PetStateGarden extends PetState
const NAME:= &"garden"
# signal transition_requested(new_state: String)
# signal lock_state(set_locked: bool)

# var name

# var pet: Pet : set = set_pet


func _init() -> void:
	super(NAME)

func enter() -> void:
	stats.get_fatigue()

func exit() -> void:
	pass


func set_pet(val: Pet) -> void:
	super(val)
	

func set_stats(val: Stats) -> void:
	super(val)
