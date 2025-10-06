extends Control

@onready var eating_pet = $EatingPet
@onready var flying_foods_container = $FlyingFoodsContainer
@onready var coins_container = $ColorRect/FlyingCoinsContainer
@onready var coins_label = $ColorRect/CoinsLabel
@onready var food_counter_label = $ColorRect/FoodCounterLabel
@onready var fishing_level2_label = $UnlockLevel2
@onready var fishing_level3_label = $UnlockLevel3

@export var coins_per_food: int = 14
@export var coin_stagger: float = 0.05

var food_counts := {}
var food_scenes := {
	"Leek": preload("res://scenes/Leek.tscn"),
	"ToyKnife": preload("res://scenes/ToyKnife.tscn"),
	"BlackMonster": preload("res://scenes/BlackMonster.tscn")
}

var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")

var active_coins := []

func _ready():
	apply_equipped_hair()
	coins_label.text = str(Global.coins)
	if PlayerData.caught_food_count > 0:
		trigger_flying_foods()
		PlayerData.caught_food_count = 0

func trigger_flying_foods():
	for food_type in PlayerData.caught_foods:
		spawn_flying_food(food_type)
	PlayerData.caught_foods.clear()

func spawn_flying_food(food_type: String):
	var scene_path = ""
	
	match food_type:
		"Leek":
			scene_path = "res://scenes/Leek.tscn"
		"ToyKnife":
			scene_path = "res://scenes/ToyKnife.tscn"
		"BlackMonster":
			scene_path = "res://scenes/BlackMonster.tscn"


	# Use load() instead of preload() for dynamic path
	var food_scene = load(scene_path)
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
	if not is_instance_valid(food):
		return

	# Remove the food immediately
	food.queue_free()

	# Handle food type
	var food_type = food.food_type  # assumes Food.gd script exists
	if food_type == null or food_type == "":
		food_type = "Unknown"

	if not PlayerData.food_counts.has(food_type):
		PlayerData.food_counts[food_type] = 0
	PlayerData.food_counts[food_type] += 1

	update_food_counter_label()
	spawn_coins_for_food()



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




# ------------------------
# Unlock next fishing level
# ------------------------
func _on_unlock_fishing_level2_pressed() -> void:
	var next_level = PlayerData.unlocked_fishing_levels + 1
	var cost = 15

	if PlayerData.food_counts.get("Leek", 0) < cost:
		print("Not enough Leeks to unlock this level!")
		$UnlockLevel2/NotEnough.play()
		return

	# Deduct Leeks
	PlayerData.food_counts["Leek"] -= cost

	# Unlock next level
	PlayerData.unlocked_fishing_levels = next_level
	print("Unlocked fishing level", next_level)

	# Update UI
	fishing_level2_label.text = "Fishing Level " + str(next_level) + " unlocked!"
	$UnlockLevel2/buy.play()

func _on_unlock_level_3_pressed() -> void:
	var next_level = PlayerData.unlocked_fishing_levels + 1
	var cost = 20

	if PlayerData.food_counts.get("ToyKnife", 0) < cost:
		print("Not enough Knives to unlock this level!")
		$UnlockLevel3/NotEnough.play()
		return

	# Deduct Leeks
	PlayerData.food_counts["ToyKnife"] -= cost

	# Unlock next level
	PlayerData.unlocked_fishing_levels = next_level
	print("Unlocked fishing level", next_level)

	# Update UI
	fishing_level3_label.text = "Fishing Level " + str(next_level) + " unlocked!"
	$UnlockLevel3/buy.play()


func _on_settings_pressed():
	$click.play()
	print("Button clicked!")

	var anim = get_node("/root/Control/SettingsMenu/Animations")
	if anim:
		print("AnimationPlayer found!")
		anim.play("FadeIn")
	else:
		print("Animation node not found!")
