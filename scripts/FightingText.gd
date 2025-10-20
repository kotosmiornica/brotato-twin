extends Label

@export var rise_distance: float = 50
@export var duration: float = 0.5
@export var font_file: FontFile

func show_text(text_to_show: String, start_position: Vector2, color: Color = Color(1,0,0,1), font_size: int = 90):
	text = text_to_show
	position = start_position
	modulate = color

	if font_file:
		self.font = font_file
		theme_font_size_override(font_size)

	z_index = 1000
	tween_up()

func theme_font_size_override(font_size_value: int):
	if not theme:
		theme = Theme.new()
	theme.set_font("font", "Label", font_file)
	theme.set_font_size("font_size", "Label", font_size_value)
	self.theme = theme


func tween_up():
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - rise_distance, duration)
	tween.tween_property(self, "modulate:a", 0, duration)
	tween.connect("finished", Callable(self, "queue_free"))
