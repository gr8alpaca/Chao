@tool
class_name FlagSprite3D extends Sprite3D
const TEXTURE: Texture2D = preload("res://assets/icon_flag.png")

func _init() -> void:
	texture = TEXTURE
	offset.y = 8
	pixel_size = 0.02
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	double_sided = false
	no_depth_test = true
	alpha_cut = ALPHA_CUT_DISCARD
	alpha_scissor_threshold = 0.6
	
