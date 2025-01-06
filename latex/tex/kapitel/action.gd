extends Node
class_name GoapAction

var character_body: Enemy
var state_manager: StateManager

func _enter_tree() -> void:
	character_body = get_parent().get_parent()
	state_manager = character_body.get_state_manager()

func get_action_name() -> String: return ""

func get_cost() -> int:
	return 0

func is_valid() -> bool:
	return true

func get_preconditions() -> Dictionary:
	return {}

func get_effects() -> Dictionary:
	return {}

func perform(_delta: float) -> bool:
	return false
