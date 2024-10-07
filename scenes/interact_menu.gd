@tool
class_name InteractMenu extends Control


@export var main_menu: Control

@export var main_buttons: Control

@export var name_label: Label

@export var panel: InfoPanel

@export var pet: Pet:
	set(val):
		if pet == val: return
		if pet:
			pet.emit_signal(Interactable.SIGNAL_ENABLED, true)
			pet.state = Pet.PET_STATE_IDLE

		pet = val

		if pet:
			pet.look_camera()
			pet.emit_signal(Interactable.SIGNAL_ENABLED, false)
			name_label.text = pet.stats.name

		main_menu_active = (pet != null)


@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var main_menu_active: bool:
	set(val):
		main_menu_active = val
		if not main_menu: return
		if not main_menu.visible and main_menu_active:
			show_main_menu()
		elif main_menu.visible and not main_menu_active:
			hide_main_menu()


@export var x_margin: float = 128.0:
	set(val):
		x_margin = clampf(val, 0.0, 1920.0)
		if main_menu_active:
			for but in get_buttons(main_buttons): but.position.x = x_margin
		queue_redraw()


func _ready() -> void:
	main_menu_active = false
	Event.pet_interacted.connect(_pet_interacted)

	if main_buttons:
		for but: BaseButton in main_buttons.get_children():
			but.pressed.connect(_on_main_pressed.bind(but))


func show_main_menu() -> void:
	assert(main_buttons, "No main_buttons set!")
	const INTERVAL: float = 0.4
	main_menu.show()

	tween_control(name_label, Vector2(name_label.position.x, 0.0), name_label.position, 1.0)

	await create_tween().tween_interval(0.5).finished

	var window_x: int = get_window_size().x
	tween_control(panel, Vector2(window_x - panel.size.x, panel.position.y), Vector2(window_x - x_margin - panel.size.x, panel.position.y), )

	await create_tween().tween_interval(0.5).finished

	for but: BaseButton in get_buttons(main_buttons):
		create_tween().tween_callback(tween_control.bind(but, Vector2(0.0, but.position.y), Vector2(x_margin, but.position.y))).set_delay(but.get_index() * INTERVAL)


func hide_main_menu() -> void:
	var tw: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	tw.tween_property(name_label, ^"modulate:a", 0.0, 0.25)

	for but in get_buttons(main_buttons):
		tw.tween_property(but, ^"modulate:a", 0.0, 0.25)
		
	tw.tween_property(panel, ^"modulate:a", 0.0, 0.25)
	tw.tween_callback(main_menu.set_visible.bind(false)).set_delay(0.25)

	
func tween_control(control: Control, from: Vector2 = Vector2.ZERO, to: Vector2 = Vector2.ZERO, duration: float = 1.3) -> Tween:
	var scale_property: String = "scale:x" if from.y == to.y else "scale:y"
	control.visible = false
	var tw: Tween = create_tween()
	tw.set_parallel().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(control, "modulate:a", 1.0, duration / 2.5).from(0.0)
	tw.tween_property(control, "position", to, duration).from(from)
	tw.tween_property(control, "scale:x", 1.0, duration / 1.5).from(0.1)
	tw.tween_callback(control.set_visible.bind(true))
	
	return tw


func _on_main_pressed(button: BaseButton) -> void:
	print("Pressed Main -> %s" % button.name)
	

func _pet_interacted(pet: Pet) -> void:
	self.pet = pet


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		self.pet = null


func get_buttons(node: Node) -> Array[BaseButton]:
	var buttons: Array[BaseButton]
	for child: Node in (node.get_children() if node else []):
		if child is BaseButton:
			buttons.push_back(child as BaseButton)
	return buttons


func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var w_size: Vector2 = get_window_size()
	draw_dashed_line(Vector2(x_margin, 0.0), Vector2(x_margin, w_size.y), Color(Color.HOT_PINK, 0.5), )
	draw_dashed_line(Vector2(w_size.x - x_margin, 0.0), Vector2(w_size.x - x_margin, w_size.y), Color(Color.HOT_PINK, 0.5), )


func get_window_size() -> Vector2:
	return Vector2(ProjectSettings.get_setting("display/window/size/viewport_width", 1920), ProjectSettings.get_setting("display/window/size/viewport_height", 1080))