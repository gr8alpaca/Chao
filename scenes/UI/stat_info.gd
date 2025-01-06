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
@export var value_label: Label
@export var value_delta_label: Label
@export var level_label: Label

@export var bar: LevelProgressBar

const POSITIVE_COLOR: Color = Color(0.70, 1.0, 0.70, 1.0)
const NEGATIVE_COLOR: Color = Color(1.0, 0.70, 0.70, 1.0)

var experience: int = 0


func _ready() -> void:
	value_delta_label.modulate.a = 0.0
	value_delta_label.set_deferred(&"size", value_label.size)
	bar.level_hit.connect(_on_level_up)
	update_display()
	
	if Engine.is_editor_hint(): return
	value_delta_label.material.set_shader_parameter(&"time_offset", randf() * TAU)
	value_delta_label.material.set_shader_parameter(&"max_distance", Vector2(5.0, 3.0))
	value_delta_label.material.set_shader_parameter(&"volatility", 1.3)


func set_font_sizes(main_fs: int = 28, level_fs : int = 10, level_up_fs: int = level_up_font_size) -> void:
	name_label.add_theme_font_size_override("font_size", main_fs)
	value_label.add_theme_font_size_override("font_size", main_fs)
	value_delta_label.add_theme_font_size_override("font_size", main_fs)
	level_label.add_theme_font_size_override("font_size", level_fs)
	level_up_font_size = main_fs + level_fs
	level_up_font_size = level_up_fs

func init(stat_name: StringName, stats: Stats) -> StatInfo:
	self.stat_name = stat_name
	self.stats = stats
	return self

func update_display() -> void:
	value_label.text = "%04.0f" % stats.get_experience(stat_name) if stats and stat_name else "0000"
	level_label.text = "LV. %2.0d" % stats.get_level(stat_name) if stats else "LV. 0"
	bar.value = stats.get_level_progress(stat_name) if stats else 0


func set_stat_name(sname: StringName = &"") -> void:
	stat_name = sname
	if stat_name and name_label:
		name_label.text = sname.capitalize()
	experience = stats.get_experience(stat_name, 0) if stats else 0


func _on_stats_changed() -> void:
	if experience == stats.get_experience(stat_name): return
	var delta: int = stats.get_experience(stat_name) - experience
	experience += delta
	display_xp_change(delta)


func set_stats(val: Stats) -> void:
	if stats and stats.changed.is_connected(_on_stats_changed):
		stats.changed.disconnect(_on_stats_changed)
	if val and not val.changed.is_connected(_on_stats_changed):
		val.changed.connect(_on_stats_changed)
	
	stats = val
	experience = stats.get_experience(stat_name, 0) if stats else 0


func _on_level_up() -> void:
	level_label.text = "LV. %2.0d" % (value_label.text.to_int() / Stats.EXPERIENCE_PER_LEVEL)
	const VELOCITY: Vector2 = Vector2(-8, -32)
	const DURATION_SEC: float = 1.3
	
	var ss:= Vector2(- get_theme_default_font().get_string_size("Level Up",0,-1,level_up_font_size).x - 8 , (size.y - get_theme_default_font().get_height(level_up_font_size))/2.0)
	var text_pop := TextPop.new().set_fade(TextPop.FADE_NORMAL | TextPop.FADE_COLOR).set_fs(level_up_font_size)\
	.set_alt_col(POSITIVE_COLOR).set_pos(ss).set_txt("Level Up").set_vel(VELOCITY)
	add_child(text_pop)
	text_pop.start(DURATION_SEC / speed_modifier)


func display_xp_change(delta: int) -> void:
	const MODULATE_TWEEN_DURATION_SEC: float = 0.67
	const PRE_ANIMATION_DELAY: float = 1.0
	
	set_value_delta_text(delta)
	value_delta_label.add_theme_color_override("font_color", POSITIVE_COLOR if delta > 0 else NEGATIVE_COLOR)
	
	var tw: Tween = create_tween()
	tw.tween_property(value_delta_label, ^"modulate:a", 1.0, MODULATE_TWEEN_DURATION_SEC * speed_modifier)
	
	tw.tween_interval(PRE_ANIMATION_DELAY * speed_modifier)
	
	tw.tween_callback(bar.add_value.bind(delta))
	
	# TEXT SPEED HERE
	tw.tween_method(set_value_delta_text, delta, 0, abs(delta) * speed_modifier / maxf(bar.fill_speed, 1.0)) 
	
	#tw.tween_property(value_delta_label, ^"modulate:a", 0.0, MODULATE_TWEEN_DURATION_SEC)
	

func set_value_delta_text(delta: int) -> void:
	value_label.text = "%04.0f" % (experience - delta * speed_modifier)
	if delta:
		value_delta_label.text = ("+" if delta > 0 else "-") + " %2.0d" % abs(delta)
	else:
		value_delta_label.modulate.a = 0.0


func get_experience() -> int:
	return (level_label.text.trim_prefix("LV. ").to_int() if level_label.text.trim_prefix("LV. ").is_valid_int() else 0) + bar.value

func _get_minimum_size() -> Vector2:
	return get_child(0).get_combined_minimum_size()
