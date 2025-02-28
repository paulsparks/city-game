class_name UIItem
extends Control


func _get_drag_data(_at_position: Vector2) -> Variant:
	var item_preview: Control = Control.new()
	item_preview.add_child(self.duplicate())
	item_preview.position = item_preview.size * -0.5

	set_drag_preview(item_preview)
	return self
