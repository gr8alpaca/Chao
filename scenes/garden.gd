@tool
class_name Garden extends Node3D


func _ready() -> void:
	Event.garden_entered.emit(self)

	
func get_pets() -> Array[Pet]:
	var pets: Array[Pet]
	for child: Node in get_children():
		if child is Pet: pets.push_back(child as Pet)
	return pets