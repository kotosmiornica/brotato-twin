extends Node2D

@onready var hook = $Hook
@onready var hook_sprite = $Hook/Sprite2D
@onready var foods_container = $Foods
@export var spawn_interval = 0.4
@export var hook_end_y = 10.0
@export var base_speed = 170.0
@export var max_speed = 250.0
@export var hook_start_offset = 800

var fishing_active = true
var spawn_timer = 0.0
var hook_rise_speed = 5.0
var caught_foods := []

func _ready():
	Global.caught_foods.clear()
	var screen_size = get_viewport_rect().size
	hook.position = Vector2(
		screen_size.x / 2,
		screen_size.y - hook_sprite.texture.get_size().y + hook_start_offset
	)
	hook.connect("area_entered", Callable(self, "_on_hook_area_entered"))

func _process(delta):
	if fishing_active:
		var hook_start_y = get_viewport_rect().size.y - hook_sprite.texture.get_size().y
		var progress = clamp(1.0 - (hook.position.y - hook_end_y) / (hook_start_y - hook_end_y), 0.0, 1.0)
		hook_rise_speed = lerp(base_speed, max_speed, progress)
		hook.position.y -= hook_rise_speed * delta
		hook.position.y = max(hook.position.y, hook_end_y)
		var mouse_x = get_viewport().get_mouse_position().x
		var hook_speed = 2.5
		hook.position.x = lerp(hook.position.x, mouse_x, hook_speed * delta)
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_food()
			spawn_timer = 0.0
	if hook.position.y <= hook_end_y:
		fishing_active = false
		hook.visible = false
		Global.caught_food_count = caught_foods.size()
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _on_hook_area_entered(area: Area2D) -> void:
	if area.is_in_group("food") and not caught_foods.has(area):
		caught_foods.append(area)
		if "food_type" in area:
			Global.caught_foods.append(area.food_type)
		else:
			Global.caught_foods.append("Unknown")
		area.queue_free()
		$caught.play()

func get_food_scene() -> PackedScene:
	var level = Global.unlocked_fishing_levels
	if level == 1:
		return preload("res://scenes/Leek.tscn")
	elif level == 2:
		return preload("res://scenes/ToyKnife.tscn")
	elif level == 3:
		return preload("res://scenes/BlackMonster.tscn")
	return preload("res://scenes/Leek.tscn")

func spawn_food():
	var food_scene = get_food_scene()
	for i in range(6):
		var new_food = food_scene.instantiate()
		var y = randf_range(100, get_viewport_rect().size.y - 150)
		new_food.position = Vector2(-50, y)
		foods_container.add_child(new_food)
