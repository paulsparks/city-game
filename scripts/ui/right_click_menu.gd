class_name RightClickMenu
extends Control

signal drop_item

const COLOR: Color = Color("#222924")
const HOVER_COLOR: Color = Color("#431517")

var _mouse_pos: Vector2
var _open_menu_pos: Vector2
var _drop_button_hover: bool

@onready var drop_button: ColorRect = $DropButton


func _ready() -> void:
	visible = false


func _highlight_button() -> void:
	if _drop_button_hover:
		drop_button.color = HOVER_COLOR
	else:
		drop_button.color = COLOR


func open() -> void:
	visible = true
	global_position = _mouse_pos
	_open_menu_pos = _mouse_pos


func close() -> void:
	visible = false


func _on_drop_button_mouse_entered() -> void:
	_drop_button_hover = true


func _on_drop_button_mouse_exited() -> void:
	_drop_button_hover = false
