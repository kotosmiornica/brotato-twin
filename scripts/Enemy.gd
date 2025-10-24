extends CharacterBody2D  

signal died

@export var medkit_drop_chance: float = 0.0002 
@export var damage_amount: int = 1
@export var damage_interval: float = 2.0
@onready var player = get_node("/root/game/Brotat")

var player_in_zone: Node = null
var damage_timer: float = 0.0
var health = 3  
var FT_Script = preload("res://scripts/FightingText.gd")

func _ready() -> void:
	%Slime.play_walk()
	add_to_group("enemies")
	if has_node("KillZone"):
		var kill_zone = $KillZone
		kill_zone.connect("body_entered", Callable(self, "_on_KillZone_body_entered"))
		kill_zone.connect("body_exited", Callable(self, "_on_KillZone_body_exited"))

func _physics_process(delta: float) -> void:
	var target = player.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	var direction = (target - global_position).normalized()
	velocity = direction * 300.0
	move_and_slide()

	if player_in_zone:
		damage_timer += delta
		if damage_timer >= damage_interval:
			player.take_damage(damage_amount)
			damage_timer = 0.0

func take_damage(amount: int):
	health -= amount
	%Slime.play_hurt()
	_show_damage_popup(amount)
	if health <= 0:
		drop_xp()
		drop_medkit_random()
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		emit_signal("died")
		queue_free()

func _show_damage_popup(amount: int):
	var popup = FT_Script.new()
	popup.show_text(str(amount), global_position)
	get_tree().current_scene.add_child(popup)

func drop_xp():
	var xp = preload("res://scenes/XPpickups.tscn").instantiate()
	xp.global_position = global_position
	var root = get_tree().current_scene
	root.call_deferred("add_child", xp)
	xp.connect("collected", root.get_node("Brotat")._on_xp_collected)

func drop_medkit_random():
	if randf() < medkit_drop_chance:
		var medkit = preload("res://scenes/MedKit.tscn").instantiate()
		medkit.global_position = global_position
		var root = get_tree().current_scene
		root.call_deferred("add_child", medkit)

func _on_KillZone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = body
		damage_timer = 0.0

func _on_KillZone_body_exited(body: Node) -> void:
	if body == player_in_zone:
		player_in_zone = null
		damage_timer = 0.0
