extends Node2D

@export var speed = 800.0

func _process(delta):
	position.x += speed * delta  # move right
	if position.x > 2000:  # off-screen
		queue_free()
