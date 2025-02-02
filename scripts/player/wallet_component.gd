extends Node
class_name WalletComponent
## Controls the players wallet

var _money: int = 1000

@export var _money_label: Label


func _process(_delta):
	if _money_label:
		_money_label.text = "Money: " + str(_money)


## Spends the specified amount of money from the wallet if you have enough.
## Returns false if you don't have enough money. Returns true if you do, and the money was spent.
func spend_money(amount: int) -> bool:
	if amount > _money:
		return false
	
	_money -= amount
	return true


## Returns the amount of money currently in the wallet
func get_money() -> int:
	return _money
