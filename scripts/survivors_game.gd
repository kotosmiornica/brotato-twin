extends Node2D

@export var base_enemy_count: int = 10
@export var kills_for_medkit: int = 5
const MobScene = preload("res://scenes/mob.tscn")
var current_wave: int = 0
var alive_enemies: int = 0
var kill_count: int = 0

func _ready() -> void:
	get_tree().paused = false
	start_next_wave()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart") and !$Fade/ColorRect/AnimationPlayer.is_playing():
		$Fade/ColorRect/AnimationPlayer.play("fade_in")
		get_tree().paused = false

	if not get_tree().paused and alive_enemies == 0:
		start_next_wave()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().reload_current_scene()

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

# ------------------------
# Wave System
# ------------------------

func start_next_wave():
	current_wave += 1
	var enemy_count = int(round(base_enemy_count * pow(1.2, current_wave - 1)))
	print("Wave %d: Spawning %d enemies" % [current_wave, enemy_count])

	_spawn_wave(enemy_count)


func _spawn_wave(enemy_count: int):
	var half = enemy_count / 2

	# Spawn from PathFollow2D
	for i in range(half):
		_spawn_mob(%PathFollow2D)

	# Spawn from PathFollow2DSecond
	for i in range(half):
		_spawn_mob(%PathFollow2DSecond)

	# If enemy_count is odd, spawn the extra one from PathFollow2DSecond (or alternate each wave if you want)
	if enemy_count % 2 != 0:
		_spawn_mob(%PathFollow2DSecond)


func _spawn_mob(path: PathFollow2D):
	var new_mob = MobScene.instantiate()
	path.progress_ratio = randf()
	new_mob.global_position = path.global_position
	add_child(new_mob)
	alive_enemies += 1
	new_mob.connect("died", Callable(self, "_on_enemy_died").bind(new_mob))
	
func _on_enemy_died(mob: Node):
	alive_enemies -= 1
	kill_count += 1
	
	if kill_count % kills_for_medkit == 0:
		spawn_medkit(mob.global_position)

func spawn_medkit(pos: Vector2):
	var medkit = preload("res://scenes/MedKit.tscn").instantiate()
	medkit.global_position = pos
	call_deferred("add_child", medkit)
