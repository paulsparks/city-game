class_name BackpackSquare
extends Control

signal item_state_changed

@onready var highlight: ColorRect = preload("res://objects/ui/Highlight.tscn").instantiate()


func _ready() -> void:
	add_child(highlight)
	mouse_entered.connect(func x() -> void: highlight.visible = true)
	mouse_exited.connect(func x() -> void: highlight.visible = false)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var ui_item: UIItem = data
	ui_item.get_parent().remove_child(ui_item)
	add_child(ui_item)
	item_state_changed.emit(ui_item)


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	if not has_item():
		return true

	return false


func has_item() -> bool:
	return HelperFunctions.has_child(self, func x(child: Node) -> bool: return child is UIItem)
