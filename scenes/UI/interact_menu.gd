@tool
class_name InteractMenu extends Control

signal start_week_pressed(schedule: Array)

var pet: Pet: set = set_pet

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
@export var submenu: SubMenuUI


func _ready() -> void:
	get_node(^"%StartWeek").pressed.connect(_on_start_week_pressed)
	for but: BaseButton in find_children("*", "BaseButton", true, false):
		but.mouse_entered.connect(focus_button.bind(but))
	set_process_input(false)

func _enter_tree() -> void:
	main_menu_active = false
	set_process_input(false)


func show_main_menu() -> void:
	const SECTION_DELAY_SEC: float = 0.5
	name_label_container.open()
	info_panel_container.open(SECTION_DELAY_SEC)
	schedule_ui.open(2 * SECTION_DELAY_SEC)
	main_buttons.open(3 * SECTION_DELAY_SEC)


func hide_main_menu() -> void:
	release_current_focus()
	submenu.close()
	name_label_container.close()
	info_panel_container.close()
	schedule_ui.close()
	main_buttons.close()


func release_current_focus() -> void:
	if not is_inside_tree(): return
	var focus_owner:= get_window().gui_get_focus_owner()
	if focus_owner: focus_owner.release_focus()


func focus_button(control: Control) -> void:
	if control and control.focus_mode and control.visible and control.is_inside_tree() and not control.has_focus(): 
		control.grab_focus()

func _input(event: InputEvent) -> void:
	accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		self.pet = null
		accept_event()
	if Input.is_key_pressed(KEY_M):
		main_menu_active = !main_menu_active
		accept_event()


func set_pet(val: Pet):
		if pet == val: return
		if pet: 
			pet.emit_signal(Interactable.SIGNAL_INTERACTION_ENDED)
		pet = val
		%InfoPanel.set_stats(pet.stats if pet else null)
		%Name.text = pet.stats.name if pet else ""
		main_menu_active = (pet != null)


func _on_start_week_pressed() -> void:
	set_process_input(true)
	var schedule: Schedule = get_tree().get_first_node_in_group(Schedule.GROUP)
	assert(schedule.is_filled(), "Schedule slots not full!!")
	pet = null
	start_week_pressed.emit(schedule.schedule.duplicate())
	schedule.clear()
