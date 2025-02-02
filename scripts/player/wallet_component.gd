extends Node
class_name WalletComponent

var _money: int = 1000

func spend_money(amount: int) -> bool:
	if amount > _money:
		return false
	
	_money -= amount
	return true

func get_money() -> int:
	return _money
