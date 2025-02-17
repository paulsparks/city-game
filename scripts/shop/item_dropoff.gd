class_name ItemDropoff
extends Node3D

var item_locations: PackedVector3Array
var items: Array

@onready var item_locations_parent: Node3D = $ItemLocations
@onready var expel_location: Vector3 = ($ExpelLocation as Node3D).global_position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item_location: Node3D in item_locations_parent.get_children():
		item_locations.append(item_location.global_position)


func _on_area_3d_body_shape_entered(
	_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int
) -> void:
	if body.find_child("GroceryComponent"):
		if len(items) == len(item_locations):
			body.global_position = expel_location
			return

		items.append(body)
		_update_locations()


func _on_area_3d_body_shape_exited(
	_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int
) -> void:
	if items.find(body) != -1:
		items.remove_at(items.find(body))

		_update_locations()


func _update_locations() -> void:
	for i: int in len(items):
		# HACK: using a magic number 0.2 for now
		items[i].global_position = Vector3(
			item_locations[i].x, item_locations[i].y + 0.2, item_locations[i].z
		)
