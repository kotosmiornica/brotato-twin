extends Area2D

var player: Node = null

var bullet_scene = preload("res://scenes/testbullet.tscn")
@export var shoot_sound: AudioStream

func _physics_process(_delta: float) -> void:

	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"):
		fire()

func fire():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = %pivot.global_position
	bullet.rotation = rotation
	bullet.direction = Vector2.RIGHT.rotated(rotation)
	get_tree().get_current_scene().add_child(bullet)
	$Bang.play()
