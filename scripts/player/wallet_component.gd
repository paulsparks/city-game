class_name WalletComponent
extends Node
## Controls the players wallet

@export var _money_label: Label

var _money: float


func _ready():
	_money = PlayerData.money


func _process(_delta):
	if _money_label:
		_money_label.text = "Money: " + str(_money)


## Spends the specified amount of money from the wallet if you have enough.
## Returns false if you don't have enough money. Returns true if you do, and the money was spent.
func spend_money(amount: float) -> bool:
	if not can_afford(amount):
		return false

	_money -= amount
	return true


## Returns the amount of money currently in the wallet
func get_money() -> float:
	return _money


## Returns a boolean representing whether or not
## the wallet has enough money to afford the specified cost.
func can_afford(cost: float) -> bool:
	if cost > _money:
		return false
	return true
