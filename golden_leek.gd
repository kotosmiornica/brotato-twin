extends Node2D

@export var speed = 900.0
@export var food_type: String = "GoldenLeek"  # << add this

func _process(delta):
	position.x += speed * delta  # move right
	if position.x > 2000:  # off-screen
		queue_free()
