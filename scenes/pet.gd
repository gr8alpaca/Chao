@tool
class_name Pet extends CharacterBody3D

@export var stats: Stats

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 9.8)


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# velocity.y -=  gravity
	# move_and_slide()