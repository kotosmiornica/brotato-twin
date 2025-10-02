extends Control

@onready var eating_pet = $EatingPet
@onready var flying_foods_container = $FlyingFoodsContainer
@onready var coins_container = $ColorRect/FlyingCoinsContainer
@onready var coins_label = $ColorRect/CoinsLabel
@onready var food_counter_label = $ColorRect/FoodCounterLabel

@export var coins_per_food: int = 14
@export var coin_stagger: float = 0.05

var food_counts := {}
var food_scene: PackedScene = preload("res://scenes/Food.tscn")
var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")

var active_coins := []

func _ready():
	apply_equipped_hair()
	coins_label.text = str(Global.coins)
	if PlayerData.caught_food_count > 0:
		trigger_flying_foods()
		PlayerData.caught_food_count = 0

func trigger_flying_foods():
	for i in range(PlayerData.caught_food_count):
		spawn_flying_food()

func spawn_flying_food():
	var food = food_scene.instantiate()
	flying_foods_container.add_child(food)

	var screen_size = get_viewport_rect().size
	food.global_position = Vector2(randf_range(100, screen_size.x - 100), screen_size.y + 20)

	var pet_pos = eating_pet.global_position

	var food_tween = create_tween()
	food_tween.tween_property(food, "global_position", pet_pos, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	food_tween.tween_callback(Callable(self, "_on_food_reached_pet").bind(food))

func spawn_coins_for_food():
	for i in range(coins_per_food):
		spawn_single_coin(i * coin_stagger)

func spawn_single_coin(delay: float = 0.0):
	var coin = coin_scene.instantiate()
	get_tree().root.add_child(coin)  
	active_coins.append(coin)
	coin.set_meta("counted", false)
	coin.global_position = eating_pet.global_position + Vector2(randf_range(-70, 10), randf_range(-70, 10))


	var target_pos = coins_label.global_position + coins_label.size / 2

	var tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(coin, "global_position", target_pos, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_coin_reached_label").bind(coin))


func _on_coin_reached_label(coin):
	$ColorRect/CoinsLabel/CoinSound.play()
	if not is_instance_valid(coin):
		return

	if coin.has_meta("counted") and coin.get_meta("counted") == true:
		coin.queue_free()
		return

	coin.set_meta("counted", true)
	coin.queue_free()
	active_coins.erase(coin)

	Global.coins += 1
	coins_label.text = str(Global.coins)

func _on_food_reached_pet(food):
	print("Food reached pet:", food)

	eating_pet.call_deferred("on_food_arrived", food)

	var food_type = food.food_type
	print("Food type:", food_type)   # 👈 check this

	if food_type == null or food_type == "":
		food_type = "Unknown"

	if not PlayerData.food_counts.has(food_type):
		PlayerData.food_counts[food_type] = 0
	PlayerData.food_counts[food_type] += 1

	update_food_counter_label()



func update_food_counter_label():
	var text = ""
	for food_type in PlayerData.food_counts.keys():
		text += "%s: %d\n" % [food_type, PlayerData.food_counts[food_type]]
	food_counter_label.text = text


func apply_equipped_hair():
	var hair_name = PlayerData.equipped_hair
	var player_node = $MakeYourPlayer
	var wig_node = player_node.get_node_or_null(hair_name)
	if wig_node:
		wig_node.visible = true
		wig_node.play(hair_name)
		wig_node.z_index = 10
		


func _on_wardrobe_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Wardrobe.tscn")
