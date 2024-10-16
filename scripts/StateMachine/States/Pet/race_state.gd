# 
@tool
extends PetState


func _init() -> void:
	name = &"race"


func enter() -> void:
	pet.speed_modifier = 1.0


func exit() -> void:
	pass
	

func update_process(delta: float) -> void:
	pass

func update_physics_process(delta: float) -> void:
	pass

func _on_race_entered(starting_waypoint: Waypoint) -> void:
	pass


func set_pet(val: Pet) -> void:
	super(val)
	Event.race_entered.connect(_on_race_entered)

func set_stats(val: Stats) -> void:
	super(val)
