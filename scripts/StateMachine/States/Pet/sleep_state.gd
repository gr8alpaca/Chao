# 
@tool
extends PetState

var text_particles: TextParticles

func _init() -> void:
	super(&"sleep")

func enter() -> void:
	pet.rotation_degrees = Vector3(90.0, 0.0 , 0.0)
	assert(not text_particles, "Text particles is not null!")
	text_particles = TextParticles.new()
	pet.add_child(text_particles)
	text_particles.position.y = 0.4
	text_particles.position.z = -0.2
	text_particles.rotation = -pet.rotation
	

func exit() -> void:
	pet.rotation_degrees = Vector3(0.0, 0.0 , 0.0)
	pet.remove_child(text_particles)
	text_particles.free()
	text_particles = null

func update_process(delta: float) -> void:
	pet.rotation_degrees = Vector3(90.0, 0.0 , 0.0)

func update_physics_process(delta: float) -> void:
	pass
	
#
#func on_mouse_entered() -> void:
	#pass
#
#func on_mouse_exited() -> void:
	#pass
#
#
#func on_input(event: InputEvent) -> void:
	#pass
#
#
#func on_unhandled_input(event: InputEvent) -> void:
	#pass
