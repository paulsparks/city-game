extends Prop
class_name Grocery
## A grocery prop

@export var cost: float = 3.99
@export var item_name: String = "Grocery Item"


## Attempt to purchase the grocery item.
## Returns the item node of type Grocery if you have the money. Returns false otherwise.
func buy(wallet: WalletComponent) -> Variant:
	if wallet.spend_money(cost):
		return self

	return false
