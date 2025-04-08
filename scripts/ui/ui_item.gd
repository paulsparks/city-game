class_name UIItem
extends TextureRect

var item_name_label: Label
var tooltip_label: Label
var item_price_label: Label
var item_text_background: ColorRect

var _item: Item = null
var _hover: bool = false

@onready var _item_tooltip: ItemTooltip = preload("res://objects/ui/item_tooltip.tscn").instantiate()


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	call_deferred("_post_ready")


func _update_texture() -> void:
	var atlas_texture: AtlasTexture = texture
	atlas_texture.region.position.x = CreateItem.texture_map[_item.id].x
	atlas_texture.region.position.y = CreateItem.texture_map[_item.id].y


func _post_ready() -> void:
	pass
	# player.right_click_menu.drop_item.connect(_drop_item)


func _drop_item() -> void:
	pass
	# player.drop_in_front(_item)
	# queue_free()


func _get_drag_data(_at_position: Vector2) -> Variant:
	remove_child(_item_tooltip)
	var item_preview: Control = Control.new()
	item_preview.add_child(self.duplicate())
	item_preview.position = item_preview.size * -0.5

	visible = false

	set_drag_preview(item_preview)
	return self


func _on_mouse_entered() -> void:
	_hover = true
	PlayerUi.ui_canvas.add_child(_item_tooltip)
	_item_tooltip.visible = false


func _on_mouse_exited() -> void:
	_hover = false
	PlayerUi.ui_canvas.remove_child(_item_tooltip)


func _input(event: InputEvent) -> void:
	if event.is_action_released("use"):
		visible = true

	if !_hover:
		return

	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event

		_item_tooltip.visible = true
		_item_tooltip._draw_mouse_tooltip(_item, mouse_motion)


func _init(item: Item = Screwdriver.new()) -> void:
	_item = item
	_update_texture()


func get_item() -> Item:
	return _item


func set_item(item: Item) -> void:
	_item = item
	_update_texture()
