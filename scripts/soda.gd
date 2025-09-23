extends Area2D

@export var damage: float = 20.0
@export var lifetime: float = 3  # how long the soda explosion stays


var player: Node = null  # <-- add this

func _ready():
	# Damage any mobs overlapping immediately
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)

	# Remove explosion after short time
	await get_tree().create_timer(lifetime).timeout
	queue_free()
