extends Area2D

@export var duration: float = 5.0
@export var damage_per_second: float = 2

var _time_alive: float = 0.0
var enemies_in_stain := []

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

	for enemy in enemies_in_stain:
		if enemy and enemy.has_method("take_damage"):
			enemy.take_damage(damage_per_second * delta)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		enemies_in_stain.append(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("enemies"):
		enemies_in_stain.erase(body)
