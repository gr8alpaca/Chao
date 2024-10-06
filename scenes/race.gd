@tool
class_name Race extends Node3D

@export var waypoints: Node3D

@export var racers: Array[Pet]


func _ready() -> void:
	assert(waypoints, "No waypoints node set")

	_waypoints_child_order_changed()

	if Engine.is_editor_hint() and not waypoints.child_order_changed.is_connected(_waypoints_child_order_changed):
		waypoints.child_order_changed.connect(_waypoints_child_order_changed, CONNECT_DEFERRED)

	if Engine.is_editor_hint(): return

	for child: Node in get_node(^"Racers").get_children():
		if child is Pet and child not in racers: racers.append(child as Pet)

	begin_race()


func begin_race() -> void:
	var wp: Waypoint = waypoints.get_child(0)
	for pet: Pet in racers:
		pet.target_position = wp.get_path_point(pet.global_position)


func _waypoints_child_order_changed() -> void:
	var children: Array[Node] = waypoints.get_children().filter(func(x: Node) -> bool: return x and x is Waypoint)
	for i: int in children.size():
		children[i].next = children[i+1] if i < children.size() - 1 else null
		
