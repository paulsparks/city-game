class_name CreateItem

const ITEMS_PATH: String = "res://objects/items/%s"

static var item_table: Dictionary = {
	"screwdriver": "tools/screwdriver.tscn",
	"promethazine": "medicine/promethazine.tscn",
	"foam_cups_24_pack": "kitchen/foam_cups_24_pack.tscn",
	"jolly_ranglers": "food/jolly_ranglers.tscn",
	"sprit": "food/sprit.tscn",
}

static var texture_map: Dictionary = {
	"screwdriver": Vector2(844, 0),
	"promethazine": Vector2(605, 0),
	"foam_cups_24_pack": Vector2(366, 0),
	"jolly_ranglers": Vector2(244, 0),
	"sprit": Vector2(488, 0),
}


static func create_item(item_id: String) -> Item:
	var item_string: String = ITEMS_PATH % item_table.get(item_id)
	var item_scene: PackedScene = load(item_string)
	return item_scene.instantiate()
