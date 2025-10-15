extends Area2D

@export var heal_amount: int = 35

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.heal(heal_amount)
			queue_free()
		
		
