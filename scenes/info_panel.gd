@tool
class_name InfoPanel extends Control

@onready var vbox: VBoxContainer = %StatDisplay

@export var info_scene: PackedScene = preload("res://scenes/stat_info.tscn"):
	set(val): info_scene = val if val else preload("res://scenes/stat_info.tscn")

@export var pet: Pet

@export var stats: Stats: set = set_stats


func _ready() -> void:
	var vbox := get_node(^"%StatDisplay")
	for prop: StringName in Stats.VISIBLE_STATS:
		var info_display: StatInfo = info_scene.instantiate()
		info_display.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
		info_display.stat_name = prop
		vbox.add_child(info_display)
	
	if Engine.is_editor_hint(): return
	
	Event.interaction_started.connect(_on_interaction_started)


func _on_interaction_started(pet: Pet) -> void:
	self.pet = pet
	stats = pet.stats if pet else null


func open(delay_sec: float = 0.0) -> void:
	emit_signal(Animator.SIGNAL_SHOW, delay_sec)

func close() -> void:
	emit_signal(Animator.SIGNAL_HIDE)


func set_stats(val: Stats) -> void:
	stats = val
