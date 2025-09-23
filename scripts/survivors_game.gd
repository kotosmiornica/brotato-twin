extends Node2D

@export var base_enemy_count: int = 10
var current_wave: int = 0

func _ready() -> void:
	get_tree().paused = false
	start_next_wave()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart") and !$Fade/ColorRect/AnimationPlayer.is_playing():
		$Fade/ColorRect/AnimationPlayer.play("fade_in")
		get_tree().paused = false


	if not get_tree().paused and get_enemy_count() == 0:
		start_next_wave()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().reload_current_scene()

func _on_brotat_health_depleted() -> void:
	%GameOver.visible = true
	get_tree().paused = true

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()


# Wave System


func start_next_wave():
	current_wave += 1
	var enemy_count = base_enemy_count * pow(2, current_wave - 1)
	print("Wave %d: Spawning %d enemies" % [current_wave, enemy_count])
	
	for i in range(enemy_count):
		spawn_mob()

func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size()
