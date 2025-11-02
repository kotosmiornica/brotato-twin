extends Node2D

@onready var hook = $Hook
@onready var hook_sprite = $Hook/Sprite2D
@onready var foods_container = $Foods
@export var spawn_interval = 0.4
@export var hook_end_y = 10.0
@export var base_speed = 180.0
@export var max_speed = 220.0
@export var hook_start_offset = 800
@export var hook_height_fallback = 64

var fishing_active = true
var spawn_timer = 0.0
var hook_rise_speed = 5.0
var caught_foods := []
var hook_locked = false

func _ready():
	Global.caught_foods.clear()
	var screen_size = get_viewport_rect().size

	var hook_height = hook_height_fallback
	if hook_sprite.texture:
		hook_height = hook_sprite.texture.get_size().y

	hook.position = Vector2(
		screen_size.x / 2,
		screen_size.y - hook_height + hook_start_offset
	)

	hook.connect("area_entered", Callable(self, "_on_hook_area_entered"))

func _process(delta):
	if fishing_active:
		var hook_height = hook_height_fallback
		if hook_sprite.texture:
			hook_height = hook_sprite.texture.get_size().y

		var hook_start_y = get_viewport_rect().size.y - hook_height
		var progress = clamp(1.0 - (hook.position.y - hook_end_y) / (hook_start_y - hook_end_y), 0.0, 1.0)
		hook_rise_speed = lerp(base_speed, max_speed, progress)

		if hook_locked:
			var locked_speed = max_speed * 4
			hook.position.y -= locked_speed * delta
			if hook.position.y <= hook_end_y:
				end_fishing()
		else:
			hook.position.y -= hook_rise_speed * delta
			hook.position.y = max(hook.position.y, hook_end_y)

			var mouse_x = get_viewport().get_mouse_position().x
			hook.position.x = lerp(hook.position.x, mouse_x, 1.5 * delta)

			spawn_timer += delta
			if spawn_timer >= spawn_interval:
				spawn_food()
				spawn_timer = 0.0

	if not hook_locked and hook.position.y <= hook_end_y:
		end_fishing()

func _on_hook_area_entered(area: Area2D) -> void:
	if area.is_in_group("food") and not caught_foods.has(area):
		caught_foods.append(area)

		if "is_bad" in area and area.is_bad:
			Global.coins = max(Global.coins - 100, 0)
			$bad_sound.play()
			hook_locked = true
			spawn_timer = 0.0

			var floating_text_scene = preload("res://scenes/FloatingText.tscn")
			var floating_text = floating_text_scene.instantiate()
			foods_container.add_child(floating_text)
			floating_text.show_text("-100 coins", area.global_position)
		else:
			if "food_type" in area:
				Global.caught_foods.append(area.food_type)
			else:
				Global.caught_foods.append("Unknown")
			$caught.play()

		area.queue_free()

func get_food_scene() -> PackedScene:
	match Global.unlocked_fishing_levels:
		1: return preload("res://scenes/Leek.tscn")
		2: return preload("res://scenes/ToyKnife.tscn")
		3: return preload("res://scenes/BlackMonster.tscn")
		_: return preload("res://scenes/Leek.tscn")

func spawn_food():
	var food_scene = get_food_scene()
	var bad_food_scene = preload("res://scenes/BadFood.tscn")

	for i in range(4):
		var scene_to_spawn: PackedScene
		if randf() < 0.10:
			scene_to_spawn = bad_food_scene
		else:
			scene_to_spawn = food_scene

		var new_food = scene_to_spawn.instantiate()
		var y = randf_range(100, get_viewport_rect().size.y - 150)
		new_food.position = Vector2(-50, y)
		foods_container.add_child(new_food)

func end_fishing():
	fishing_active = false
	hook.visible = false
	Global.caught_food_count = caught_foods.size()
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
