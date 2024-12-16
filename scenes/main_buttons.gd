@tool
class_name MainButtons extends VBoxContainer

const MAIN_BUTTON_GROUP : ButtonGroup = preload("res://resources/UI/main_button_group.tres")

@export_range(0.0, 1.2, 0.05, "suffix:sec")
var interval_sec: float = 0.35:
	set(val): interval_sec = maxf(val, 0.0)


func _ready() -> void:
	var cons:= get_cons()
	cons[-1].opened.connect(focus_button.bind(cons[0].get_child(0)))
	MAIN_BUTTON_GROUP.pressed.connect(_on_button_pressed)
	var buttons:= MAIN_BUTTON_GROUP.get_buttons()
	
	for i: int in buttons.size():
		buttons[i].focus_neighbor_left = ^"."
		buttons[i].focus_neighbor_top = buttons[i].get_path_to(buttons[i-1])
		buttons[i].focus_previous = buttons[i].focus_neighbor_top
		buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(buttons[(i+1) % buttons.size()])
		buttons[i].focus_next = buttons[i].focus_neighbor_bottom


func open(delay_sec: float = 0.0) -> void:
	var cons:= get_cons()
	for i: int in cons.size():
		cons[i].open(i * interval_sec + delay_sec)


func close() -> void:
	for con: Tweak in get_cons():
		con.close()


func _on_button_pressed(but: BaseButton) -> void:
	var pressed_button: BaseButton = MAIN_BUTTON_GROUP.get_pressed_button()
	if pressed_button and pressed_button.has_focus():
		pressed_button.release_focus()
	
	else:
		focus_button(but)


func focus_button(but: BaseButton) -> void:
	if but and but.visible and not but.button_pressed and not but.has_focus(): 
		but.grab_focus()


func set_disabled(val: bool) -> void:
	for but: BaseButton in get_buttons():
		but.diabled = val


func get_cons() -> Array[Tweak]:
	var cons: Array[Tweak]
	for child: Node in get_children():
		if child is Tweak: cons.push_back(child)
	return cons


func get_buttons() -> Array[BaseButton]:
	return MAIN_BUTTON_GROUP.get_buttons()
