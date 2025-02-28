class_name BackpackSquare
extends Control


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var ui_item: UIItem = data
	ui_item.get_parent().remove_child(ui_item)
	add_child(ui_item)
	# ui_item.set_anchors_preset(PRESET_CENTER)


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
