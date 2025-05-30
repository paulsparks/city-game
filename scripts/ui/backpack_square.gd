class_name BackpackSquare
extends Control

@onready var highlight: ColorRect = preload("res://objects/ui/Highlight.tscn").instantiate()


func _ready() -> void:
	add_child(highlight)
	mouse_entered.connect(func x() -> void: highlight.visible = true)
	mouse_exited.connect(func x() -> void: highlight.visible = false)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is not UIItem:
		return

	var ui_item: UIItem = data

	if has_item() and get_item() != ui_item:
		var current_item: UIItem = get_item()
		remove_child(current_item)
		ui_item.get_parent().add_child(current_item)

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
