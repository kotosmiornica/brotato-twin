extends CharacterBody2D

var bullet_scene = preload("res://testbullet.tscn")

func _physics_process(delta: float) -> void:
	# Make gun face the mouse
	look_at(get_global_mouse_position())

	# Fire when mouse button is clicked
	if Input.is_action_just_pressed("shoot"):
		fire()

func fire() -> void:
	var bullet = bullet_scene.instantiate()

	# Spawn bullet from your muzzle (rename Node2D to whatever your muzzle node is)
	bullet.global_position = $pivot.global_position

	# Make bullet face same way as gun
	bullet.rotation = rotation

	# Give bullet a direction vector based on gun rotation
	bullet.direction = Vector2.RIGHT.rotated(rotation)

	# Add bullet to main scene (not as gun child)
	get_tree().get_current_scene().add_child(bullet)
