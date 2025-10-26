extends Node2D

var player: Node = null
var cooldown: float = 15
var _time_passed: float = 0.0

var stain_scene = preload("res://scenes/BleachStain.tscn")

func _process(delta: float) -> void:
	if player == null:
		return

	_time_passed += delta
	if _time_passed >= cooldown:
		_time_passed = 0
		spawn_stain()


func spawn_stain() -> void:
	var bleach_level = Global.bleach_level
	var stain = stain_scene.instantiate()
	stain.global_position = player.global_position

	stain.scale = Vector2.ONE * (1.0 + (bleach_level - 1) * 0.7)

	print("Bleach level:", bleach_level, " | Scale:", stain.scale)

	get_tree().current_scene.add_child(stain)
