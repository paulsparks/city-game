class_name UIItem
extends Control

var item_name_label: Label
var tooltip_label: Label
var item_price_label: Label

var _item: Item = null
var _hover: bool = false
var _labels_instantiated: bool = false

@onready var player: PlayerController = find_parent("Player")


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _get_drag_data(_at_position: Vector2) -> Variant:
	_remove_labels()
	var item_preview: Control = Control.new()
	item_preview.add_child(self.duplicate())
	item_preview.position = item_preview.size * -0.5

	set_drag_preview(item_preview)
	return self


func _on_mouse_entered() -> void:
	if not _labels_instantiated:
		item_name_label = player.item_name_label.duplicate()
		tooltip_label = player.tooltip_label.duplicate()
		item_price_label = player.item_price_label.duplicate()
		_labels_instantiated = true

	_hover = true
	add_child(item_name_label)
	add_child(tooltip_label)
	add_child(item_price_label)


func _on_mouse_exited() -> void:
	_hover = false
	_remove_labels()


func _remove_labels() -> void:
	if item_name_label.get_parent() != null:
		remove_child(item_name_label)
	if tooltip_label.get_parent() != null:
		remove_child(tooltip_label)
	if item_price_label.get_parent() != null:
		remove_child(item_price_label)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event

		if _hover:
			item_name_label.text = _item.display_name
			item_name_label.label_settings.font_color.a = 1.0
			item_name_label.global_position = mouse_motion.global_position + Vector2(28, 0)

			tooltip_label.text = _item.tooltip
			tooltip_label.label_settings.font_color.a = 1.0
			tooltip_label.global_position = mouse_motion.global_position + Vector2(28, 24)

			# TODO: For the love of god please make it so I'm not copy-pasting this
			var grocery_component: GroceryComponent = HelperFunctions.find_child_with_func(
				_item, func(child: Node) -> bool: return child is GroceryComponent
			)
			if grocery_component == null:
				item_price_label.text = "Owned"
			else:
				item_price_label.text = "$" + str(grocery_component.cost)

			item_price_label.label_settings.font_color.a = 1.0
			item_price_label.global_position = (mouse_motion.global_position + Vector2(28, -18))


func _init(item: Item = Screwdriver.new()) -> void:
	_item = item


func get_item() -> Item:
	return _item


func set_item(item: Item) -> void:
	_item = item
