extends Area2D

var player: Node = null
var unlocked: bool = false

@export var shooting_point: Node2D
@onready var timer: Timer = $Timer

const BULLET = preload("res://scenes/bullet.tscn")

var shoot_sound_randomizer: AudioStreamRandomizer

func _ready():
	if Global.extra_gun_unlocked != true:
		return
	shoot_sound_randomizer = AudioStreamRandomizer.new()
	shoot_sound_randomizer.add_stream(0, load("res://SOUNDS/sounds/simpleshot.mp3"))
	shoot_sound_randomizer.add_stream(1, load("res://SOUNDS/sounds/simpleshot2.mp3"))
	shoot_sound_randomizer.add_stream(2, load("res://SOUNDS/sounds/simpleshot3.mp3"))
	shoot_sound_randomizer.random_pitch = 0.15
	shoot_sound_randomizer.random_volume_offset_db = 1.0

func _physics_process(_delta: float) -> void:
	if not unlocked:
		return
	var enemies_in_range = get_overlapping_bodies()

	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

		if not timer.is_stopped():
			return
		timer.start()
	else:
		timer.stop()

func shoot() -> void:
	if Global.extra_gun_unlocked != true:
		return
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.global_rotation = shooting_point.global_rotation
	get_tree().current_scene.add_child(new_bullet)
	_play_detached_sound(shoot_sound_randomizer, global_position)

func _on_timer_timeout() -> void:
	shoot()

func _play_detached_sound(sound_stream: AudioStream, sound_position: Vector2):
	if Global.extra_gun_unlocked != true:
		return
	var sound = AudioStreamPlayer2D.new()
	sound.stream = sound_stream
	sound.global_position = sound_position
	get_tree().current_scene.add_child(sound)
	sound.play()

	var duration = sound.stream.get_length()
	if duration <= 0.0:
		duration = 2.0

	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(Callable(sound, "queue_free"))
	sound.add_child(timer)
	timer.start()
