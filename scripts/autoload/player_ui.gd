extends Node

var inventory_opened: bool = false

@onready var ui_canvas: CanvasLayer = CanvasLayer.new()
@onready var item_tooltip: ItemTooltip = preload("res://objects/ui/item_tooltip.tscn").instantiate()
@onready
var right_click_menu: RightClickMenu = preload("res://objects/ui/RightClickMenu.tscn").instantiate()


func _ready() -> void:
	ui_canvas.layer = 1
	add_child(ui_canvas)

	ui_canvas.add_child(item_tooltip)
	ui_canvas.add_child(right_click_menu)
