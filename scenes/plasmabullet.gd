extends Area2D


@export var cooldown := 1.0
var travelled_distance = 0

func _physics_process(delta):
	const SPEED = 900
	const RANGE = 1100
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body):
	print(body)
	if body.has_method("take_damage"):
		body.take_damage(4)
	_on_hit()


func _on_hit():
	var stream = preload("res://music/lasershot.wav")
	print("Sound length:", stream.get_length())
	play_detached_sound(stream, global_position)
	queue_free()


func play_detached_sound(sound_stream: AudioStream, _sound_position: Vector2):
	var sound = AudioStreamPlayer2D.new()
	sound.stream = sound_stream
	sound.position = position
	get_tree().current_scene.add_child(sound)

	sound.play()

	var timer = Timer.new()
	timer.wait_time = sound.stream.get_length()
	timer.one_shot = true
	timer.timeout.connect(Callable(sound, "queue_free"))
	sound.add_child(timer)
	timer.start()
