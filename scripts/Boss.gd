extends CharacterBody2D

signal died

var health: int = 100
var speed: float = 220.0
var dash_speed: float = 600.0
var dash_distance: float = 150.0
var dash_cooldown: float = 2.0
var can_dash = true
var is_dashing = false
var dash_target: Vector2
var FT_Script = preload("res://scripts/FightingText.gd")
var SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
var XP_SCENE = preload("res://scenes/XPpickups.tscn")

@onready var player = get_node("/root/game/Brotat")
@onready var sprite = $BossSprite

func _ready() -> void:
	sprite.play_walk()
	add_to_group("enemies")

func _physics_process(_delta: float) -> void:
	if not player:
		return
	if is_dashing:
		var direction = (dash_target - global_position).normalized()
		velocity = direction * dash_speed
		move_and_slide()
		if global_position.distance_to(dash_target) < 5.0:
			is_dashing = false
	else:
		var distance = global_position.distance_to(player.global_position)
		if distance > dash_distance:
			velocity = global_position.direction_to(player.global_position) * speed
			move_and_slide()
		elif can_dash:
			can_dash = false
			velocity = Vector2.ZERO
			await get_tree().create_timer(3).timeout
			_start_dash()
			await get_tree().create_timer(dash_cooldown).timeout
			can_dash = true



func _start_dash() -> void:
	is_dashing = true
	dash_target = player.global_position

func take_damage(amount: int) -> void:
	health -= amount
	sprite.play_hurt()
	_show_damage_popup(amount)
	if health <= 0:
		_die()

func _show_damage_popup(amount: int) -> void:
	var popup = FT_Script.new()
	popup.show_text(str(amount), global_position)
	get_tree().current_scene.add_child(popup)

func _die() -> void:
	drop_xp()
	var smoke = SMOKE_SCENE.instantiate()
	smoke.global_position = global_position
	get_parent().add_child(smoke)
	emit_signal("died")
	queue_free()

func drop_xp() -> void:
	var xp = XP_SCENE.instantiate()
	xp.global_position = global_position
	var root = get_tree().current_scene
	root.call_deferred("add_child", xp)
	xp.connect("collected", root.get_node("Brotat")._on_xp_collected)
