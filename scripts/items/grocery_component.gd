class_name GroceryComponent
extends Node
## Place this under an Item to make it purchasable.

@export var cost: float = 3.99

@onready var item: Item = get_parent()


## Attempt to purchase the grocery item.
## Returns the item node if you have the money. Returns false otherwise.
func buy(wallet: WalletComponent) -> Variant:
	if wallet.spend_money(cost):
		return self

	return false
