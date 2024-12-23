@tool
class_name WeekOverlay extends Control

@export var stat_info_display_scene: PackedScene = preload("res://scenes/stat_info.tscn")
@export var activity: Activity : set = set_activity
@export var stats: Stats

func open(activity: Activity, stats: Stats) -> void:
	self.stats = stats
	self.activity = activity

func set_activity(val: Activity) -> void:
	activity = val
	set_stat_displays(activity.get_stat_changes() if activity else PackedStringArray())

func set_stat_displays(stat_names: PackedStringArray) -> void:
	var hbox: HBoxContainer = get_node(^"%StatsHBox")
	
	for child: Node in hbox.get_children():
		hbox.remove_child(child)
		child.free()
		
	for stat_name: String in stat_names:
		var info: StatInfo = stat_info_display_scene.instantiate()
		info.stat_name = stat_name
		info.stats = stats
		hbox.add_child(info)
