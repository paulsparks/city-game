class_name CreateItem

const ITEMS_PATH: String = "res://objects/items/%s"
const ITEM_TEXTURES_PATH: String = "res://assets/ui/items/%s.png"

static var item_table: Dictionary = {
	"screwdriver": "tools/screwdriver.tscn",
	"promethazine": "medicine/promethazine.tscn",
	"foam_cups_24_pack": "kitchen/foam_cups_24_pack.tscn",
	"jolly_ranglers": "food/jolly_ranglers.tscn",
	"sprit": "food/sprit.tscn",
}


static func create_item(item_id: String) -> Item:
	var item_string: String = ITEMS_PATH % item_table.get(item_id)
	var item_scene: PackedScene = load(item_string)
	return item_scene.instantiate()
