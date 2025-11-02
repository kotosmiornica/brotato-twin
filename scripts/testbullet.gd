extends Area2D

@export var hit_sound: AudioStream
@export var speed: float = 1000.0
@export var damage: int = 10

var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2
var max_range = 700

func _ready() -> void:
	start_position = global_position  
	connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if global_position.distance_to(start_position) >= max_range:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
	
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


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
