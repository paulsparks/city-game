extends Trigger
class_name ShopBuyTrigger


@export var player: PlayerController
@export var item_dropoff: ItemDropoff
@export var bag_location: Node3D


func perform_task():
	if (len(item_dropoff.groceries) == 0) or (not player.wallet):
		return false
	
	var combined_price: float = 0
	for grocery in item_dropoff.groceries:
		combined_price += grocery.cost
	
	if not player.wallet.can_afford(combined_price):
		return false
	
	var grocery_bag = load("res://custom/grocery_bag.tscn").instantiate()
	
	# These two for loops need to be separated
	for grocery in item_dropoff.groceries:
		grocery_bag.items.append(grocery)
	
	for i in range(len(item_dropoff.groceries)):
		item_dropoff.groceries.front().get_parent().remove_child(item_dropoff.groceries.front())
	
	player.get_parent().add_child(grocery_bag)
	grocery_bag.global_position = bag_location.global_position
	
	return player.wallet.spend_money(combined_price)
