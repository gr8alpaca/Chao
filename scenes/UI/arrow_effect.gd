@tool
class_name ArrowEffect extends Control

const SCALE_DELTA_MAX: float = 0.5
const SCALE_MIN: float = 0.35
const SCALE_MAX: float = 2.0

@export_range(1, 20, 1, "or_greater") 
var arrow_count: int = 5:
	set(val):
		arrow_count = val
		#randomize_arrows()

@export var font: Font:
	get: return font if font else get_theme_default_font()

@export_range(8, 32, 1, "or_greater", "or_less")
var font_size: int = 12

@export_range(0, 16, 1,)
var font_outline: int = 12

@export_range(0.1, 5.0, 0.1, "or_greater", "suffix:s")
var cycle_duration_sec: float = 2.5

@export_range(0.0, 0.8, 0.01,)
var cycle_delta_max: float = 0.25

# [X-Position ratio, Scale, Cycle_Seconds]
var arrow_info: PackedFloat32Array


func _draw() -> void:
	#draw_bg()
	draw_arrows()


func draw_arrows() -> void:
	var arrows_info:= randomize_arrows()
	for i: int in arrow_count:
		var idx: int = i * 3 


func draw_arrow(x_pos: float, arrow_scale: float, cycle_seconds: float) -> void:
	const FRAMES_PER_SECOND: int = 60
	
	var total_frames: int = FRAMES_PER_SECOND * cycle_seconds
	
	for frame: int in total_frames:
		var t: float = inverse_lerp(0, total_frames - 1 , frame)
		
	


func randomize_arrows() -> PackedFloat32Array:
	var arrow_info: PackedFloat32Array
	arrow_info.resize(arrow_count * 3)
	
	var x_offset: float = 2.0/float(arrow_count)
	var ratio_delta_max: float = 4.0/ float(arrow_count)
	
	for arrow_idx: int in arrow_count:
		var i: int =  arrow_idx * 3
		var t: float = inverse_lerp(0, arrow_count, arrow_idx) + x_offset
		arrow_info[i] = randf_range(-ratio_delta_max, ratio_delta_max)
		arrow_info[i + 1] = 1.0 + randf_range(-SCALE_DELTA_MAX, SCALE_DELTA_MAX)
		arrow_info[i + 2] = randf_range(cycle_duration_sec * (1.0 - cycle_delta_max), cycle_duration_sec * (1.0 + cycle_delta_max))
	
	return arrow_info


func draw_bg() -> void:
	const MAX_GRADIENT_OPACITY: float = 0.35
	const BASE_COLOR: Color = Color.FOREST_GREEN
	const RING_SIZE: float = 2.0
	
	var center: Vector2 = size/2.0
	var max_radius: float = minf(center.x, center.y)
	var ring_count: int = maxi(int(max_radius/RING_SIZE), 1)
	print("RingCount: %d" % ring_count)
	
	for i: int in ring_count:
		var t: float = inverse_lerp( 0, ring_count - 1, i )
		#print("%.2f" % t)
		draw_circle(
				center, 
				t * max_radius + RING_SIZE/2.0, 
				Color.FOREST_GREEN, #Color(BASE_COLOR, (1.0 - t) * MAX_GRADIENT_OPACITY), 
				false, RING_SIZE, true)
