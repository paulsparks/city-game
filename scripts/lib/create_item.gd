class_name CreateItem

const ITEMS_PATH: String = "res://objects/items/%s"

static var item_table: Dictionary = {
	1: "tools/screwdriver.tscn",
	2: "medicine/promethazine.tscn",
	3: "kitchen/foam_cups_24_pack.tscn",
	4: "food/jolly_ranglers.tscn",
	5: "food/sprit.tscn",
}


static func create_item(item_id: int) -> Item:
	var item_string: String = ITEMS_PATH % item_table.get(item_id)
	var item_scene: PackedScene = load(item_string)
	return item_scene.instantiate()
