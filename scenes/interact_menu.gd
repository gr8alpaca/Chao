@tool
class_name InteractMenu extends Control


@export var pet: Pet: set = set_pet

func set_pet(val: Pet):
		if pet == val: return

		if pet:
			pet.emit_signal(Interactable.SIGNAL_INTERACTION_ENDED)
			
		pet = val

		if pet:
			pet.emit_signal(Interactable.SIGNAL_INTERACTION_STARTED)
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

@export_group("Node References")
@export var main_menu: Control
@export var main_buttons: Control
@export var name_label: Label
@export var stat_panel: InfoPanel
@export var schedule_ui: ScheduleUI

func _ready() -> void:
	main_menu_active = false

	if main_buttons:
		for but: BaseButton in main_buttons.get_children():
			but.pressed.connect(_on_main_pressed.bind(but))
	
	for but: BaseButton in find_children("*", "BaseButton", true, false):
		but.mouse_entered.connect(but.grab_focus)
		but.focus_entered.connect(_on_button_focus_enter.bind(but))
		but.focus_exited.connect(_on_button_focus_exit.bind(but))


func show_main_menu() -> void:
	assert(main_buttons, "No main_buttons set!")
	const DURATION: float = 1.3
	const INTERVAL: float = 0.4
	main_menu.show()

	Util.tween_position(name_label, Vector2(name_label.position.x, 0.0), name_label.position, 1.0)

	await create_tween().tween_interval(0.5).finished

	var window_x: int = get_window_size().x
	Util.tween_position(stat_panel, Vector2(window_x - stat_panel.size.x, stat_panel.position.y), Vector2(window_x - x_margin - stat_panel.size.x, stat_panel.position.y), )
 
	await create_tween().tween_interval(0.5).finished

	var buttons: Array[BaseButton] = get_buttons(main_buttons)
	assert(not buttons.is_empty(), "NO BUTTONS FOUND!")
	for but: BaseButton in buttons:
		create_tween().tween_callback(Util.tween_position.bind(but, Vector2(0.0, but.position.y), Vector2(x_margin, but.position.y), DURATION)).set_delay(but.get_index() * INTERVAL)

	await create_tween().tween_interval((buttons.size() - 1) * INTERVAL + DURATION * 0.85).finished
	if get_viewport().gui_get_focus_owner() not in buttons:
		buttons[0].grab_focus()


func hide_main_menu() -> void:
	Util.tween_fade(name_label)
	for but: BaseButton in get_buttons(main_buttons): Util.tween_fade(but)
	Util.tween_fade(stat_panel).tween_callback(main_menu.set_visible.bind(false)).set_delay(0.25)


func _on_main_pressed(button: BaseButton) -> void:
	match button.name:
		&"Train":
			print("Opening Training Menu here...")

	print("Pressed Main -> %s" % button.name)


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		self.pet = null


func _on_button_focus_enter(but: BaseButton) -> void:
	if not but.draw.is_connected(Pointer.draw_pointer):
		but.draw.connect(Pointer.draw_pointer.bind(but, true))

	but.queue_redraw()


func _on_button_focus_exit(but: BaseButton) -> void:
	if but.draw.is_connected(Pointer.draw_pointer):
		but.draw.disconnect(Pointer.draw_pointer)

	but.queue_redraw()


func get_buttons(node: Node) -> Array[BaseButton]:
	var buttons: Array[BaseButton]
	for child: Node in (node.get_children() if node else []):
		if child is BaseButton:
			buttons.push_back(child as BaseButton)
	return buttons


func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var w_size: Vector2 = get_window_size()
	const DASH_GAP_SIZE: float = 8.0
	draw_dashed_line(Vector2(x_margin, 0.0), Vector2(x_margin, w_size.y), Util.DEBUG_COLOR, DASH_GAP_SIZE)
	draw_dashed_line(Vector2(w_size.x - x_margin, 0.0), Vector2(w_size.x - x_margin, w_size.y), Util.DEBUG_COLOR, DASH_GAP_SIZE)
	draw_line(Vector2(w_size.x / 2.0, 0, ), Vector2(w_size.x / 2.0, w_size.y), Color.RED)
	draw_line(Vector2(0, w_size.y / 2.0), Vector2(w_size.x, w_size.y / 2.0), Color.RED)


	draw_rect(name_label.get_rect(), Util.DEBUG_COLOR, false)
	for but: BaseButton in get_buttons(main_buttons):
		draw_rect(but.get_rect(), Util.DEBUG_COLOR, false)
	draw_rect(stat_panel.get_rect(), Util.DEBUG_COLOR, false)


func get_window_size() -> Vector2:
	return Vector2(ProjectSettings.get_setting("display/window/size/viewport_width", 1920), ProjectSettings.get_setting("display/window/size/viewport_height", 1080))