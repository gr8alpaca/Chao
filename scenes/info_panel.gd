@tool
class_name InfoPanel extends Panel

@onready var vbox: VBoxContainer = %StatDisplay

@export var info_scene: PackedScene = preload("res://scenes/stat_info.tscn"):
	set(val): info_scene = val if val else preload("res://scenes/stat_info.tscn")
		
@export var pet: Pet
		
@export var stats: Stats: set = set_stats

		
func _ready() -> void:
	Event.pet_interacted.connect(_on_pet_interacted)


func _on_pet_interacted(pet: Pet) -> void:
	self.pet = pet
	stats = pet.stats if pet else null


func open() -> void:
	pass


func close() -> void:
	pass

func set_stats(val: Stats) -> void:
	stats = val
	if not stats: return
	