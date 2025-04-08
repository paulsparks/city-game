class_name BackpackSquare
extends Control

signal item_state_changed


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var ui_item: UIItem = data
	ui_item.get_parent().remove_child(ui_item)
	add_child(ui_item)
	item_state_changed.emit(ui_item)


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	if len(get_children()) == 0:
		return true

	return false
