class_name ItemTooltip
extends Control

@onready var item_name_label: Label = $ItemName
@onready var tooltip_label: Label = $Tooltip
@onready var item_price_label: Label = $ItemPrice
@onready var item_text_background: ColorRect = $ItemTextBackground


func draw_world_tooltip(object: Variant, is_holding_prop: bool) -> void:
	if object is Bag:
		var bag: Bag = object
		item_name_label.text = bag.name.capitalize()
		tooltip_label.text = ""
		item_price_label.text = ""
		return

	if object is not Item or is_holding_prop:
		item_name_label.text = ""
		tooltip_label.text = ""
		item_price_label.text = ""
		return

	var item: Item = object

	tooltip_label.text = item.tooltip
	item_name_label.text = item.display_name

	_draw_grocery_value(item)


func clear_world_tooltip() -> void:
	item_name_label.text = ""
	tooltip_label.text = ""
	item_price_label.text = ""


func draw_mouse_tooltip(item: Item, location: InputEventMouse) -> void:
	item_name_label.text = item.display_name
	item_name_label.label_settings.font_color.a = 1.0
	item_name_label.global_position = location.global_position + Vector2(28, 0)

	tooltip_label.text = item.tooltip
	tooltip_label.label_settings.font_color.a = 0.7
	tooltip_label.global_position = location.global_position + Vector2(28, 24)

	item_text_background.visible = true
	item_text_background.global_position = location.global_position + Vector2(20, -26)
	item_text_background.size.x = max(item_name_label.size.x, tooltip_label.size.x) + 8
	item_text_background.size.y = (
		item_name_label.size.y
		+ (tooltip_label.size.y if tooltip_label.text != "" else 0.0)
		+ item_price_label.size.y
		+ 12
	)

	_draw_grocery_value(item)

	item_price_label.label_settings.font_color.a = 1.0
	item_price_label.global_position = (location.global_position + Vector2(28, -18))


func _draw_grocery_value(object: Node) -> void:
	var grocery_component: GroceryComponent = HelperFunctions.find_child_with_func(
		object, func(child: Node) -> bool: return child is GroceryComponent
	)
	if grocery_component == null:
		item_price_label.text = "Owned"
	else:
		item_price_label.text = "$" + str(grocery_component.cost)
