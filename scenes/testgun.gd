extends CharacterBody2D

var bullet_path = preload("res://testbullet.tscn")

func _physics_process(delta) -> void:
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("ui_accept"):
		fire()
	
func fire():
	var bullet = bullet_path.instantiate()
	bullet.direction = rotation
	bullet.position = $Node2D.global_position
	bullet.rotation = global_position
	get_parent().add_child(bullet)
