@tool
class_name MainButtons extends Control


@export_range(0.0, 1.2, 0.05, "suffix:sec")
var interval: float = 0.35:
	set(val): interval = maxf(val, 0.0)


func show_buttons() -> void:
	var buttons : Array[BaseButton] = get_buttons()
	for i: int in buttons.size():
		buttons[i].emit_signal(Animator.SIGNAL_SHOW, i * interval)


func hide_buttons() -> void:
	for but: BaseButton in get_buttons():
		but.emit_signal(Animator.SIGNAL_HIDE)


func get_buttons() -> Array[BaseButton]:
	var buttons: Array[BaseButton]
	for child: BaseButton in find_children("*", "BaseButton", true, false):
		buttons.push_back(child as BaseButton)
	return buttons