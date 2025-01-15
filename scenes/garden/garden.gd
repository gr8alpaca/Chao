@tool
class_name Garden extends Node3D

const MAX_DISTANCE: float = 3.0

#@export var interact_menu_scene: PackedScene

var pet_stats: Stats
var interact_menu: InteractMenu
var block_free: bool = true

func _init() -> void:
	if Engine.is_editor_hint(): return
	interact_menu = load("res://scenes/UI/interact_menu.tscn").instantiate()
	interact_menu.name = &"InteractMenu"
	add_child(interact_menu, true)
	interact_menu.start_week_pressed.connect(_on_start_week_pressed)

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	if not pet_stats:
		set_stats(Stats.new())

func _ready() -> void:
	if Engine.is_editor_hint(): return


func check_pet_status() -> void:
	assert(is_inside_tree() and get_pet() and pet_stats)

func set_stats(stats: Stats) -> void:
	pet_stats = stats
	
	var pet: Pet = get_pet()
	pet.connect(Interactable.SIGNAL_INTERACTION_STARTED, interact_menu.set_pet.bind(pet))
	pet.stats = stats


func _on_start_week_pressed(schedule: Array[Activity]) -> void:
	get_pet().emit_signal(StateMachine.SIGNAL_STATE, &"idle")
	emit_signal(Main.SIGNAL_EXIT)
	
	for i: int in schedule.size():
		var act: Activity = schedule[i]
		var scene: ActivityScene = act.get_scene().instantiate()
		scene.init(pet_stats, act, i+1)
		emit_signal(Main.SIGNAL_QUEUE_ADD, scene)
	
	emit_signal(Main.SIGNAL_QUEUE_ADD, self)
	
	if is_inside_tree():
		await tree_exited
	
	emit_signal(Main.SIGNAL_QUEUE_ADVANCE)
	

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY when not Engine.is_editor_hint():
			pass
		
		NOTIFICATION_PREDELETE when not Engine.is_editor_hint() and block_free:
			cancel_free()


func get_pet() -> Pet:
	for child: Node in get_children():
		if child is Pet: return child
	return null
