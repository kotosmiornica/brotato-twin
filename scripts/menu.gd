extends Control


@onready var eating_pet = $ColorRect/EatingPet
@onready var coins_container = $ColorRect/FlyingCoinsContainer
@onready var coins_label = $ColorRect/CoinsLabel


@export var coin_scene: PackedScene
var food_scene: PackedScene = preload("res://scenes/Food.tscn")

@export var coins_per_food: int = 4
@export var coin_stagger: float = 0.05


var displayed_coins: int = 0
var active_coins := []


func _ready():
	var callable = Callable(%CoinsLabel, "_on_coins_changed")
	if not Global.is_connected("coins_changed", callable):
		Global.connect("coins_changed", callable)

	%CoinsLabel.text = str(Global.coins)
	for coin in active_coins:
		if is_instance_valid(coin):
			coin.queue_free()
	active_coins.clear()
	for coin in coins_container.get_children():
		if is_instance_valid(coin):
			coin.queue_free()

	displayed_coins = Global.coins
	coins_label.text = str(displayed_coins)



func trigger_flying_foods():
	if PlayerData.caught_food_count <= 0:
		return

	for i in range(PlayerData.caught_food_count):
		spawn_flying_food()
	PlayerData.caught_food_count = 0


func spawn_flying_food():
	var food = food_scene.instantiate()
	add_child(food) 


	var screen_size = get_viewport_rect().size
	food.global_position = Vector2(randf_range(100, screen_size.x - 100), screen_size.y + 20)


	var food_tween = create_tween()
	food_tween.tween_property(food, "global_position", eating_pet.global_position, 0.7)
	food_tween.tween_callback(Callable(self, "_on_food_reached_pet").bind(food))


func _on_food_reached_pet(food):
	if not is_instance_valid(food):
		return

	food.queue_free()


	for i in range(coins_per_food):
		spawn_single_coin(i * coin_stagger)


func spawn_single_coin(delay: float = 0.0):
	var coin = coin_scene.instantiate()
	coins_container.add_child(coin)
	active_coins.append(coin)
	coin.set_meta("counted", false)


	coin.global_position = eating_pet.global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))


	var target_pos = coins_label.global_position + coins_label.size / 2


	var coin_tween = create_tween()
	coin_tween.tween_interval(delay)
	coin_tween.tween_property(coin, "global_position", target_pos, 0.7)
	coin_tween.tween_callback(Callable(self, "_on_coin_reached_label").bind(coin))


func _on_coin_reached_label(coin):
	if not is_instance_valid(coin):
		return

	if coin.has_meta("counted") and coin.get_meta("counted") == true:
		coin.queue_free()
		return

	coin.set_meta("counted", true)
	coin.queue_free()
	active_coins.erase(coin)


	Global.add_coins(1)
