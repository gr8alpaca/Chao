@tool
class_name BounceContainer extends Container

@export
var active: bool = true:
	set(val):
		active = val
		update_process()

@export 
var max_bounce_offset: Vector2 = Vector2(0, -20)

@export_range(0.0, 5.0, 0.05, "or_greater")
var time_scale: float = 1.0

var time: float = 0.0

func _process(delta: float) -> void:
	time = fmod(time + delta * time_scale, 2.0)
	place_children()
	

func place_children() -> void:
	var pos: Vector2 = Tween.interpolate_value(Vector2.ZERO, max_bounce_offset, pingpong(time, 1.0), 1.0, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	for child: Node in get_children():
		if not child is Control: continue
		child.position = pos


func update_process() -> void:
	if is_processing() and not (visible and active):
		set_process(false)
		time = 0.0
		place_children()
	
	elif not is_processing() and visible and active:
		set_process(true)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			update_process()
		
		
		NOTIFICATION_SORT_CHILDREN:
			for child: Node in get_children():
				if not child is Control: continue
				child.size = size
				place_children()
		
		NOTIFICATION_VISIBILITY_CHANGED:
			update_process()


func _get_minimum_size() -> Vector2:
	var min_size: Vector2 = Vector2.ZERO
	for control: Node in get_children():
		if not control is Control: continue
		var control_min: Vector2 = control.get_combined_minimum_size()
		min_size.x = maxf(control_min.x, min_size.x)
		min_size.y = maxf(control_min.y, min_size.y)
	return min_size
