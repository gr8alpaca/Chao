@tool
class_name MainButtons extends VBoxContainer


@export_range(0.0, 1.2, 0.05, "suffix:sec")
var interval_sec: float = 0.35:
	set(val): interval_sec = maxf(val, 0.0)

@export var main_button_group: ButtonGroup

func _ready() -> void:
	var cons:= get_cons()
	cons[0].opened.connect(focus_button.bind(cons[0].get_child(0)))

func open(delay_sec: float = 0.0) -> void:
	var cons:= get_cons()
	for i: int in cons.size():
		cons[i].open(i * interval_sec + delay_sec)


func close() -> void:
	for con: Tweak in get_cons():
		con.close()


func focus_button(control: Control) -> void:
	if control and control.visible and not control.has_focus(): 
		control.grab_focus()


func set_disabled(val: bool) -> void:
	for but: BaseButton in main_button_group.get_buttons():
		but.diabled = val


func get_cons() -> Array[Tweak]:
	var cons: Array[Tweak]
	for child: Node in get_children():
		if child is Tweak: cons.push_back(child)
	return cons
