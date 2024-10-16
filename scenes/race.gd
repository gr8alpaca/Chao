@tool
class_name Race extends Node3D

signal race_finished

@export var waypoints: Node3D

@export var racers: Array[Pet]

var placings: PackedInt32Array

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
	
	begin_race()


func init_racers() -> void:
	var racer_count: int = racers.size()
	var line_start: Vector3 = get_node(^"%StartingLineStart").global_position
	var line_end: Vector3 = get_node(^"%StartingLineEnd").global_position
	for i: int in racer_count:
		racers[i].global_position = line_start.lerp(line_end, inverse_lerp(0.0, racer_count-1, i))
		racers[i].emit_signal(Interactable.SIGNAL_ENABLED, false)
		racers[i].emit_signal(StateMachine.SIGNAL_FORCE_STATE, &"race")


func begin_race() -> void:

	var goal: Waypoint = get_waypoints()[-1]
	if not goal.body_entered.is_connected(_on_goal_reached):
		goal.body_entered.connect(_on_goal_reached)

	var wp: Waypoint = waypoints.get_child(0)
	for pet: Pet in racers:
		pet.target_position = wp.get_path_point()

# func get_pet_distance(pet: Pet) -> float:
# 	assert( pet or pet in racers, "Invalid pet input!")
# 	return 0.0

func _on_goal_reached(body: Node) -> void:
	if not body is Pet: return
	body.is_moving = false
	
	placings.push_back(racers.find(body as Pet, ))

	if placings.size() == racers.size():
		race_finished.emit()
		print_placings()


func print_placings() -> void:
	for i: int in placings.size():
		printt("%1.d ->" % i, racers[placings[i]].stats.name, racers[placings[i]])


func get_racer_distance_to_goal(racer: Pet) -> float:
	if racers.find(racer) in placings: return 0.0
	var accum: float = 0.0
	var waypoint: Waypoint = racer.get_meta(Waypoint.META_NEXT, get_waypoints()[0])
	while waypoint:
		accum += racer.global_position.distance_to(waypoint.global_position)
		waypoint = waypoint.next if waypoint.next != waypoint else null # Guard in case of recursion...
	return accum


func _waypoints_child_order_changed() -> void:
	var children: Array[Waypoint] = get_waypoints()
	for i: int in children.size():
		children[i].next = children[i + 1] if i < children.size() - 1 else null
		

func get_waypoints() -> Array[Waypoint]:
	var pts: Array[Waypoint]
	pts.assign(waypoints.get_children().filter(func(x: Node) -> bool: return x and x is Waypoint))
	return pts