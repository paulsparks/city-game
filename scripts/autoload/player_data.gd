extends Node

const RESOURCE_PATH: String = "user://player_data.res"

var money: float
var inventory_items: Array


func _init() -> void:
	if not ResourceLoader.exists(RESOURCE_PATH):
		ResourceSaver.save(PlayerDataResource.new(), RESOURCE_PATH)

	var player_data: PlayerDataResource = ResourceLoader.load(RESOURCE_PATH)

	inventory_items = player_data.inventory_items
	money = player_data.money


func save() -> void:
	var player_data: PlayerDataResource = PlayerDataResource.new(inventory_items, money)

	# WARNING: Never let another player manipulate this save file in a custom way. Deserializing this can lead to RCE.
	ResourceSaver.save(player_data, RESOURCE_PATH)
