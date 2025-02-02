extends StaticBody3D
class_name ItemDropoff


var item_locations: PackedVector3Array
var groceries: Array

@onready var item_locations_parent: Node3D = $ItemLocations
@onready var expel_location: Vector3 = $ExpelLocation.global_position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item_location: Node3D in item_locations_parent.get_children():
		item_locations.append(item_location.global_position)


func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is Grocery:
		
		if len(groceries) == len(item_locations):
			body.global_position = expel_location
			return
		
		groceries.append(body)
		_update_locations()


func _on_area_3d_body_shape_exited(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if groceries.find(body) != -1:
		groceries.remove_at(groceries.find(body))

		_update_locations()


func _update_locations() -> void:
	for i in len(groceries):
		# HACK: using a magic number 0.1 for now
		groceries[i].global_position = Vector3(item_locations[i].x, item_locations[i].y + 0.2, item_locations[i].z)
