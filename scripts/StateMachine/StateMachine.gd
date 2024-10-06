@tool
class_name StateMachine extends Node
const GROUP: StringName = &"StateMachine"

signal state_changed(old_state: State, new_state: State)

@export_category("States")
@export var state_resources: Array[State] = []
@export var add_resource_by_script: Script:
	set(val):
		if val and val.can_instantiate():
			var instance: Object = val.new()
			if not instance is State:
				printerr("You can only add scripts that extend 'State' to State Machine.")
				return
			state_resources.push_back(instance as State)
			notify_property_list_changed.call_deferred()

@export var initial_state_name: String

@export_category("State References")
@export var reference_variable_names: Array[StringName] = []
@export var reference_variable_values: Array[Node] = []

@export_category("Debug")
@export var debug_label: Label
@export var debug_mode: bool = false

## StateName -> State
@export var states: Dictionary = {}

var state_locked: bool = false: set = _set_state_locked
var current_state: State: set = _set_current_state
var current_state_name: StringName = &""

var parallel_states: Array[State]

func _set_current_state(new_state: State) -> void:
		if not new_state or new_state == current_state: return

		var old_state: State = current_state

		if debug_mode:
			print("CALLED TRANSITION : %s -> %s" % [current_state_name, new_state.name])

		if current_state: current_state.exit()
		
		current_state = new_state
		current_state_name = current_state.name

		if debug_label: debug_label.text = current_state_name

		current_state.enter()
		
		state_changed.emit(old_state, current_state)

func _ready() -> void:
	
	var parent: Node = get_parent()
	if not parent.is_node_ready(): await parent.ready

	for state: State in state_resources:

		states[state.name] = state.duplicate()
		states[state.name].transition_requested.connect(_on_transition_requested, CONNECT_DEFERRED)
		states[state.name].parallel_started.connect()
		states[state.name].parallel_ended.connect()
		## Sets custom reference variables if applicable
		for j: int in reference_variable_values.size():
			states[state.name].set(reference_variable_names[j], reference_variable_values[j])
	
	if initial_state_name:
		current_state = get_state(initial_state_name)

func get_state(state_name: String) -> State:
	return states.get(state_name)

func _set_state_locked(set_locked: bool) -> void:
	state_locked = set_locked

#region Signals 

## Sets state regardless of 'state_locked'
func _on_force_state(state_name: String) -> void:
	if states.has(state_name): current_state = get_state(state_name)
	else: print("Tried to force non-existent state: %s" %str(state_name))

## If not state_locked will set current state = get_state(state_name)
func _on_transition_requested(state_name: String) -> void:
	if state_locked: return
	current_state = get_state(state_name)

func _on_lock_state(set_locked: bool) -> void:
	state_locked = set_locked

func _on_parallel_started(state: State) -> void:
	if not state in parallel_states:
		parallel_states.push_back(state)

func _on_parallel_ended(state: State) -> void:
	if state in parallel_states:
		parallel_states.erase(state)

#endregion Signals





#region Updates


func _process(delta: float) -> void:
	if current_state: current_state.update_process(delta)

func _physics_process(delta: float) -> void:
	if current_state: current_state.update_physics_process(delta)

func on_input(event: InputEvent) -> void:
	if current_state: current_state.on_input(event)

func on_unhandled_input(event: InputEvent) -> void:
	if current_state: current_state.on_unhandled_input(event)

func on_gui_input(event: InputEvent) -> void:
	if current_state: current_state.on_gui_input(event)

func on_mouse_entered() -> void:
	if current_state: current_state.on_mouse_entered()

func on_mouse_exited() -> void:
	if current_state: current_state.on_mouse_exited()

func on_focus_entered() -> void:
	if current_state: current_state.on_focus_entered()

func on_focus_exited() -> void:
	if current_state: current_state.on_focus_exited()


#endregion

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			add_to_group(GROUP)
			get_parent().set_meta(GROUP, self)
		NOTIFICATION_EXIT_TREE:
			get_parent().remove_meta(GROUP)


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary]
	props.append({
		name=&"add_state_by_script...",
		type=TYPE_OBJECT,

	})

	return props