@tool
class_name InfoPanel extends Control

@onready var vbox: VBoxContainer = %StatDisplay

@export var info_scene: PackedScene = preload("res://scenes/UI/stat_info.tscn"):
	set(val): info_scene = val if val else preload("res://scenes/UI/stat_info.tscn")


func _ready() -> void:
	var vbox := get_node(^"%StatDisplay")
	for prop: StringName in Stats.VISIBLE_STATS:
		var info_display: StatInfo = info_scene.instantiate()
		info_display.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
		info_display.stat_name = prop
		vbox.add_child(info_display)
	
	propagate_call(&"set_use_parent_material", [true])
	use_parent_material = false
	material.set_shader_parameter(&"time_offset", randf() * TAU)


func set_stats(stats: Stats) -> void:
	if stats: for panel: StatInfo in get_info_panels():
		panel.set_stats(stats)
		panel.update_display()


func open(delay_sec: float = 0.0) -> void:
	pass

func close() -> void:
	pass

func get_info_panels() -> Array[StatInfo]:
	var items: Array[StatInfo]
	for panel : StatInfo in get_node(^"%StatDisplay").get_children():
		items.push_back(panel)
	return items
