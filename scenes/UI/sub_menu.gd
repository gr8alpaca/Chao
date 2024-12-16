@tool
class_name SubMenuUI extends Control

@export_custom(PROPERTY_HINT_NODE_TYPE, "Control", PROPERTY_USAGE_EDITOR) 
var active_menu: Control

@export var enter_side: Side
@export var exit_side: Side = SIDE_RIGHT


@export_group("Node References")
@export var tweaks: Array[Tweak]
@export var menus: Array[Control]


func _ready() -> void:
	var buttons:= MainButtons.MAIN_BUTTON_GROUP.get_buttons()
	for i: int in mini(buttons.size(), get_child_count()):
		if not get_child(i) is Tweak: continue
		buttons[i].toggled.connect(_on_main_button_toggled.bind(buttons[i], get_child(i), get_child(i).get_child(0)))
	#MainButtons.MAIN_BUTTON_GROUP.pressed.connect(_on_menu_button_pressed)


func open(menu: Control) -> void:
	active_menu = menu

func close() -> void:
	if MainButtons.MAIN_BUTTON_GROUP.get_pressed_button():
		MainButtons.MAIN_BUTTON_GROUP.get_pressed_button().set_pressed(false)


func _on_menu_button_pressed(but: BaseButton) -> void:
	var pressed_button: BaseButton = MainButtons.MAIN_BUTTON_GROUP.get_pressed_button()
	var index: int = MainButtons.MAIN_BUTTON_GROUP.get_buttons().find(pressed_button)
	active_menu = menus[index] if index != -1 and index < tweaks.size() else null
	
	print("Opening %s menu..." % active_menu.name if active_menu else "Closing Current Menu...")
	
	if pressed_button and pressed_button.has_focus():
		pressed_button.release_focus()
	
	elif but and but.visible and not but.has_focus():
		but.grab_focus()


func _on_main_button_toggled(is_toggled: bool, button: BaseButton, tweak: Tweak, menu_control: Control) -> void:
	active_menu = menu_control if is_toggled else null
	tweak.side = enter_side if is_toggled else exit_side
	tweak.active = is_toggled
	
	if not is_toggled and button and button.visible and not button.has_focus():
		button.grab_focus()
	
	if is_toggled and button.has_focus():
		button.release_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if active_menu and Input.is_key_pressed(KEY_ESCAPE):
		close()
		accept_event()
