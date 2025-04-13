class_name BackpackSquare
extends Control

@onready var highlight: ColorRect = preload("res://objects/ui/Highlight.tscn").instantiate()
@onready var collision: CollisionObject2D = $BackpackSquareCollision


func _ready() -> void:
	add_child(highlight)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if has_item() or data is not UIItem:
		return

	var ui_item: UIItem = data

	ui_item.get_parent().remove_child(ui_item)
	add_child(ui_item)


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true


func has_item() -> bool:
	return HelperFunctions.has_child(self, func x(child: Node) -> bool: return child is UIItem)


func get_item() -> UIItem:
	return HelperFunctions.find_child_with_func(
		self, func x(child: Node) -> bool: return child is UIItem
	)


func _on_backpack_square_collision_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()

	if parent is not UIItem:
		return

	# var ui_item: UIItem = parent

	highlight.visible = true


func _on_backpack_square_collision_area_exited(_area: Area2D) -> void:
	highlight.visible = false
