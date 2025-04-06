class_name InventoryComponent
extends Node

var inventory_opened: bool = false

var _ui_item_scene: PackedScene = preload("res://objects/ui/UIItem.tscn")

@onready var inventory_menu: Panel = $InventoryUI
@onready var backpack_layout: Control = $InventoryUI/TestBackpack
@onready var player: PlayerController = get_parent()
@onready var crosshair: ColorRect = player.find_child("Crosshair")


func _ready() -> void:
	_set_inventory_opened(false)
	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			square.item_state_changed.connect(_on_backpack_square_item_state_changed)

	if len(PlayerData.inventory_items) > 0:
		set_inventory(PlayerData.inventory_items)


## Set the inventory to an array of values of type <int item id> or <false>.
## Every inventory slot should be in the array in ascending order.
## Elements of type <int item id> are put into the slot in that position,
## and elements of type false will be an empty inventory square.
func set_inventory(item_array: Array) -> void:
	# Remove all items from inventory
	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			for ui_item: UIItem in square.get_children():
				ui_item.get_parent().remove_child(ui_item)

	# Fill inventory with items in array
	for grid: Node in backpack_layout.get_children():
		var backpack_squares: Array = grid.get_children()
		for i: int in len(backpack_squares):
			var backpack_square: BackpackSquare = backpack_squares[i]
			if item_array[i] is int:
				var item_id: int = item_array[i]
				if item_id > 0:
					var item: Item = CreateItem.create_item(item_id)
					var ui_item: UIItem = _ui_item_scene.instantiate()
					ui_item.set_item(item)
					backpack_square.add_child(ui_item)


func add_to_inventory(item: Item) -> void:
	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			if len(square.get_children()) == 0:
				var ui_item: UIItem = _ui_item_scene.instantiate()
				ui_item.set_item(item.duplicate() as Item)
				square.add_child(ui_item)
				item.queue_free()
				return


## Returns all the UIItem nodes in the InventoryComponent
func get_inventory_items() -> Array:
	var inventory_items: Array = []

	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			if len(square.get_children()) > 0:
				var ui_item: UIItem = square.get_children()[0]
				inventory_items.append(ui_item.get_item().duplicate())
			else:
				inventory_items.append(false)

	return inventory_items


func get_inventory_ids() -> Array:
	var item_array: Array = get_inventory_items()

	# Turn items into id representations so they can be stored in the filesystem
	for i: int in len(item_array):
		if item_array[i] is Item:
			var item: Item = item_array[i]
			item_array[i] = item.id

	return item_array


func _on_backpack_square_item_state_changed(item: UIItem) -> void:
	print(item)


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
