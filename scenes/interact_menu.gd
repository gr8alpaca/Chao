@tool
class_name InteractMenu extends Control


@export var main_menu: Control

@export var main_buttons: Control
		

func _ready() -> void:
	hide()
	Event.pet_interacted.connect(_pet_interacted)

	if main_buttons:
		for but: BaseButton in main_buttons.get_children():
			but.pressed.connect(_on_main_pressed.bind(but))




func show_main_menu() -> void:
	assert(main_buttons, "No main_buttons set!")
	const INTERVAL: float = 0.4
	const DURATION: float = 2.0

	var buttons: Array[BaseButton]
	for but: BaseButton in main_buttons.get_children(): 
		buttons.append(but)

	for i: int in buttons.size():
		var tw: Tween = buttons[i].create_tween().chain()
		tw.tween_interval(i*INTERVAL)
		tw.set_parallel().set_trans(Tween.TRANS_ELASTIC)
		tw.tween_property(buttons[i], "position:x", buttons[i].position.x, DURATION).from(0.0)
		tw.tween_property(buttons[i], "modulate:a", 1.0, DURATION/2.5).from(0.0)
		tw.tween_property(buttons[i], "scale:x", 1.0, DURATION/1.5).from(0.1)



func _on_main_pressed(button: BaseButton) -> void:
	pass


func _pet_interacted(pet: Pet) -> void:
	show()			


func _visibility_changed() -> void:
	if visible:
		show_main_menu()
