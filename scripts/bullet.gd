extends Area2D

var travelled_distance = 0
@export var hit_sound: AudioStream

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1)

	if hit_sound:
		_play_detached_sound(hit_sound, global_position)

	queue_free()


func _play_detached_sound(sound_stream: AudioStream, sound_position: Vector2):
	var sound = AudioStreamPlayer2D.new()
	sound.stream = sound_stream
	sound.global_position = sound_position
	get_tree().current_scene.add_child(sound)
	sound.play()
	sound.connect("finished", Callable(sound, "queue_free"))
	
func _physics_process(delta):
	const SPEED = 1800
	const RANGE = 1100
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()
