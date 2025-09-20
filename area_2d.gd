extends Area2D

signal collected

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Brotat":
		collected.emit()
		queue_free()
