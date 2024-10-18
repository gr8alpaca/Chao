@tool
class_name Race extends Node3D

@export var waypoints: Node3D

@export var racers: Array[Pet]

var racer_distances: Dictionary
var placings: Array[Pet]

func _ready() -> void:
	assert(waypoints, "No waypoints node set")
	
	_waypoints_child_order_changed()

	if Engine.is_editor_hint():
		if not waypoints.child_order_changed.is_connected(_waypoints_child_order_changed):
			waypoints.child_order_changed.connect(_waypoints_child_order_changed, CONNECT_DEFERRED)
		return

	assert(get_waypoints().size() > 0, "NO WAYPOINTS FOUND!")

	for child: Node in get_node(^"Racers").get_children():
		if child is Pet and child not in racers:
			racers.append(child as Pet)

	init_racers()
	Event.race_entered.emit(self, get_waypoints()[0])
	create_tween().tween_callback(begin_race).set_delay(1.5)


func init_racers() -> void:
	var racer_count: int = racers.size()

	var line_start: Vector3 = get_node(^"%StartingLineStart").position
	var line_end: Vector3 = get_node(^"%StartingLineEnd").position
	

	for i: int in racer_count:
		racers[i].position = line_start.lerp(line_end, inverse_lerp(0, racer_count-1, i) if racer_count > 1 else 0.5) 
		racers[i].look_at(racers[i].position + Vector3.RIGHT)
		racers[i].emit_signal(Interactable.SIGNAL_ENABLED, false)




func begin_race() -> void:
	var goal: Waypoint = get_waypoints()[-1]
	if not goal.body_entered.is_connected(_on_goal_reached):
		goal.body_entered.connect(_on_goal_reached)

	Event.race_started.emit()


func _on_goal_reached(body: Node) -> void:
	if not body is Pet: return
	body.is_moving = false
	
	if body not in placings:
		placings.push_back(body as Pet)

	if placings.size() == racers.size():
		end_race()


func end_race() -> void:
	Event.race_finished.emit(self)
	print_placings()


func print_placings() -> void:
	for i: int in placings.size():
		printt("%1.0d: " % i, placings[i])



func update_racer_position(distance_to_goal: float, racer: Pet) -> void:
	racer_distances[racer] = distance_to_goal


func _waypoints_child_order_changed() -> void:
	var children: Array[Waypoint] = get_waypoints()
	for i: int in children.size():
		children[i].next = children[i + 1] if i < children.size() - 1 else null
		

func get_waypoints() -> Array[Waypoint]:
	var pts: Array[Waypoint]
	pts.assign(waypoints.get_children().filter(func(x: Node) -> bool: return x and x is Waypoint))
	return pts
