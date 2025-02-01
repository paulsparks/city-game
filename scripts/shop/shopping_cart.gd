extends AnimatableBody3D
class_name ShoppingCart


var item_locations: Array
var groceries: Array
var holding_cart: bool = false

@onready var item_locations_parent: Node3D = $ItemLocations


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item_location: Node3D in item_locations_parent.get_children():
		item_locations.append(item_location)


func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if not holding_cart and body is Grocery:
		groceries.append(body)
		_update_locations()


func _on_area_3d_body_shape_exited(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if not holding_cart and body is Grocery:
		groceries.remove_at(groceries.find(body))
		_update_locations()


func _update_locations() -> void:
	for i in len(groceries):
		# HACK: using a magic number 0.1 for now
		groceries[i].global_position = Vector3(item_locations[i].global_position.x, item_locations[i].global_position.y + 0.1, item_locations[i].global_position.z)
