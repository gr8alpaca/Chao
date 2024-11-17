@tool
class_name LayeredStyleBox extends StyleBox

@export var style_boxes: Array[StyleBox]: set = set_styleboxes

func set_styleboxes(val: Array[StyleBox]) -> void:
	for dict: Dictionary in get_incoming_connections():
		if dict.signal.get_name() == &"changed" : dict.signal.disconnect(dict.callable)
	style_boxes = val
	for box: StyleBox in style_boxes:
		if box: box.changed.connect(emit_changed)
	emit_changed()


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	for box: StyleBox in style_boxes:
		if box: box.draw(to_canvas_item, rect)

func _get_minimum_size() -> Vector2:
	var min_size:=Vector2.ZERO
	for box: StyleBox in style_boxes:
		if not box: continue
		var box_min:= box.get_minimum_size()
		min_size.x = maxf(min_size.x, box_min.x)
		min_size.y = maxf(min_size.y, box_min.y)
	return min_size

#func _on_notify_property_list_changed() -> void:
	#emit_changed()
