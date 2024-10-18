@tool
class_name GardenUI extends CanvasLayer

@onready var interact_menu: InteractMenu = $InteractMenu

func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(get_parent() is Garden)
	for pet: Pet in get_parent().get_pets():
		pet.connect(Interactable.SIGNAL_INTERACTION_STARTED, interact_menu.set_pet.bind(pet))
	