class_name PlayerDataResource
extends Resource

@export var inventory_items: Array
@export var money: float


func _init(p_inventory_items: Array = [], p_money: float = 20) -> void:
	inventory_items = p_inventory_items
	money = p_money
