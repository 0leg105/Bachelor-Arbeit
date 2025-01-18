extends Node
class_name GoapPlanner

@export var actions: Array[GoapAction]
@export var goals: Array[GoapGoal]
@onready var effect_action_table: Dictionary = create_effect_action_table()
var current_plan: Array[GoapAction] = []
var current_goal: GoapGoal = GoapGoal.new()
var current_state: Dictionary = {}
var create_plan: bool = false

func update(state_manager: StateManager) -> void:
	current_state = state_manager.get_current_state()
	var new_goal = get_best_goal()
	# Goal hat sich geändert oder Plan wird angefordert
	if current_goal != new_goal or create_plan:
		current_goal = new_goal
		create_new_plan()

func create_effect_action_table() -> Dictionary:
	var effect_action_table: Dictionary = {}
	for action in actions:
		for effect in action.get_effects():
			if not effect_action_table.has(effect):
				effect_action_table[effect] = []
			effect_action_table[effect].append(action)
	return effect_action_table

func get_best_goal() -> GoapGoal:
	var highest_priority_goal: GoapGoal = GoapGoal.new()
	for goal in goals:
		if goal.is_valid() and goal.get_priority() > highest_priority_goal.get_priority():
			highest_priority_goal = goal
	return highest_priority_goal

func create_new_plan() -> void:
	var current_state_of_goals: Dictionary = create_current_state_of_goals()
	var root_node: AStarNode = AStarNode.new(current_state_of_goals, current_goal.get_desired_state(), null, null)
	self.current_plan = a_star_algorithm(root_node)
	set_create_plan(false)

func a_star_algorithm(root_node: AStarNode) -> Array[GoapAction]:
	# Die open_list wird als PriorityQueue umgesetzt, um Performance zu verbessern
	var open_list: PriorityQueue = PriorityQueue.new()
	var closed_list: Dictionary = {}
	# Wurzelknoten wird in die open_list hinzugefügt
	open_list.push(root_node, root_node.get_f_score())
	while !open_list.is_empty():
		# Günstigester Knoten wird aus open_list genommen und entfernt
		var expanded_node: AStarNode = open_list.pop()
		# Sollte der günstigste Knoten erfüllt sein, dann soll ein Plan geliefert werden
		if expanded_node.is_satisfied():
			# Sequenz wird vom Zielknoten bis Wurzelknoten rekonstruiert
			return create_path(expanded_node)
		closed_list[expanded_node] = null
		# Ansonsten wird der Knoten weiter untersucht
		expand_node(expanded_node, open_list, closed_list)
	# Gibt es keine Knoten in der open_list, so gibt es keine Knoten die zum Ziel führen
	return []

func expand_node(expanded_node: AStarNode, open_list: PriorityQueue, closed_list: Dictionary) -> void:
	# Generiert alle möglichen Kindknoten des zu erweiterten Knoten
	for child_node in get_child_nodes(expanded_node):
		# Der Kindknoten darf nicht bereits erweitert worden sein, um erneute Verarbeitung zu vermeiden
		if child_node in closed_list:
			continue
		# Berechnung des g(n)
		var child_node_g_cost: int = expanded_node.get_g_score() + child_node.get_action().get_cost()
		# Sollte der Kindknoten sich bereits in der open_list befinden und teurer sein, dann gibt es keinen Grund diesen weiter zu verfolgen
		if open_list.has(child_node) and child_node_g_cost >= child_node.get_g_score():
			continue
		# Berechnung des h(n)
		var child_node_h_cost: int = child_node.get_unsatasfied_states().size()
		# Berechnung des f(n)
		var child_node_f_cost: int = child_node_g_cost + child_node_h_cost
		child_node.set_g_score(child_node_g_cost)
		child_node.set_f_score(child_node_f_cost)
		# Kindknoten wird in die open_list hinzugefügt
		open_list.push(child_node, child_node.get_f_score())

# Erstellt ein Dictionary wo die Zustände des Zieles nach dem derzeitigen Zustand überschrieben werden.
func create_current_state_of_goals() -> Dictionary:
	var current_state_of_goals: Dictionary = {}
	for state in current_goal.get_desired_state().keys():
		if current_state.has(state):
			current_state_of_goals[state] = current_state[state]
	return current_state_of_goals

# Sucht Kanten(Aktionen) welche die benötigten Zustände erfüllen können
func get_child_nodes(expanded_node: AStarNode) -> Array[AStarNode]:
	var child_nodes: Array[AStarNode] = []
	# Liest alle derzeitigen benötigten Zustände des Knoten aus
	for state in expanded_node.get_unsatasfied_states():
		var goal_value: bool = expanded_node.get_goal_state()[state]
		# Sucht Kanten mit passenden Effekten zur Erfüllung der benötigten Zustand
		if effect_action_table.has(state):
			for action in effect_action_table[state]:
				# Prüft ob Aktion im derzeitigen Zustand gültig ist
				if action.is_valid() == false:
					continue
				var effect_value: bool = action.get_effects()[state]
				# Prüft ob der Effekt der jeweiligen Aktion den benötigten Zuständ umsetzen kann
				if effect_value == goal_value:
					# Erstellt einen neunen Kindknoten, zu dem die Kante(Aktion) führt
					var child_node: AStarNode = expanded_node.apply_action(current_state, action)
					child_nodes.append(child_node)
	return child_nodes

func create_path(goal_node: AStarNode) -> Array[GoapAction]:
	var path: Array[GoapAction] = []
	var recursive_node: AStarNode = goal_node
	while recursive_node.get_parent_node() != null:
		path.append(recursive_node.get_action())
		recursive_node = recursive_node.get_parent_node()
	return path

func set_create_plan(create_plan: bool) -> void:
	self.create_plan = create_plan

func get_current_goal() -> GoapGoal:
	return self.current_goal

func get_current_plan() -> Array[GoapAction]:
	return self.current_plan

# Für MonitorFunctions und Debugging benötigt
func get_plan_length() -> int:
	return current_plan.size()

func print_plans(open_list: PriorityQueue, cheapest_node: AStarNode) -> void:
	var plans: Array[AStarNode] = open_list.get_plans()
	var best_plan: Array = create_path(cheapest_node)
	var actions: Array
	print("---------------------------------------------")
	print("goal: ", current_goal.get_goal_name())
	for action in best_plan:
		actions.append(action.get_action_name())
	print("best_plan actions: ", actions, " cost: ", cheapest_node.get_f_score())
	for plan in plans:
		var path: Array = create_path(plan)
		actions = []
		for action in path:
			actions.append(action.get_action_name())
		print("actions: ", actions, " cost: ", plan.get_f_score())
