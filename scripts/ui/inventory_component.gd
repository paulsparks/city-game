class_name InventoryComponent
extends Control

var opened: bool = false

var _ui_item_scene: PackedScene = preload("res://objects/ui/UIItem.tscn")

@onready
var backpack_layout: Control = $Background/MarginContainer/Inventory/StorageSection/AspectRatioContainer/HBoxContainer


func _ready() -> void:
	visible = false

	PlayerUi.right_click_menu.connect("drop_item", _drop_item)

	print(PlayerData.inventory_items)
	if len(PlayerData.inventory_items) > 0:
		set_inventory(PlayerData.inventory_items)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is not UIItem:
		return

	var ui_item: UIItem = data

	PlayerUi.right_click_menu.drop_item.emit(ui_item)


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true


## Returns { "grid": "grid_name", "coords": (x, y) } or null if the item is not found
func get_grid_location(node: Node) -> Variant:
	for grid: GridContainer in backpack_layout.get_children():
		for col: int in range(len(get_backpacks()[grid.name])):
			for row: int in range(len(get_backpacks()[grid.name][col])):
				var square: BackpackSquare = get_backpacks()[grid.name][col][row]
				var location: Dictionary = {"grid": grid.name, "coords": Vector2(col, row)}

				if node is UIItem:
					if square.get_item() == node:
						return location
				if node is BackpackSquare:
					if square == node:
						return location

	return null


func get_backpacks() -> Dictionary:
	var backpacks: Dictionary

	for grid: GridContainer in backpack_layout.get_children():
		var squares_2d: Array = []

		var squares: Array = grid.get_children()

		var columns: int = grid.columns
		@warning_ignore("integer_division")
		var rows: int = len(squares) / columns

		var starting_index: int = 0

		# Populates a 2D array, with the first level of the array representing the column number,
		# and the second level of the array representing the row number.
		# The value being held in each grid slot is the BackpackSquare in that location.
		for col: int in range(columns):
			var increment: int = columns
			var i: int = starting_index

			squares_2d.append([])
			for row: int in range(rows):
				@warning_ignore("unsafe_method_access")
				squares_2d[col].append(squares[i])
				i += increment

			starting_index += 1

		backpacks[grid.name] = squares_2d

	return backpacks


func _drop_item(ui_item: UIItem) -> void:
	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			for node: Node in square.get_children():
				if node == ui_item:
					var item: Item = ui_item.get_item()
					item.global_position = PlayerData.player.hand_ray.hold_pos
					PlayerData.player.get_parent().add_child(item)
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
				backpack_square.occupied = true

				# var data: Dictionary = get_grid_location(backpack_square)
				# var grid_name: String = data["grid"]
				# var location: Vector2 = data["coords"]

				# print(item.name + ": ")
				# print("w: " + str(ui_item.grid_w))
				# print("h: " + str(ui_item.grid_h))

				# var adjacent_squares: Array = []

				# var grid_table: Array = get_backpacks()[grid_name]
				# var corner_coord: Vector2 = Vector2(
				# 	location.x + ui_item.grid_w - 1, location.y + ui_item.grid_h - 1
				# )

				# for i: int in range(ui_item.grid_h - 1):
				# 	var next_square_down_from_origin: Vector2 = (
				# 		location - Vector2(0, location.y + i + 1)
				# 	)
				# 	print(next_square_down_from_origin)
				# 	var next_square_up_from_corner: Vector2 = (
				# 		location + Vector2(0, corner_coord.y + i + 1)
				# 	)
				# 	print(next_square_up_from_corner)
				# print(
				# 	get_backpacks()[location["grid"]][location["coords"].x + i][
				# 		location["coords"].y
				# 	]
				# )

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


## Returns all the BackpackSquare nodes in the InventoryComponent
func get_backpack_squares() -> Array:
	var backpack_squares: Array = []

	for grid: Node in backpack_layout.get_children():
		for square: BackpackSquare in grid.get_children():
			backpack_squares.append(square)

	return backpack_squares


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
	_set_inventory_opened(!opened)
	PlayerUi.right_click_menu.visible = false


func _set_inventory_opened(p_opened: bool) -> void:
	opened = p_opened

	if opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show()
		# crosshair.hide()
		PlayerUi.item_tooltip.clear_world_tooltip()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()
		# crosshair.show()
