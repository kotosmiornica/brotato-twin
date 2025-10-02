extends Node2D

@onready var hook = $Hook
@onready var foods_container = $Foods
@onready var caught_sound = $caught

@export var hook_end_y: float = 50.0
@export var base_speed: float = 300.0
@export var max_speed: float = 350.0
@export var hook_start_offset: float = 500.0
@export var spawn_interval: float = 0.3

@export var leek_scene: PackedScene
@export var knife_scene: PackedScene
@export var monster_scene: PackedScene

var spawn_probabilities = {
	"leek": 0.6,	# 60%
	"knife": 0.3,	# 30%
	"monster": 0.1	# 10%
}

var fishing_active: bool = true
var spawn_timer: float = 0.0
var hook_rise_speed: float = 6.0
var caught_foods := []

func _ready():
	randomize()
	var screen_size = get_viewport_rect().size
	hook.position = Vector2(
		screen_size.x / 2,
		screen_size.y - hook.texture.get_size().y + hook_start_offset
	)

func _process(delta: float) -> void:
	if not fishing_active:
		return

	_move_hook(delta)
	_handle_food_spawn(delta)
	_check_catch()

	if hook.position.y <= hook_end_y:
		_end_fishing()

func _move_hook(delta: float) -> void:
	var hook_start_y = get_viewport_rect().size.y - hook.texture.get_size().y
	var progress = clamp(1.0 - (hook.position.y - hook_end_y) / (hook_start_y - hook_end_y), 0.0, 1.0)
	hook_rise_speed = lerp(base_speed, max_speed, progress)

	hook.position.y -= hook_rise_speed * delta
	hook.position.y = max(hook.position.y, hook_end_y)
	hook.position.x = get_viewport().get_mouse_position().x

func _handle_food_spawn(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_food()
		spawn_timer = 0.0

func _check_catch():
	for food in foods_container.get_children():
		if hook.global_position.distance_to(food.global_position) < 32:
			if not caught_foods.has(food):
				caught_foods.append(food)

				# get the type from the food scene
				var food_type: String = "unknown"
				if food.has_method("get_food_type"):
					food_type = food.get_food_type()

				# record directly into PlayerData
				PlayerData.caught_foods.append(food_type)
				PlayerData.caught_food_count = PlayerData.caught_foods.size()

				food.queue_free()
				caught_sound.play()

func _end_fishing() -> void:
	fishing_active = false
	hook.visible = false
	# PlayerData.caught_food_count already updated on each catch
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func spawn_food() -> void:
	# Decide which scene to spawn based on probabilities
	var r := randf()
	var chosen_scene: PackedScene = null

	if r < spawn_probabilities["leek"]:
		chosen_scene = leek_scene
	elif r < spawn_probabilities["leek"] + spawn_probabilities["knife"]:
		chosen_scene = knife_scene
	else:
		chosen_scene = monster_scene

	if chosen_scene == null:
		push_warning("spawn_food: one of the food scene exports is NULL. Assign scenes in the Inspector.")
		return

	# Spawn one or more instances (kept your original loop)
	for i in range(4):
		var new_food = chosen_scene.instantiate()
		var y = randf_range(100, get_viewport_rect().size.y - 150)
		new_food.position = Vector2(-50, y)
		foods_container.add_child(new_food)
