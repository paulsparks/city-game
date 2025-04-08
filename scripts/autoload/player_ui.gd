extends Node

@onready var ui_canvas: CanvasLayer = CanvasLayer.new()
@onready var item_tooltip: ItemTooltip = preload("res://objects/ui/item_tooltip.tscn").instantiate()


func _ready() -> void:
	ui_canvas.layer = 1
	add_child(ui_canvas)

	ui_canvas.add_child(item_tooltip)
