@tool
class_name InteractMenu extends Control

static var vp_size: Vector2 = Vector2(ProjectSettings["display/window/size/viewport_width"], ProjectSettings["display/window/size/viewport_height"])

@export var pet: Pet: set = set_pet

@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var main_menu_active: bool:
	set(val):
		main_menu_active = val
		if not is_node_ready(): 
			await ready
		call(&"show_main_menu" if main_menu_active else &"hide_main_menu")


@export_group("Node References")
@export var name_label_container: Tweak
@export var main_buttons: MainButtons

@export var info_panel_container: Tweak
@export var stat_panel: InfoPanel
@export var schedule_ui: ScheduleUI
@export var submenu: Control


func _init() -> void:
	modulate.a = 0.0


func _ready() -> void:
	main_menu_active = false
	create_tween().tween_callback(set_modulate.bind(Color.WHITE)).set_delay(0.5)
	for but: BaseButton in find_children("*", "BaseButton", true, false):
		but.mouse_entered.connect(focus_button.bind(but))


func show_main_menu() -> void:
	const SECTION_DELAY_SEC: float = 0.5
	name_label_container.open()
	info_panel_container.open(SECTION_DELAY_SEC)
	schedule_ui.open(2 * SECTION_DELAY_SEC)
	main_buttons.open(3 * SECTION_DELAY_SEC)


func hide_main_menu() -> void:
	
	release_current_focus()
	name_label_container.close()
	info_panel_container.close()
	schedule_ui.close()
	main_buttons.close()
	submenu.close()
	
	
func release_current_focus() -> void:
	var focus_owner:= get_window().gui_get_focus_owner()
	if focus_owner: focus_owner.release_focus()



func focus_button(control: Control) -> void:
	if control and control.focus_mode and control.visible and not control.has_focus(): 
		control.grab_focus()

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		self.pet = null


func set_pet(val: Pet):
		if pet == val: return
		if pet:
			pet.emit_signal(Interactable.SIGNAL_INTERACTION_ENDED)
		pet = val
		if pet:
			pet.emit_signal(Interactable.SIGNAL_INTERACTION_STARTED)
			if name_label_container.get_child_count():
				name_label_container.get_child(0).text = pet.stats.name
		
		main_menu_active = (pet != null)
