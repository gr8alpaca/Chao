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
