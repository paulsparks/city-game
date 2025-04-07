class_name RightClickMenu
extends Control

signal drop_item

var _mouse_pos: Vector2
var _open_menu_pos: Vector2
var _drop_button_hover: bool

@onready var drop_button: ColorRect = $DropButton


func _ready() -> void:
	visible = false
	drop_button.mouse_entered.connect(func x() -> void: _drop_button_hover = true)
	drop_button.mouse_exited.connect(func x() -> void: _drop_button_hover = false)


func _highlight_button() -> void:
	if _drop_button_hover:
		drop_button.color = Color.RED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_highlight_button()

		if _mouse_pos.distance_to(_open_menu_pos) > 110:
			close()

		var mouse_motion: InputEventMouseMotion = event
		_mouse_pos = mouse_motion.global_position
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if _drop_button_hover:
				drop_item.emit()
			close()


func open() -> void:
	visible = true
	position = _mouse_pos
	_open_menu_pos = _mouse_pos


func close() -> void:
	visible = false
