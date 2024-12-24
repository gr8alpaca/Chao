@tool
class_name Garden extends Node3D
@export var activity_scene: PackedScene

func _ready() -> void:
	return
	#Event.garden_entered.emit(self)

#func _on_start_week()


func get_pets() -> Array[Pet]:
	var pets: Array[Pet]
	for child: Node in get_children():
		if child is Pet: pets.push_back(child as Pet)
	return pets
