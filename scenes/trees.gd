@tool
extends Area2D

func _ready():
	if Engine.is_editor_hint():
		randomize()
		_randomize_colors_recursive(self)

func _randomize_colors_recursive(node: Node):
	for child in node.get_children():
		if child is Sprite2D:
			var hue_shift = randf_range(-0.1, 0.1)
			var sat_shift = randf_range(0.9, 1.1)
			var val_shift = randf_range(0.9, 1.1)

			var base = child.modulate
			var h = fmod(base.h + hue_shift + 1.0, 1.0)
			var s = clamp(base.s * sat_shift, 0.0, 1.0)
			var v = clamp(base.v * val_shift, 0.0, 1.0)

			child.modulate = Color.from_hsv(h, s, v, base.a)
		elif child.get_child_count() > 0:
			_randomize_colors_recursive(child)
