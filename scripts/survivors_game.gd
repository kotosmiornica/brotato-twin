extends Node2D

@export var base_enemy_count: int = 10
@export var kills_for_medkit: int = 20

const MobScene = preload("res://scenes/mob.tscn")
const BossScene = preload("res://scenes/Boss1.tscn")

var FT_Script = preload("res://scripts/FightingText.gd")

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

func start_next_wave() -> void:
	current_wave += 1

	if current_wave % 5 == 0:
		_spawn_boss()
	else:
		var enemy_count = int(round(base_enemy_count * pow(1.2, current_wave - 1)))
		await _spawn_wave(enemy_count)

func _spawn_boss() -> void:
	var boss = BossScene.instantiate()
	boss.global_position = Vector2(600, 300)
	add_child(boss)
	alive_enemies += 1
	boss.connect("died", Callable(self, "_on_enemy_died").bind(boss))

func _spawn_wave(enemy_count: int):
	var half = enemy_count / 2

	for i in range(half):
		_spawn_mob(%PathFollow2D)

	for i in range(half):
		_spawn_mob(%PathFollow2DSecond)

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

func _show_floating_text(text: String, pos: Vector2, type: int = 0):
	var popup = FT_Script.new()
	popup.show_text(text, pos, type)
	get_tree().current_scene.add_child(popup)
