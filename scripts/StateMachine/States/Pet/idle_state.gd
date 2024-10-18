@tool
extends PetState

@export_range(0.0, 10.0, 0.25, "suffix:secs")
var wait_time_sec_min: float = 1.0

@export_range(0.0, 10.0, 0.25, "suffix:secs")
var wait_time_sec_max: float = 5.0

@export_range(0.0, 10.0, 0.25, "suffix:secs")
var max_wander_distance: float = 5.0

@export_range(0, 100, 2, "suffix:%")
var speed_modifier_percent: int = 100


var is_timer_active: bool

var current_timer: float


func _init() -> void:
	super(&"idle")


func enter() -> void:
	pet.speed_modifier = speed_modifier_percent / 100.0
	wander_random()


func exit() -> void:
	if pet.move_ended.is_connected(start_delay_timer):
		pet.move_ended.disconnect(start_delay_timer)

	pet.speed_modifier = 1.0
	current_timer = 0.0


func start_delay_timer() -> void:
	current_timer = randf_range(wait_time_sec_min, wait_time_sec_max)
	is_timer_active = true


func wander_random() -> void:
	pet.move_to_point(get_random_point())

	if not pet.move_ended.is_connected(start_delay_timer):
		pet.move_ended.connect(start_delay_timer, CONNECT_ONE_SHOT)


func update_process(delta: float) -> void:
	if not is_timer_active: return
	current_timer -= delta
	if current_timer <= 0.0:
		is_timer_active = false
		wander_random()


func _on_move_ended() -> void:
	if pet.target_position == pet.global_position:
		start_delay_timer()
	else:
		pet.move_ended.connect(start_delay_timer, CONNECT_ONE_SHOT)


func get_random_point(max_dist: float = max_wander_distance, origin:=Vector3.ZERO) -> Vector3:
	return Vector3(randf_range(-max_wander_distance, max_wander_distance) + origin.x, pet.position.y, randf_range(-max_wander_distance, max_wander_distance) + origin.z)


func set_pet(val: Pet) -> void:
	super(val)
	Event.garden_entered.connect(_on_garden_entered)

func _on_garden_entered(garden: Garden) -> void:
	transition_requested.emit(name)