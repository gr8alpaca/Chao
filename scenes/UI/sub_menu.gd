@tool
class_name SubMenuUI extends Control

@export var active_menu: Control : set = set_active_menu

@export var enter_side: Side
@export var exit_side: Side = SIDE_RIGHT

@export var main_button_group: ButtonGroup

@export_group("Node References")
@export var tweaks: Array[Tweak]
@export var menus: Array[Control]


func _ready() -> void:
	main_button_group.pressed.connect(_on_menu_button_pressed)


func open(menu: Control) -> void:
	if not menu: return
	active_menu = menu


func close() -> void:
	if main_button_group.get_pressed_button():
		main_button_group.get_pressed_button().button_pressed = false
	

func set_active_menu(val: Control) -> void:
	var tweak: Tweak = active_menu.get_parent() if active_menu else null
	if tweak:
		tweak.side = exit_side
		tweak.active = false
	
	active_menu = val
	tweak = active_menu.get_parent() if active_menu else null
	
	if tweak:
		tweak.side = enter_side
		tweak.active = true
	
	

func _on_menu_button_pressed(but: BaseButton) -> void:
	update_active_menu()


func update_active_menu() -> void:
	var pressed_button: BaseButton = main_button_group.get_pressed_button()
	if not pressed_button:
		active_menu = null
	var index: int = main_button_group.get_buttons().find(pressed_button)
	
	active_menu = menus[index] if index != -1 and index < tweaks.size() else null
	print("Opening %s menu..." % main_button_group.get_pressed_button().name if active_menu else "Closing Current Menu...")


func _unhandled_key_input(event: InputEvent) -> void:
	if active_menu and Input.is_key_pressed(KEY_ESCAPE):
		close()
		accept_event()


func _validate_property(property: Dictionary) -> void:
	if property.name == &"active_menu":
		property.usage &= ~(PROPERTY_USAGE_STORAGE)
