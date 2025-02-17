class_name ShopBuyTrigger
extends Trigger


@export var player: PlayerController
@export var item_dropoff: ItemDropoff
@export var bag_location: Node3D


func perform_task():
	if (len(item_dropoff.items) == 0) or (not player.wallet):
		return false

	var combined_price: float = 0
	var groceries = item_dropoff.items.map(
		func (item: Item): return item.find_child("GroceryComponent")
	)
	for grocery in groceries:
		combined_price += grocery.cost

	if not player.wallet.can_afford(combined_price):
		return false

	var grocery_bag = load("res://custom/grocery_bag.tscn").instantiate()

	# These two for loops need to be separated
	for item: Item in item_dropoff.items:
		item.remove_child(item.find_child("GroceryComponent"))
		grocery_bag.items.append(item)

	for i in range(len(item_dropoff.items)):
		item_dropoff.items.front().get_parent().remove_child(item_dropoff.items.front())

	player.get_parent().add_child(grocery_bag)
	grocery_bag.global_position = bag_location.global_position

	return player.wallet.spend_money(combined_price)
