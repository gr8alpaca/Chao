@tool
class_name GardenUI extends CanvasLayer

@onready var interact_menu: InteractMenu = $InteractMenu


func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(get_parent() is Garden)
	
	for pet: Pet in get_parent().get_pets():
		pet.connect(Interactable.SIGNAL_INTERACTION_STARTED, interact_menu.set_pet.bind(pet))
	
	if not Engine.is_editor_hint():
		get_window().gui_focus_changed.connect(_on_gui_focus_changed.bind($FocusLabel))


func _on_gui_focus_changed(control: Control, lbl: Label) -> void:
	lbl.text = "Current Focus: %s" % (control.name if control else "None")


func _input(event: InputEvent) -> void:
	if is_node_ready() and event.is_pressed() and Input.is_key_pressed(KEY_9):
		$FocusLabel.visible = !$FocusLabel.visible
