class_name HelperFunctions


## Find a node's child using a filter function that takes a child node and returns true or false.
## Returns the first node found, or null if none are found.
static func find_child_with_func(node: Node, filter: Callable) -> Node:
	for child: Node in node.get_children():
		var child_matches_condition: bool = filter.call(child)

		if child_matches_condition:
			return child

	return null


static func has_child(node: Node, filter: Callable) -> bool:
	return find_child_with_func(node, filter) != null
