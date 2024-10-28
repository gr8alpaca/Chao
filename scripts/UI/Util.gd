@tool
class_name Util
## Class containing common helper functions for use across other scripts.

const DEBUG_COLOR: Color = Color(Color.HOT_PINK, 0.5)

static func tween_position(control: Control, from: Vector2 = Vector2.ZERO, to: Vector2 = Vector2.ZERO, duration: float = 1.3, tween_trans:= Tween.TRANS_ELASTIC, tween_ease:= Tween.EASE_IN_OUT) -> Tween:
	var scale_property: String = "scale:x" if from.y == to.y else "scale:y"
	control.visible = false
	var tw: Tween = control.create_tween()
	tw.set_parallel().set_trans(tween_trans).set_ease(tween_ease)
	tw.tween_property(control, "modulate:a", 1.0, duration / 2.5).from(0.0)
	tw.tween_property(control, "position", to, duration).from(from)
	tw.tween_property(control, "scale:x", 1.0, duration / 1.5).from(0.1)
	tw.tween_callback(control.set_visible.bind(true))
	
	return tw


static func tween_fade(control: Control, final_alpha_value: float = 0.0, time_sec: float = 0.25) -> Tween:
	var tw: Tween = control.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(control, ^"modulate:a", final_alpha_value, time_sec)
	return tw