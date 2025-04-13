class_name UIItem
extends TextureRect

const SMALLEST_ITEM_SQUARE_PIXELS: int = 70
const IMAGE_INACCURACY: int = 4

var item_name_label: Label
var tooltip_label: Label
var item_price_label: Label
var item_text_background: ColorRect
var grid_w: int = 1
var grid_h: int = 1

var _item: Item = null
var _hover: bool = false

@onready var collision: CollisionObject2D = $UIItemCollision
@onready var collision_shape: CollisionShape2D = $UIItemCollision/CollisionShape2D

@onready var _item_tooltip: ItemTooltip = preload("res://objects/ui/item_tooltip.tscn").instantiate()


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	_set_size_based_on_image_resolution()


func _set_size_based_on_image_resolution() -> void:
	# Given an item's size, the base size for that item, and innacuracy amount, return the scale factor of that item
	var calculate_scale_factor: Callable = func x(
		p_size: int, base_num: int, inaccuracy: int = 0
	) -> int:
		var factor: int
		match p_size:
			var w when w >= ((base_num * 2) - inaccuracy) and w <= ((base_num * 2) + inaccuracy):
				factor = 2
			var w when w >= ((base_num * 3) - inaccuracy) and w <= ((base_num * 3) + inaccuracy):
				factor = 3
			var w when w >= ((base_num * 4) - inaccuracy) and w <= ((base_num * 4) + inaccuracy):
				factor = 4
			_:
				factor = 1
		return factor

	grid_w = calculate_scale_factor.call(texture.get_width(), 32, IMAGE_INACCURACY)
	grid_h = calculate_scale_factor.call(texture.get_height(), 32, IMAGE_INACCURACY)

	var scale_factor: Vector2 = Vector2(grid_w, grid_h)

	size = SMALLEST_ITEM_SQUARE_PIXELS * scale_factor

	var size_correction: Vector2 = Vector2.ZERO
	# I really don't know why I have to do this part but this is the solution I came up with
	if grid_w > 1:
		size_correction += Vector2(grid_w * (grid_w + 1), 0)
	if grid_h > 1:
		size_correction += Vector2(0, grid_h * (grid_h + 1))

	size += size_correction

	var rectangle_shape: RectangleShape2D = collision_shape.shape
	rectangle_shape.size = SMALLEST_ITEM_SQUARE_PIXELS * scale_factor

	if grid_w > 1:
		collision_shape.position.x = rectangle_shape.size.x / grid_w * 0.5
	if grid_h > 1:
		collision_shape.position.y = rectangle_shape.size.y / grid_h * 0.5

	rectangle_shape.size += size_correction
	collision_shape.position += size_correction * 0.5


func _update_texture() -> void:
	var texture_path: String = CreateItem.ITEM_TEXTURES_PATH % _item.id
	texture = load(texture_path)


func _get_drag_data(_at_position: Vector2) -> Variant:
	var c: Control = Control.new()

	var ui_item_preview: UIItem = self.duplicate()

	c.add_child(ui_item_preview)
	ui_item_preview.position = -0.5 * ui_item_preview.size

	visible = false

	set_drag_preview(c)
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
