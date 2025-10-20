extends Label

@export var rise_distance: float = 30
@export var duration: float = 0.6

func show_text(text_to_show: String, start_position: Vector2):
	text = text_to_show
	position = start_position
	modulate = Color(1, 0, 0, 1) # red for damage
	tween_up()

func tween_up():
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - rise_distance, duration)
	tween.tween_property(self, "modulate:a", 0, duration)
	tween.connect("finished", Callable(self, "queue_free"))
