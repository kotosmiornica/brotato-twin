extends Node2D
@onready var hook = $Hook
@onready var foods_container = $Foods
@export var spawn_interval = 0.4
@export var hook_end_y = 10.0
@export var base_speed = 280.0
@export var max_speed = 380.0
@export var hook_start_offset = 800
var fishing_active = true
var spawn_timer = 0.0
var hook_rise_speed = 5.0
var caught_foods := []
func _ready():
	PlayerData.caught_foods.clear()
	var screen_size = get_viewport_rect().size
	hook.position = Vector2(
		screen_size.x / 2,
		screen_size.y - hook.texture.get_size().y + hook_start_offset)
func _process(delta):
	if fishing_active:
		var hook_start_y = get_viewport_rect().size.y - hook.texture.get_size().y
		var progress = clamp(1.0 - (hook.position.y - hook_end_y) / (hook_start_y - hook_end_y), 0.0, 1.0)
		hook_rise_speed = lerp(base_speed, max_speed, progress)
		hook.position.y -= hook_rise_speed * delta
		hook.position.y = max(hook.position.y, hook_end_y)
		var mouse_x = get_viewport().get_mouse_position().x
		var hook_speed = 5
		hook.position.x = lerp(hook.position.x, mouse_x, hook_speed * delta)
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_food()
			spawn_timer = 0.0
		for food in foods_container.get_children():
			if hook.global_position.distance_to(food.global_position) < 32:
				if not caught_foods.has(food):
					caught_foods.append(food)
					if "food_type" in food:
						PlayerData.caught_foods.append(food.food_type)
					else:
						PlayerData.caught_foods.append("Unknown")
					food.queue_free()
					$caught.play()
	if hook.position.y <= hook_end_y:
		fishing_active = false
		hook.visible = false
		PlayerData.caught_food_count = caught_foods.size()
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
func get_food_scene() -> PackedScene:
	var level = PlayerData.unlocked_fishing_levels
	if level == 1:
		return preload("res://scenes/Leek.tscn")
	elif level == 2:
		return preload("res://scenes/ToyKnife.tscn")
	elif level == 3:
		return preload("res://scenes/BlackMonster.tscn")
	# fallback
	return preload("res://scenes/Leek.tscn")
func spawn_food():
	var food_scene = get_food_scene()  # get correct scene for current level
	for i in range(5):
		var new_food = food_scene.instantiate()
		var y = randf_range(100, get_viewport_rect().size.y - 150)
		new_food.position = Vector2(-50, y)
		foods_container.add_child(new_food)
