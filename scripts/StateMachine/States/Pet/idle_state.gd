@tool
class_name PetStateIdle extends PetState

@export_range(0.0, 10.0, 0.25, "suffix:secs")
var wait_time_sec_min: float = 1.0

@export_range(0.0, 10.0, 0.25, "suffix:secs")
var wait_time_sec_max: float = 5.0

@export_range(0.0, 10.0, 0.25, "suffix:secs")
var max_wander_distance: float = 5.0

@export_range(0, 100, 2, "suffix:%")
var speed_modifier_percent: int = 100

var speed: float = 0.1

var current_timer: float


func _init() -> void:
	super(&"idle")


func enter() -> void:
	speed = pet.speed * speed_modifier_percent / 100.0
	current_timer = randf_range(wait_time_sec_min, wait_time_sec_max)

func exit() -> void:
	pet.speed_modifier = 1.0
	pet.is_moving = false

func wander_random() -> void:
	current_timer = randf_range(wait_time_sec_min, wait_time_sec_max)
	pet.target_position = get_random_point()
	#pet.is_moving = true

func update_physics_process(delta: float) -> void:
	pet.move_towards_target_and_rotate(delta, speed)
	if not pet.is_moving:
		current_timer -= delta
		if current_timer <= 0.0:
			wander_random()

func get_random_point(max_dist: float = max_wander_distance, origin:=Vector3.ZERO) -> Vector3:
	return Vector3(randf_range(-max_wander_distance, max_wander_distance) + origin.x, pet.position.y, randf_range(-max_wander_distance, max_wander_distance) + origin.z)
