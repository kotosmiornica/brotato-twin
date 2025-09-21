extends Control

# Nodes
@onready var eating_pet = $ColorRect/EatingPet
@onready var foods_container = $FlyingFoodsContainer   # Node2D to spawn flying foods
@onready var coins_container = $FlyingCoinsContainer   # Node2D to spawn flying coin sprites
@onready var coins_label = $ColorRect/CoinsLabel

# Coin sprite scene
@export var coin_scene: PackedScene

# State
var displayed_coins = 0

func _ready():
	displayed_coins = PlayerData.coins
	coins_label.text = str(displayed_coins)

	# Spawn flying foods
	for i in range(PlayerData.caught_food_count):
		spawn_flying_food()

	# Reset caught foods
	PlayerData.caught_food_count = 0

func spawn_flying_food():
	var food_scene = preload("res://scenes/Food.tscn")
	var food = food_scene.instantiate()
	foods_container.add_child(food)
	# Start at bottom
	var screen_size = get_viewport_rect().size
	food.position = Vector2(randf_range(100, screen_size.x - 100), screen_size.y - 50)

	# Tween to EatingPet
	var tween = create_tween()
	tween.tween_property(food, "position", eating_pet.global_position, 0.7)
	tween.tween_callback(func():
		if is_instance_valid(food):
			food.queue_free()
			spawn_flying_coin()  # spawn coin when food "eaten"
	)

func spawn_flying_coin(amount = 10):
	for i in range(amount):
		var coin = coin_scene.instantiate()
		coins_container.add_child(coin)
		# Start at EatingPet position
		coin.position = eating_pet.global_position

		# Add a small offset for each coin to avoid overlapping exactly
		coin.position.x += randf_range(-10, 10)
		coin.position.y += randf_range(-10, 10)

		# Target is coins_label center
		var label_pos = coins_label.get_global_position()
		var label_size = coins_label.get_size()
		var target_pos = label_pos + Vector2(label_size.x / 2, label_size.y / 2)

		# Optional: small delay per coin
		var tween = create_tween()
		tween.tween_interval(i * 0.05)  # 0.05s between coins
		tween.tween_property(coin, "position", target_pos, 0.5 + randf() * 0.2)
		tween.tween_callback(func():
			if is_instance_valid(coin):
				coin.queue_free()
				displayed_coins += 1
				coins_label.text = str(displayed_coins)
				PlayerData.coins = displayed_coins)
