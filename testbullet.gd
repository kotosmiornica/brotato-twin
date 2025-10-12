extends Area2D

@export var speed: float = 1000.0
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
