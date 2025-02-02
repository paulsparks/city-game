extends Trigger
class_name ShopBuyTrigger


@export var player: PlayerController
@export var item_dropoff: ItemDropoff


func perform_task():
	if (len(item_dropoff.groceries) == 0) or (not player.wallet):
		return false
	
	var combined_price: float = 0
	for grocery in item_dropoff.groceries:
		combined_price += grocery.cost
	
	if not player.wallet.can_afford(combined_price):
		return false
	
	for grocery in item_dropoff.groceries:
		grocery.queue_free()
	return player.wallet.spend_money(combined_price)
