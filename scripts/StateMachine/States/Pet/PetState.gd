@tool
class_name PetState extends State

var pet: Pet : set = set_pet
var stats: Stats: set = set_stats

func _init(name: StringName = &"PetState") -> void:
	super(name)


func set_pet(val: Pet) -> void:
	pet = val
	stats = pet.stats

func set_stats(val: Stats) -> void:
	stats = val


func update_physics_process(delta: float) -> void:
	pet.velocity = pet.velocity.move_toward(Vector3(0.0, pet.velocity.y, 0.0), pet.acceleration * delta)
