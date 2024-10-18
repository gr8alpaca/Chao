@tool
class_name StatInfo extends VBoxContainer

@export var stats: Stats: set = set_stats
		
@export var stat_name: StringName: set = set_stat_name
		

@export_group("Node References")
@export var name_label: Label
@export var value_label: Label
@export var bar: LevelProgressBar
	

func _ready() -> void:
	if value_label:
		value_label.text = "0000"
	if bar:
		bar.value = 0


func update_display() -> void:
	if value_label:
		value_label.text = "%04.0f" % (stats.get(stat_name) if stats and stat_name else 0.0)
	if bar:
		bar.value = 0


func _on_stats_changed() -> void:
	update_display()


func set_stat_name(sname: StringName = &"") -> void:
	stat_name = sname
	if stat_name and name_label:
		name_label.text = sname.capitalize()


func set_stats(val: Stats) -> void:
	if stats and stats.changed.is_connected(_on_stats_changed):
		stats.changed.disconnect(_on_stats_changed)
	if val and not val.changed.is_connected(_on_stats_changed):
		val.changed.connect(_on_stats_changed)

	stats = val

	update_display()
