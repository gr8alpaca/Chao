@tool
class_name InteractMenu extends Control


@export var main_menu: Control

@export var main_buttons: Control
@export var name_label: Label

@export var pet: Pet:
	set(val):

		pet = val


func _ready() -> void:
	hide()
	Event.pet_interacted.connect(_pet_interacted)

	if main_buttons:
		for but: BaseButton in main_buttons.get_children():
			but.pressed.connect(_on_main_pressed.bind(but))


func show_main_menu() -> void:
	assert(main_buttons, "No main_buttons set!")
	const INTERVAL: float = 0.4
	for but: BaseButton in get_buttons(main_buttons):
		but.visible = false
		create_tween().tween_callback(tween_control.bind(but)).set_delay(but.get_index()*INTERVAL)
	


func tween_control(control: Control, side: Side = SIDE_LEFT, duration: float = 1.3) -> Tween:
	var property: String = "x" if side == SIDE_LEFT or side == SIDE_RIGHT else "y"
	var start_position: float = 0.0 if side < 2 else float(get_window().size[property])		
	
	var tw: Tween = create_tween()
	tw.set_parallel().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(control, "modulate:a", 1.0, duration / 2.5).from(0.0)
	tw.tween_property(control, "position:" + property, control.position[property], duration).from(start_position)
	tw.tween_property(control, "scale:" + property , 1.0, duration / 1.5).from(0.1)
	tw.tween_callback(control.set_visible.bind(true))
	
	return tw


func _on_main_pressed(button: BaseButton) -> void:
	pass


func _pet_interacted(pet: Pet) -> void:
	show()


func _visibility_changed() -> void:
	if visible:
		show_main_menu()
	

func get_buttons(node: Node) -> Array[BaseButton]:
	var buttons: Array[BaseButton]
	for child: Node in (node.get_children() if node else []):
		if child is BaseButton:
			buttons.push_back(child as BaseButton)
	return buttons
