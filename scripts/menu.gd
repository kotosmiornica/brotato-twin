extends Control

# Nodes
@onready var eating_pet = $ColorRect/EatingPet
@onready var foods_container = $FlyingFoodsContainer
@onready var coins_container = $FlyingCoinsContainer
@onready var coins_label = $ColorRect/CoinsLabel

# Scenes
@export var coin_scene: PackedScene
var food_scene: PackedScene = preload("res://scenes/Food.tscn")  # preload once

# State
var displayed_coins = 0

func _ready():
	# Start the coin counter at 0
	displayed_coins = 0
	coins_label.text = str(displayed_coins)

	# Spawn flying foods for all caught foods
	for i in range(PlayerData.caught_food_count):
		spawn_flying_food()

	# Reset caught foods
	PlayerData.caught_food_count = 0

func spawn_flying_food():
	var food = food_scene.instantiate()
	foods_container.add_child(food)

	# Start at bottom of the screen with random X
	var screen_size = get_viewport_rect().size
	food.position = Vector2(randf_range(100, screen_size.x - 100), screen_size.y - 50)

	# Tween food to the pet
	var food_tween = create_tween()
	food_tween.tween_property(food, "position", eating_pet.global_position, 0.7)
	food_tween.tween_callback(Callable(self, "_on_food_reached_pet").bind(food))

func _on_food_reached_pet(food):
	if is_instance_valid(food):
		food.queue_free()
		spawn_flying_coin()

func spawn_flying_coin(amount = 4):
	for i in range(amount):
		var coin = coin_scene.instantiate()
		coins_container.add_child(coin)

		# Start at pet's position with small random offset
		coin.position = eating_pet.global_position
		coin.position.x += randf_range(-10, 10)
		coin.position.y += randf_range(-10, 10)

		# Target is the center of the coins_label
		var label_pos = coins_label.get_global_position()
		var label_size = coins_label.get_size()
		var target_pos = label_pos + Vector2(label_size.x / 2, label_size.y / 2)

		# Tween coin to label
		var coin_tween = create_tween()
		coin_tween.tween_interval(i * 0.05)  # stagger coins slightly
		coin_tween.tween_property(coin, "position", target_pos, 0.5 + randf() * 0.2)
		coin_tween.tween_callback(Callable(self, "_on_coin_reached_label").bind(coin))

func _on_coin_reached_label(coin):
	if is_instance_valid(coin):
		coin.queue_free()
		_increment_coin()

func _increment_coin():
	displayed_coins += 1
	coins_label.text = str(displayed_coins)
	PlayerData.coins += 1


func _on_shop_button_pressed() -> void:
	pass # Replace with function body.
