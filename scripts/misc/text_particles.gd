@tool
class_name TextParticles extends CPUParticles3D

func _init(text: String = "Z", font_size: int = 30) -> void:
	amount = 3
	lifetime = 0.5
	speed_scale = 0.5
	fixed_fps = 60
	visibility_aabb = AABB(Vector3(-1.0, -1.0, -2.0), Vector3(2.0, 2.0, 3.0))
	local_coords = true
	
	mesh = TextMesh.new()
	mesh.text = text
	mesh.font_size = font_size
	mesh.depth = 0.0
	mesh.width = 100
	mesh.offset.y = font_size
	
	mesh.material = StandardMaterial3D.new()
	mesh.material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	mesh.material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mesh.material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh.material.billboard_keep_scale = true
	
	direction = Vector3(0.5, 1.0, -1.0)
	spread = 0.0
	initial_velocity_min = 2.5
	initial_velocity_max = 2.5
	
	scale_amount_curve = Curve.new()
	scale_amount_curve.clear_points()
	scale_amount_curve.add_point(Vector2(0.0, 0.7), 0.0, 0.0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
	scale_amount_curve.add_point(Vector2(0.3, 1.0), 0.0, 0.0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
	scale_amount_curve.add_point(Vector2(0.65, 1.0), 0.0, 0.0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
	scale_amount_curve.add_point(Vector2(1.0, 0.5), -2.0, 0.0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
	
