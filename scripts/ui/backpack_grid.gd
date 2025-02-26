class_name BackpackGrid
extends GridContainer

@export var height: int = 4
@export var width: int = 4
@export var box_size: int = 50


func _ready() -> void:
	columns = width

	# Wow I'm bad at math but i came up with this and it works.
	# Someone please tell me if this is a dumb roundabout way of doing some simple common math problem.
	size.x = box_size
	size.y = box_size
	var scale_factor: float = 1
	if height > width:
		scale_factor = float(height) / float(width)
		print(scale_factor)
		size.y = size.y * scale_factor
		size = size * width
	elif width > height:
		scale_factor = float(width) / float(height)
		print(scale_factor)
		size.x = size.x * scale_factor
		size = size * height
	elif width == height:
		size = size * height

	print(size)

	var squares: int = width * height
	for _i: int in range(squares):
		var color_rect: ColorRect = ColorRect.new()
		color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		color_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(color_rect)
