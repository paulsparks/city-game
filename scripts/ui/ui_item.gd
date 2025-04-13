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


func _update_texture() -> void:
	var texture_path: String = CreateItem.ITEM_TEXTURES_PATH % _item.id
	texture = load(texture_path)


func _get_drag_data(_at_position: Vector2) -> Variant:
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
	if event.is_action_pressed("use_special"):
		_item_tooltip.visible = false

	if event.is_action_released("use"):
		visible = true

	if !_hover:
		return

	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event

		_item_tooltip.visible = true
		_item_tooltip.draw_mouse_tooltip(_item, mouse_motion)


func _init(item: Item = Screwdriver.new()) -> void:
	_item = item
	_update_texture()


func get_item() -> Item:
	return _item


func set_item(item: Item) -> void:
	_item = item
	_update_texture()


func _on_gui_input(event: InputEvent) -> void:
	if not PlayerUi.inventory_opened or event is not InputEventMouseButton:
		return

	var mouse_event: InputEventMouseButton = event

	if event.is_action_pressed("use_special"):
		PlayerUi.right_click_menu.open(mouse_event.global_position, self)
