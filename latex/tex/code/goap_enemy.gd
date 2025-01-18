extends Npc
class_name GoapAgent

var goap_planner: GoapPlanner
var action_sequence: Array[GoapAction]
var current_step: int

func _enter_tree() -> void:
	super._enter_tree()
	goap_planner = $"GOAP Planner"

func update(_delta: float) -> void:
	#look_at_component.look_at_pos(state_manager.get_state("look_pos"))
	vision_component.update()
	if goap_planner.update(state_manager):
		current_step = 0
		action_sequence = goap_planner.get_current_sequence()
	label_info.update(_delta)
	follow_sequence(_delta)

func follow_sequence(delta) -> void:
	if action_sequence.is_empty() or current_step >= action_sequence.size() or action_sequence[current_step] == null or not action_sequence[current_step].is_valid():
		goap_planner.set_create_sequence(true)
		return
	label_info.set_current_action(action_sequence[current_step])
	if action_sequence[current_step].update(delta):
		current_step += 1
	return
