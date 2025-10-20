extends Area2D

@export var hit_sound: AudioStream
var travelled_distance := 0.0
const SPEED := 1800.0
const RANGE := 1100.0

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta

	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body and body.has_method("take_damage"):
		# Apply damage with global buff multiplier support
		var base_damage := 2
		var dmg_multiplier := Global.get_buff_multiplier("damage")
		body.take_damage(base_damage * dmg_multiplier)

	if hit_sound:
		_play_detached_sound(hit_sound, global_position)

	queue_free()

func _play_detached_sound(sound_stream: AudioStream, sound_position: Vector2) -> void:
	var sound := AudioStreamPlayer2D.new()
	sound.stream = sound_stream
	sound.global_position = sound_position
	get_tree().current_scene.add_child(sound)
	sound.play()
	sound.connect("finished", Callable(sound, "queue_free"))
