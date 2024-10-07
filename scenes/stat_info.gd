@tool
class_name StatInfo extends VBoxContainer

@export var stats: Stats
		
@export var stat_name: StringName
		

@export_group("Node References")
@export var name_label: Label
@export var value_label: Label
@export var bar: LevelProgressBar


func _ready() -> void:
	assert(stats, "NO STATS SET!")
	if not stats.changed.is_connected(_on_stats_changed):
			stats.changed.connect(_on_stats_changed)
	name_label.text = stat_name
	update_labels()


func set_info(stat: StringName, stats: Stats) -> void:
	stat_name = stat
	self.stats = stats

func clear_display() -> void:
	value_label.text = "000"
	bar.value = 0
func update_labels() -> void:
	var stat_value: float = get_indexed("stats:%s" %stat_name) if get_indexed("stats:%s" %stat_name) else 0.0
	value_label.text = "%03.f" % stat_value


func _on_stats_changed() -> void:
	update_labels()