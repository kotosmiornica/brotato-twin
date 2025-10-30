extends Node2D

@export var speed = 600.0
@export var food_type: String = "ToyKnife"

func _process(delta):
	position.x += speed * delta
	if position.x > 2000:
		queue_free()
