class_name BackpackSquare
extends Control

var occupied: bool = false

@onready var highlight: ColorRect = preload("res://objects/ui/Highlight.tscn").instantiate()
@onready var collision: CollisionObject2D = $BackpackSquareCollision


func _ready() -> void:
	add_child(highlight)


func place_item_on_square(ui_item: UIItem) -> void:
	if has_item():
		print("has " + get_item().get_item().name)
		return

	print(ui_item.get_item().name)

	# ui_item_parent_backpack_square.occupied = false
	ui_item.get_parent().remove_child(ui_item)
	# add_child(ui_item)


func has_item() -> bool:
	return HelperFunctions.has_child(self, func x(child: Node) -> bool: return child is UIItem)


func get_item() -> UIItem:
	return HelperFunctions.find_child_with_func(
		self, func x(child: Node) -> bool: return child is UIItem
	)
