extends Area2D

signal collected

func _ready():
	connect("body_entered", _on_body_entered)
	_start_despawn_timer()

func _on_body_entered(body):
	if body.name == "Brotat":
		collected.emit()
		queue_free()

func _start_despawn_timer():
	await get_tree().create_timer(10.0).timeout
	if is_inside_tree():
		queue_free()
