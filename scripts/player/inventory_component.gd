extends Node
class_name InventoryComponent


const MAX_BAGS: int = 1

var _bags: Array = []
var equipped: Variant = null

@export var bag_label: Label


func _ready():
	_bags = PlayerData.bags
	if len(_bags) > 0:
		equip(_bags[0])


func get_bags() -> Array:
	return _bags


func _process(_delta):
	bag_label.text = str(equipped)


## Delete bag prop and add it to the inventory.
## Returns true or false depending on if this was successful (enough room in bag).
func add_to_inventory(bag: Bag) -> bool:
	if len(_bags) == MAX_BAGS:
		return false
	
	_bags.append(bag)
	bag.get_parent().remove_child(bag)
	
	equip(_bags[0])
	return true


func equip(item: Variant):
	equipped = item


func place_bag(pos: Vector3, source: Node3D):
	if equipped is not Bag:
		return
	
	remove_equipped_bag_from_inventory()
	source.get_parent().add_child(equipped)
	equipped.global_position = pos
	equipped = null


func remove_equipped_bag_from_inventory():
	_bags.remove_at(_bags.find(equipped))


func place_next_bag_item(pos: Vector3, source: Node3D):
	if equipped is not Bag:
		return
		
	var item = equipped.items.pop_front()
	source.get_parent().add_child(item)
	item.global_position = pos
	
	if equipped is GroceryBag and len(equipped.items) == 0:
		remove_equipped_bag_from_inventory()
		equipped.queue_free()
		equipped = null
