extends Node2D

@export var base_enemy_count: int = 10
@export var kills_for_medkit: int = 20
@export var wave_duration: float = 20.0
@onready var score_label: Label = $Bar/XPbar/PointsLabel
@onready var timer_label: Label = $Brotat/TimerLabel
@onready var boss_warning_label: Label = $Bar/XPbar/BossWarningLabel
@onready var boss_warning_anim: AnimationPlayer = $BossWarningAnimation

const MobScene = preload("res://scenes/mob.tscn")
const BossScene = preload("res://scenes/Boss1.tscn")

var wave_time_left: float = 0.0
var wave_active: bool = false
var boss_alive: bool = false
var boss_count = 0
var current_wave: int = 0
var alive_enemies: int = 0
var kill_count: int = 0
var player_score:int = kill_count * 50
var wave_locked: bool = false

func _ready() -> void:
	get_tree().paused = false
	start_next_wave()



func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart") and !$Fade/ColorRect/AnimationPlayer.is_playing():
		$Fade/ColorRect/AnimationPlayer.play("fade_in")
		get_tree().paused = false

	if not get_tree().paused and alive_enemies == 0 and boss_alive == false and wave_locked == false:
		start_next_wave()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().reload_current_scene()

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

func start_next_wave() -> void:
	current_wave += 1
	Global.waves_survived = current_wave - 1

	wave_time_left = wave_duration
	wave_active = true

	if current_wave % 5 == 0:
		_spawn_boss()
	else:
		if boss_alive:
			return
		var enemy_count = int(round(base_enemy_count * pow(1.2, current_wave - 1)))
		await _spawn_wave(enemy_count)

func _spawn_boss() -> void:
	boss_warning_label.visible = true
	boss_warning_anim.play("boss_warning")
	
	await get_tree().create_timer(2.0).timeout
	
	var boss = BossScene.instantiate()
	boss.global_position = Vector2(600, 300)
	add_child(boss)
	boss_count += 1
	boss_alive = true

	if $Music.playing:
		$Music.stop()
	$BossMusic.play()

	boss.connect("died", Callable(self, "_on_boss_died"))

func _spawn_wave(enemy_count: int):
	if boss_alive != false:
		return
	var half = enemy_count / 2

	for i in range(half):
		_spawn_mob($Brotat/Path2D/PathFollow2D)

	for i in range(half):
		_spawn_mob($Brotat/Path2DSecond/PathFollor2DSecond)

	if enemy_count % 2 != 0:
		_spawn_mob($Brotat/Path2DSecond/PathFollor2DSecond)
		
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
	Global.score = kill_count
	update_score_display()

	if kill_count % kills_for_medkit == 0:
		spawn_medkit(mob.global_position)
	if $BossMusic.playing:
		$BossMusic.stop()
		$Music.play()

func update_score_display():
	player_score = kill_count * 50
	score_label.text = "Score: %d" % player_score

func spawn_medkit(pos: Vector2):
	var medkit = preload("res://scenes/MedKit.tscn").instantiate()
	medkit.global_position = pos
	call_deferred("add_child", medkit)
	
func _on_boss_died():
	alive_enemies -= 1
	boss_alive = false

	if $BossMusic.playing:
		$BossMusic.stop()
	$Music.play()


func _show_upgrade_menu():
	if Global.waves_survived == 1:
		$UpgradeMenu.visible = true
		get_tree().paused = true
