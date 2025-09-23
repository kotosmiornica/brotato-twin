extends Node2D

# Nodes
@onready var hook = $Hook
@onready var foods_container = $Foods

# Exported variables
@export var food_scene: PackedScene
@export var spawn_interval = 0.3
@export var hook_end_y = 50.0    
@export var base_speed = 120.0      # hook start speed
@export var max_speed = 350.0       # hook max speed
@export var hook_start_offset = 500  # default at current bottom


# State
var fishing_active = true
var spawn_timer = 0.0
var hook_rise_speed = 6.0
var caught_foods := []

func _ready():
	var screen_size = get_viewport_rect().size
	hook.position = Vector2(
		screen_size.x / 2, 
		screen_size.y - hook.texture.get_size().y + hook_start_offset)


func _process(delta):
	if fishing_active:
		# Height-based acceleration
		var hook_start_y = get_viewport_rect().size.y - hook.texture.get_size().y
		var progress = clamp(1.0 - (hook.position.y - hook_end_y) / (hook_start_y - hook_end_y), 0.0, 1.0)
		hook_rise_speed = lerp(base_speed, max_speed, progress)

		# Move hook up
		hook.position.y -= hook_rise_speed * delta
		hook.position.y = max(hook.position.y, hook_end_y)

		# Hook follows mouse horizontally
		hook.position.x = get_viewport().get_mouse_position().x

		# Spawn moving foods
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_food()
			spawn_timer = 0.0

		# Hook catches foods
		for food in foods_container.get_children():
			if hook.global_position.distance_to(food.global_position) < 32:
				if not caught_foods.has(food):
					caught_foods.append(food)
					food.queue_free()  # remove from screen immediately

		# End fishing session
		if hook.position.y <= hook_end_y:
			fishing_active = false
			hook.visible = false
			# Update singleton with caught food
			PlayerData.caught_food_count = caught_foods.size()
			PlayerData.coins += caught_foods.size() * 10
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func spawn_food():
	if food_scene == null:
		return
	for i in range(4):  # spawn 2 foods at a time
		var new_food = food_scene.instantiate()
		var y = randf_range(100, get_viewport_rect().size.y - 150)
		new_food.position = Vector2(-50, y)
		foods_container.add_child(new_food)
