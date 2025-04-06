extends Node

const RESOURCE_PATH: String = "user://player_data.res"

var money: float
var inventory_items: Array

var _timer: Timer


func _init() -> void:
	_timer = Timer.new()
	add_child(_timer)

	if not ResourceLoader.exists(RESOURCE_PATH):
		_reset_save_data()

	var player_data: PlayerDataResource = ResourceLoader.load(RESOURCE_PATH)

	inventory_items = player_data.inventory_items
	money = player_data.money


func save() -> void:
	var player_data: PlayerDataResource = PlayerDataResource.new(inventory_items, money)

	# WARNING: Never let another player manipulate this save file in a custom way. Deserializing this can lead to RCE.
	ResourceSaver.save(player_data, RESOURCE_PATH)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_save_data"):
		_reset_save_data()


func _reset_save_data() -> void:
	var new_resource: PlayerDataResource = PlayerDataResource.new()
	ResourceSaver.save(new_resource, RESOURCE_PATH)

	money = new_resource.money
	inventory_items = new_resource.inventory_items

	get_tree().call_deferred("change_scene_to_file", "res://maps/house.tscn")

	var reset_label: Label = Label.new()
	reset_label.text = "Save data has been reset!"
	reset_label.set_anchors_preset(Label.PRESET_CENTER)

	add_child(reset_label)
	_timer.connect("timeout", func x() -> void: remove_child(reset_label))
	_timer.start()
