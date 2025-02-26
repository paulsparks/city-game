class_name InventoryComponent
extends Node

var inventory_opened: bool = false

@onready var inventory_menu: Control = $InventoryUI
@onready var backpack_layout: Control = $InventoryUI/BackpackGrids
@onready var player: PlayerController = get_parent()
@onready var crosshair: ColorRect = player.find_child("Crosshair")


func _ready() -> void:
	_set_inventory_opened(false)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_toggle_inventory()


func _toggle_inventory() -> void:
	_set_inventory_opened(!inventory_opened)


func _set_inventory_opened(opened: bool) -> void:
	inventory_opened = opened

	if inventory_opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inventory_menu.show()
		crosshair.hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		inventory_menu.hide()
		crosshair.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
