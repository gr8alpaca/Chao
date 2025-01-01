@tool
class_name InteractMenu extends Control

signal start_week_pressed(activity_handler: Node)

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
@export var submenu: SubMenuUI

func _init() -> void:
	modulate.a = 0.0


func _ready() -> void:
	main_menu_active = false
	set_process_input(false)
	create_tween().tween_callback(set_modulate.bind(Color.WHITE)).set_delay(0.5)
	for but: BaseButton in find_children("*", "BaseButton", true, false):
		but.mouse_entered.connect(focus_button.bind(but))
	
	get_node(^"%StartWeek").pressed.connect(_on_start_week_pressed)


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
	
#
func release_current_focus() -> void:
	if not is_inside_tree(): return
	var focus_owner:= get_window().gui_get_focus_owner()
	if focus_owner: focus_owner.release_focus()


func focus_button(control: Control) -> void:
	if control and control.focus_mode and control.visible and control.is_inside_tree() and not control.has_focus(): 
		control.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		self.pet = null
		accept_event()
	if Input.is_key_pressed(KEY_M):
		main_menu_active = !main_menu_active
		accept_event()

func _input(event: InputEvent) -> void:
	accept_event()

func set_pet(val: Pet):
		if pet == val: return
		if pet:
			pet.emit_signal(Interactable.SIGNAL_INTERACTION_ENDED)
		pet = val
		if pet:
			pet.emit_signal(Interactable.SIGNAL_INTERACTION_STARTED)
			%InfoPanel.set_stats(pet.stats)
			if name_label_container.get_child_count():
				name_label_container.get_child(0).text = pet.stats.name
		
		main_menu_active = (pet != null)
	

func _on_start_week_pressed() -> void:
	set_process_input(true)
	assert(schedule_ui.slots.all(func(slot: ScheduleSlot) -> bool: return slot.activity != null), "Schedule slots not full!!")
	
	main_menu_active = false
	
	#TODO Remove 
	main_buttons.closed.connect(pet.get_parent().remove_child.bind(pet), CONNECT_ONE_SHOT) 
	
	var activity_handler: ActivitySceneHandler = ActivitySceneHandler.new()
	activity_handler.open(pet.stats, schedule_ui.get_activities())
	activity_handler.ready.connect(activity_handler.advance_week, CONNECT_DEFERRED)
	
	start_week_pressed.emit(activity_handler)
	
	#var garden: Node = load(get_parent().scene_file_path).instantiate()
	#garden.tree_entered.connect(garden.add_child.bind(pet))
	#Event.queue_scene.emit(garden)
	#
	#Event.change_scene.emit(activity_handler)
