# 
@tool
class_name PetStateRace extends PetState


var path_points: PackedVector3Array

var distance_to_goal: float
# var path_distances: PackedFloat32Array

func _init() -> void:
	name = &"race"


func enter() -> void:
	pet.speed_modifier = 1.0
	pet.is_moving = false
	pet.emit_signal(Interactable.SIGNAL_ENABLED, false)
	

	Event.race_started.connect(_on_race_started, CONNECT_ONE_SHOT)
	pet.move_ended.connect(advance_path_point)


func update_physics_process(delta: float) -> void:
	if path_points.is_empty(): return

	distance_to_goal = pet.global_position.distance_to(path_points[0])

	for i: int in path_points.size() - 1:
		distance_to_goal += path_points[i].distance_to(path_points[i + 1])

	pet.emit_signal(&"distance_to_goal_changed", distance_to_goal, pet)


func exit() -> void:
	pet.is_moving = false
	pet.set_collision_layer_value(1, false)

func _on_race_entered(race: Race, waypoint: Waypoint) -> void:
	path_points = waypoint.get_race_path()
	
	transition_requested.emit(&"race")
	
	if not pet.has_user_signal(&"distance_to_goal_changed"):
		pet.add_user_signal(&"distance_to_goal_changed")

	pet.connect(&"distance_to_goal_changed", race.update_racer_position)


func advance_path_point() -> void:
	if path_points.is_empty():
		transition_requested.emit(&"tpose") # TODO: Make 'cheer' state
		return

	print("Moving to point: %1.0v" % path_points[0])
	pet.move_to_point(path_points[0])
	path_points.remove_at(0)


func _on_race_started() -> void:
	advance_path_point()


func set_pet(val: Pet) -> void:
	super(val)
	Event.race_entered.connect(_on_race_entered)
