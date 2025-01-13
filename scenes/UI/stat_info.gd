@tool
class_name StatInfo extends Control

@export var stat_name: StringName: set = set_stat_name
@export var stats: Stats: set = set_stats

@export_range(0.1, 3.0, 0.05, "suffix:/1.0") 
var speed_modifier: float = 1.0

@export_group("Level Up Text")
@export var level_up_font_size: int = 40

@export_group("Node References")
@export var name_label: Label
@export var point_label: Label
@export var point_delta_label: Label
@export var level_label: Label

@export var bar: LevelProgressBar

const POSITIVE_COLOR: Color = Color(0.70, 1.0, 0.70, 1.0)
const NEGATIVE_COLOR: Color = Color(1.0, 0.70, 0.70, 1.0)


func _ready() -> void:
	point_delta_label.modulate.a = 0.0
	
	update_display()
	
	if Engine.is_editor_hint(): return
	point_delta_label.material.set_shader_parameter(&"time_offset", randf() * TAU)
	point_delta_label.material.set_shader_parameter(&"max_distance", Vector2(5.0, 3.0))
	point_delta_label.material.set_shader_parameter(&"volatility", 1.3)


func init(stat_name: StringName, stats: Stats) -> StatInfo:
	self.stats = stats
	self.stat_name = stat_name
	return self


func update_display() -> void:
	if point_label: set_point_label_text(get_points())
	if level_label: set_level_label_text(get_level())
	if bar: bar.init_value(get_level_progress())


func disconnect_callables(callables: Array[Callable]) -> void:
	for c: Dictionary in get_incoming_connections():
		if not c.callable in callables: continue
		c.signal.disconnect(c.callable)


func reconnect_stats() -> void:
	disconnect_callables([_on_xp_change, _on_level_changed])
	if stats and stat_name:
		stats.connect_signal(stat_name, "xp", _on_xp_change)
		stats.connect_signal(stat_name, "level", _on_level_changed)
	
	update_display()



func _on_bar_level_up(delta: int) -> void:
	const VELOCITY: Vector2 = Vector2(-8, -32)
	const DURATION_SEC: float = 1.8 
	
	level_label.text = "LV. %2.0d" % (get_level())
	
	var ss:= Vector2(- get_theme_default_font().get_string_size("Level Up",0,-1,level_up_font_size).x - 8 , (size.y - get_theme_default_font().get_height(level_up_font_size))/2.0)
	var text_pop := TextPop.new().set_fade(TextPop.FADE_NORMAL | TextPop.FADE_COLOR).set_fs(level_up_font_size).set_alt_col(POSITIVE_COLOR).set_pos(ss).set_txt("Level Up").set_vel(VELOCITY)
	add_child(text_pop)
	text_pop.start(DURATION_SEC / speed_modifier + abs(delta) / maxf(bar.fill_speed, 1.0))
	animate_point_change(delta)


func animate_point_change(delta: int) -> void:
	#const MODULATE_TWEEN_
	const MODULATE_TWEEN_DURATION_SEC: float = 0.4
	const PRE_ANIMATION_DELAY: float = 1.0
	
	set_point_delta_label_text(delta)
	point_delta_label.add_theme_color_override("font_color", POSITIVE_COLOR if delta > 0 else NEGATIVE_COLOR)
	
	var tw: Tween = create_tween()
	tw.tween_property(point_delta_label, ^"modulate:a", 1.0, MODULATE_TWEEN_DURATION_SEC / speed_modifier)
	tw.tween_interval(PRE_ANIMATION_DELAY / speed_modifier)
	tw.tween_method(set_point_delta_label_text, delta, 0, abs(delta) / maxf(bar.fill_speed, 1.0)) 


func set_point_delta_label_text(delta: int) -> void:
	set_point_label_text(get_points() - delta)
	if delta:
		point_delta_label.text = ("+" if delta > 0 else "-") + " %2.0d" % abs(delta)
	else:
		point_delta_label.modulate.a = 0.0

func _on_xp_change(delta: int) -> void:
	bar.add_value(delta)

func _on_level_changed(delta: int) -> void:
	if bar.level_hit.is_connected(_on_bar_level_up):
		bar.level_hit.disconnect(_on_bar_level_up)
	bar.level_hit.connect(_on_bar_level_up.bind(delta), CONNECT_ONE_SHOT)

func get_points() -> int:
	return stats.get_points(stat_name, 0) if stats else 0
func get_level() -> int:
	return stats.get_level(stat_name, 0) if stats else 0
func get_xp() -> int:
	return stats.get_xp(stat_name, 0) if stats else 0
func get_level_progress() -> int:
	return stats.get_level_progress(stat_name, 0) if stats else 0

func set_font_sizes(main_fs: int = 28, level_fs : int = 10, level_up_fs: int = level_up_font_size) -> void:
	name_label.add_theme_font_size_override("font_size", main_fs)
	point_label.add_theme_font_size_override("font_size", main_fs)
	point_delta_label.add_theme_font_size_override("font_size", main_fs)
	level_label.add_theme_font_size_override("font_size", level_fs)
	level_up_font_size = main_fs + level_fs
	level_up_font_size = level_up_fs


func set_stat_name(sname: StringName = &"") -> void:
	stat_name = sname
	set_indexed(^"name_label:text", sname.capitalize())
	reconnect_stats()


func set_stats(val: Stats) -> void:
	if stats == val: return 
	stats = val
	reconnect_stats()

func set_point_label_text(val: int) -> void:
	if point_label: point_label.text = "%04.0d" % val

func set_level_label_text(val: int) -> void:
	if point_delta_label: point_delta_label.text = "LV. %2.0d" % val

func _get_minimum_size() -> Vector2:
	return get_child(0).get_combined_minimum_size()
