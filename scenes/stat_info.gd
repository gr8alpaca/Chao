@tool
class_name StatInfo extends VBoxContainer

@export var stats: Stats: set = set_stats
		
@export var stat_name: StringName: set = set_stat_name
		

@export_group("Node References")
@export var name_label: Label
@export var value_label: Label
@export var level_label: Label

@export var bar: LevelProgressBar
	

var experience: int = 0


func _ready() -> void:
	if bar:
		bar.level_hit.connect(_on_level_up)

	if value_label:
		value_label.text = "0000"
	if bar:
		bar.value = 0



func update_display() -> void:
	
	if value_label:
		value_label.text = "%04.0f" % (stats.get_level_progress(stat_name) if stats and stat_name else 0.0)
	
	if level_label:
		level_label.text = "LV. %2.0d" % stats.get_level_progress(stat_name) if stats else "LV. 0"
	
	if bar:
		bar.value = 0


func set_stat_name(sname: StringName = &"") -> void:
	stat_name = sname
	if stat_name and name_label:
		name_label.text = sname.capitalize()


func _on_experience_changed(sname: StringName, new_experience_amount: int) -> void:
	if sname == stat_name:
		pass


func set_stats(val: Stats) -> void:
	if stats and stats.experience_changed.is_connected(_on_experience_changed):
		stats.experience_changed.disconnect(_on_experience_changed)
	if val and not val.experience_changed.is_connected(_on_experience_changed):
		val.experience_changed.connect(_on_experience_changed)

	stats = val

	experience = stats.get_experience(stat_name, 0) if stats else 0

	if stat_name:
		update_display()


func _on_level_up() -> void:
	pass


func animate_experience(delta: int = 0) -> void:
	if not delta: return
	
	var current_experience: int = bar.value
	var current_level: int = level_label.text.trim_prefix("LV. ").to_int()


func get_experience() -> int:
	return (level_label.text.trim_prefix("LV. ").to_int() if level_label.text.trim_prefix("LV. ").is_valid_int() else 0) + bar.value