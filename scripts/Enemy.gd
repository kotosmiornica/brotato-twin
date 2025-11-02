extends CharacterBody2D

signal died

@export var medkit_drop_chance: float = 0.0002
@export var damage_amount: int = 10
@export var damage_interval: float = 0.5
@onready var player = get_node("/root/game/Brotat")

var player_in_zone: Node = null
var damage_timer: float = 0.0
var health = 8
var active_effects = {}

var FT_Script = preload("res://scripts/FightingText.gd")
const XP_SCENE = preload("res://scenes/XPpickups.tscn")
const MEDKIT_SCENE = preload("res://scenes/MedKit.tscn")
const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")

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
	velocity = direction * 250.0
	move_and_slide()

	if player_in_zone:
		damage_timer += delta
		if damage_timer >= damage_interval:
			player.take_damage(damage_amount)
			damage_timer = 0.0

	_update_effects(delta)

func _update_effects(delta: float) -> void:
	for effect_name in active_effects.keys():
		var effect = active_effects[effect_name]
		if effect.has("damage_per_second"):
			effect["time_accum"] += delta
			while effect["time_accum"] >= 1.0:
				var dmg = int(effect["damage_per_second"])
				take_damage(dmg)
				effect["time_accum"] -= 1.0
		effect["time_left"] -= delta
		if effect["time_left"] <= 0:
			active_effects.erase(effect_name)

func apply_status_effect(effect_name: String, duration: float, damage_per_second: float) -> void:
	if active_effects.has(effect_name):
		active_effects[effect_name]["time_left"] = duration
		return
	active_effects[effect_name] = {
		"time_left": duration,
		"damage_per_second": damage_per_second,
		"time_accum": 0.0
	}

func take_damage(amount: int):
	health -= amount
	%Slime.play_hurt()
	$slimehurt.play()
	_show_damage_popup(amount)
	if health <= 0:
		drop_xp()
		drop_medkit_random()
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		emit_signal("died")
		$slimehurt.play()
		queue_free()

func _show_damage_popup(amount: int):
	if amount > 0:
		var popup = FT_Script.new()
		popup.show_text(str(amount), global_position)
		get_tree().current_scene.add_child(popup)

func drop_xp():
	var xp = XP_SCENE.instantiate()
	xp.global_position = global_position
	var root = get_tree().current_scene
	root.call_deferred("add_child", xp)
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		xp.connect("collected", Callable(player_node, "_on_xp_collected"))

func drop_medkit_random():
	if randf() < medkit_drop_chance:
		var medkit = MEDKIT_SCENE.instantiate()
		medkit.global_position = global_position
		var root = get_tree().current_scene
		root.call_deferred("add_child", medkit)

func _on_KillZone_body_entered(body: Node) -> void:
	if body.is_in_group("player") and player_in_zone == null:
		player_in_zone = body
		damage_timer = 0.0

func _on_KillZone_body_exited(body: Node) -> void:
	if body == player_in_zone:
		player_in_zone = null
		damage_timer = 0.0
