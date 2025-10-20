extends CharacterBody2D  

signal died

var health = 3  
@export var medkit_drop_chance: float = 0.0002 

@onready var player = get_node("/root/game/Brotat")

# Preload the floating text script
var FT_Script = preload("res://scripts/FightingText.gd")

func _ready() -> void:
	%Slime.play_walk()
	add_to_group("enemies")

func _physics_process(_delta: float) -> void:
	var target = player.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	var direction = (target - global_position).normalized()
	velocity = direction * 300.0
	move_and_slide()

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
