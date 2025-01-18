extends Enemy
class_name GoapAgent

var goap_planner: GoapPlanner
var fsm: FiniteStateMachine
var action_sequence: Array[GoapAction]

func _enter_tree() -> void:
	super._enter_tree()
	goap_planner = $"GOAP Planner"
	fsm = $FiniteStateMachine

func _process(_delta: float) -> void:
	look_at_component.look_at_pos(state_manager.get_state("look_pos"))
	vision_component.update()
	goap_planner.update(state_manager)
	if action_sequence != goap_planner.get_current_plan():
		fsm.change_state(fsm.get_current_state(), "Action")
		action_sequence = goap_planner.get_current_plan()
	fsm.update(_delta)
	label_info.update(_delta)

func set_create_plan(create_plan: bool) -> void:
	goap_planner.set_create_plan(create_plan)

func get_action_sequence() -> Array:
	return action_sequence
