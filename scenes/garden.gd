@tool
class_name Garden extends Node3D


# func _ready() -> void:
# 	for pet: Pet in get_pets():
# 		init_pet(pet)


# func init_pet(pet: Pet) -> void:
# 	pet.state = Pet.PET_STATE_IDLE


func get_pets() -> Array[Pet]:
	var pets: Array[Pet]
	for child: Node in get_children(): 
		if child is Pet: pets.push_back(child as Pet)
	return pets