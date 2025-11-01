extends Area2D

@export var speed: float = 1000.0
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2
var max_range = 700

func _ready() -> void:
	start_position = global_position  
	connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if global_position.distance_to(start_position) >= max_range:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
