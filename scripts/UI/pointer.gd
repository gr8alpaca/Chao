@tool
class_name Pointer extends Control

const TEXTURE_REGION: Rect2i = Rect2i(52, 146, 421, 237)
const TEXTURE: Texture2D = preload("res://assets/UI/hand_icon.png")


static func draw_pointer(control: Control, draw_on_right: bool = true) -> void:
	const SIZE: Vector2 = Vector2(-128, 64)
	const POINTER_OFFSET_PIXELS: Vector2 = Vector2(10, 0)
	const TIME_SECS: float = 1.50
	const MOVE_PIXELS: int = 64
	const TOTAL_FRAMES: int = MOVE_PIXELS * 2
	const SLICE_TIME_SECS: float = TIME_SECS / TOTAL_FRAMES

	var draw_size: Vector2 = SIZE if draw_on_right else SIZE * Vector2(-1, 1)
	var start_position: Vector2 = (control.size * Vector2.RIGHT) + POINTER_OFFSET_PIXELS if draw_on_right else - POINTER_OFFSET_PIXELS + Vector2(SIZE.x, 0)

	for i: int in TOTAL_FRAMES:
		var t: float = inverse_lerp(0, TOTAL_FRAMES, i)
		var pos_offset: Vector2 = Vector2(i if i < MOVE_PIXELS else TOTAL_FRAMES - i, 0) 
		if not draw_on_right: pos_offset *= Vector2(-1, 0)

		control.draw_animation_slice(TIME_SECS, t * TIME_SECS, t * TIME_SECS + SLICE_TIME_SECS, )
		control.draw_texture_rect_region(TEXTURE, Rect2(start_position + pos_offset, draw_size), TEXTURE_REGION, Color.WHITE, false)
