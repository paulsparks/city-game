class_name PlayerDataResource
extends Resource

var inventory_items: Array
var money: float


func _init(p_inventory_items: Array = [], p_money: float = 0) -> void:
	inventory_items = p_inventory_items
	money = p_money
