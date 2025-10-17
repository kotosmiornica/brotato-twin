extends Area2D

@export var speed: float = 1200.0
@export var food_type: String = "BlackMonster"

func _ready():
	add_to_group("food")

func _process(delta):
	position.x += speed * delta
	if position.x > 2000:
		queue_free()
