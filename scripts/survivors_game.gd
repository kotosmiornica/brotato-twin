extends Node2D

@export var base_enemy_count: int = 10
@export var kills_for_medkit: int = 20
@export var wave_duration: float = 20.0

@onready var wave_timer: Timer = $WaveTimer
@onready var timer_label: Label = $WaveTimerLabel
@onready var points_label: Label = $PointsLabel
@onready var upgrade_menu_scene = preload("res://scenes/UpgradeMenu.tscn")

const MobScene = preload("res://scenes/mob.tscn")
const BossScene = preload("res://scenes/Boss1.tscn")

var upgrade_menu: Control
var player_points: int = 0
var boss_alive: bool = false
var current_wave: int = 0
var alive_enemies: int = 0
var kill_count: int = 0

func _ready() -> void:
	upgrade_menu = upgrade_menu_scene.instantiate()
	add_child(upgrade_menu)
	upgrade_menu.hide()
	upgrade_menu.connect("upgrade_selected", Callable(self, "_on_upgrade_selected"))
	get_tree().paused = false
	start_next_wave()

func _process(delta: float) -> void:
	if wave_timer.is_stopped() == false:
		timer_label.text = "Time Left: %.1f" % wave_timer.time_left
	else:
		timer_label.text = ""
	points_label.text = "Points: %d" % player_points

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

func start_next_wave() -> void:
	current_wave += 1
	kill_count = 0
	alive_enemies = 0

	if current_wave % 5 == 0:
		print("Wave %d: Boss incoming!" % current_wave)
		_spawn_boss()
	else:
		var enemy_count = int(round(base_enemy_count * pow(1.2, current_wave - 1)))
		print("Wave %d: Spawning %d enemies" % [current_wave, enemy_count])
		await _spawn_wave(enemy_count)
	wave_timer.wait_time = wave_duration
	wave_timer.start()


func _spawn_boss() -> void:
	var boss = BossScene.instantiate()
	boss.global_position = Vector2(600, 300)
	add_child(boss)
	alive_enemies += 1
	boss_alive = true

	if $Music.playing:
		$Music.stop()
	$BossMusic.play()

	boss.connect("died", Callable(self, "_on_boss_died"))


func _spawn_wave(enemy_count: int):
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
	player_points += 1
	
	if kill_count % kills_for_medkit == 0:
		spawn_medkit(mob.global_position)
	if $BossMusic.playing:
		$BossMusic.stop()
		$Music.play()

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


func _on_WaveTimer_timeout() -> void:
	print("Wave ended! Enemies killer: %d" % kill_count)
	show_upgrade_menu()


func show_upgrade_menu() -> void:
	get_tree().paused = true
	upgrade_menu.show()


func _on_upgrade_selected(upgrade_name: String) -> void:
	match upgrade_name:
		"health":
			$Brotat.max_health += 20
			player_points -= 5
		"damage":
			$Brotat.damage += 4
			player_points -= 8
		"movement speed":
			$Brotat.speed += 50
			player_points -= 5
	upgrade_menu.hide()
	get_tree().paused = false
	start_next_wave()
