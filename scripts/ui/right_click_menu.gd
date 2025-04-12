class_name RightClickMenu
extends Control

signal drop_item

var _item_focused: UIItem = null


func _ready() -> void:
	visible = false


func open(pos: Vector2, ui_item: UIItem) -> void:
	visible = true
	global_position = pos - Vector2(10, 10)
	_item_focused = ui_item


func close() -> void:
	visible = false
	_item_focused = null


func _on_mouse_exited() -> void:
	close()


func _on_drop_button_pressed() -> void:
	drop_item.emit(_item_focused)
	close()
