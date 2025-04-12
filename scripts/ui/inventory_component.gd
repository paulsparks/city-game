class_name InventoryComponent
extends Control

var _ui_item_scene: PackedScene = preload("res://objects/ui/UIItem.tscn")

@onready
var backpack_layout: Control = $Background/MarginContainer/Inventory/StorageSection/AspectRatioContainer/HBoxContainer
@onready var player: PlayerController = get_parent()
@onready var crosshair: ColorRect = player.find_child("Crosshair")


func _ready() -> void:
	PlayerUi.right_click_menu.connect("drop_item", _drop_item)

	_set_inventory_opened(false)

	if len(PlayerData.inventory_items) > 0:
		set_inventory(PlayerData.inventory_items)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is not UIItem:
		return

	var ui_item: UIItem = data

	PlayerUi.right_click_menu.drop_item.emit(ui_item)


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true


func _drop_item(ui_item: UIItem) -> void:
	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			for node: Node in square.get_children():
				if node == ui_item:
					var item: Item = ui_item.get_item()
					item.global_position = player.hand_ray.hold_pos
					player.get_parent().add_child(item)
					node.queue_free()


## Set the inventory to an array of values of type <String item id> or <false>.
## Every inventory slot should be in the array in ascending order.
## Elements of type <String item id> are put into the slot in that position,
## and elements of type false will be an empty inventory square.
func set_inventory(item_array: Array) -> void:
	# Remove all items from inventory
	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			for node: Node in square.get_children():
				if node is UIItem:
					node.get_parent().remove_child(node)

	var inventory_location: int = 0

	# Fill inventory with items in array
	for grid: Node in backpack_layout.get_children():
		var backpack_squares: Array = grid.get_children()
		for backpack_square: BackpackSquare in backpack_squares:
			if item_array[inventory_location] is String and item_array[inventory_location] != "":
				var item_id: String = item_array[inventory_location]
				var item: Item = CreateItem.create_item(item_id)
				var ui_item: UIItem = _ui_item_scene.instantiate()
				ui_item.set_item(item)
				backpack_square.add_child(ui_item)
			inventory_location += 1


func add_to_inventory(item: Item) -> void:
	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			if not square.has_item():
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
			if square.has_item():
				var ui_item: UIItem = HelperFunctions.find_child_with_func(
					square, func x(child: Node) -> bool: return child is UIItem
				)
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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_toggle_inventory()


func _toggle_inventory() -> void:
	_set_inventory_opened(!PlayerUi.inventory_opened)


func _set_inventory_opened(opened: bool) -> void:
	PlayerUi.inventory_opened = opened

	if PlayerUi.inventory_opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show()
		crosshair.hide()
		PlayerUi.item_tooltip.clear_world_tooltip()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()
		crosshair.show()
