@tool
class_name Garden extends Node3D

@export var interact_menu_scene: PackedScene = preload("res://scenes/interact_menu.tscn")

func _ready() -> void:
	#
	if not Engine.is_editor_hint():
		var interact_menu: InteractMenu = interact_menu_scene.instantiate()
		add_child(interact_menu)

		for pet: Pet in get_pets():
			pet.connect(Interactable.SIGNAL_INTERACTION_STARTED, interact_menu.set_pet.bind(pet))


func get_pets() -> Array[Pet]:
	var pets: Array[Pet]
	for child: Node in get_children():
		if child is Pet: pets.push_back(child as Pet)
	return pets
