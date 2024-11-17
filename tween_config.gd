@tool
class_name TweenConfig extends Resource

@export_range(0.01, 5.0, 0.1, "or_greater", "suffix:s") var time_sec: float 
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
