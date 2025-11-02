extends Area2D

@export var duration: float = 6.0
@export var bluey_duration: float = 4.0
@export var bluey_damage_per_second: float = 2.0

var _time_alive: float = 0.0

func _ready() -> void:
	rotation = randf_range(0, 2 * PI)

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	monitoring = true
	monitorable = true
	set_process(true)

func _process(delta: float) -> void:
	_time_alive += delta
	if _time_alive >= duration:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("apply_status_effect"):
		body.apply_status_effect("Bluey", bluey_duration, bluey_damage_per_second)
