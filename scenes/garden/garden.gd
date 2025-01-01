@tool
class_name Garden extends Node3D

const MAX_DISTANCE: float = 3.0
@export var pet_scene: PackedScene
@export var interact_menu_scene: PackedScene

var pet_stats: Array[Stats]


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	var interact_menu: InteractMenu = interact_menu_scene.instantiate()
	add_child(interact_menu, true)
	interact_menu.start_week_pressed.connect(_on_start_week_pressed)
	
	if pet_stats.is_empty():
		pet_stats.append(Stats.new())
	
	populate_pets()


func populate_pets() -> void:
	assert(has_node(^"InteractMenu"))
	var interact_menu: InteractMenu = get_node(^"InteractMenu")
	
	for pet: Pet in get_pets():
		remove_child(pet)
		pet.free()
	
	for s: Stats in pet_stats:
		var pet: Pet = pet_scene.instantiate()
		add_child(pet)
		pet.rotation.y = PI # To face camera
		pet.connect(Interactable.SIGNAL_INTERACTION_STARTED, interact_menu.set_pet.bind(pet))
		pet.stats = s


func _on_start_week_pressed(activity_scene: Node) -> void:
	emit_signal(Main.SIGNAL_CHANGE, activity_scene)


func get_pets() -> Array[Pet]:
	var pets: Array[Pet]
	for child: Node in get_children():
		if child is Pet: pets.push_back(child as Pet)
	return pets
