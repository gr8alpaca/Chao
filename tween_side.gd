@tool
class_name TweenSide extends Node

@export var item: Control



func _init(side:= SIDE_LEFT, duration: float = 1.3, trans:= Tween.TRANS_ELASTIC, ease:= Tween.EASE_IN_OUT) -> void:
	item = get_parent()
	Engine.get_main_loop().process_frame
	item.get_process_delta_time()
	#set_trans(trans)
	#set_ease(ease)
