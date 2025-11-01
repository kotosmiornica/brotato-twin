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

func authenticate():
	var guestLoginResponse = await LL_Authentication.GuestSession.new("test").send()
	if(!guestLoginResponse.success):
		printerr("Guest login failed with reason: " + guestLoginResponse.error_data.to_string())
		return
	print("Guest user was successfully signed in to LootLocker")
	var score_list_response: LL_Leaderboards._LL_GetScoreListResponse = await LL_Leaderboards.GetScoreList.new("main").send()
	if(!score_list_response.success):
		printerr("Failed to get score list response: " + score_list_response.error_data.to_string())
	else:
		pass
	#for entry in score_list.items:
	#	print(entry.member_id, entry.player, entry.rank, entry.score)
	#score_list.items.get(0)

func _ready():
	authenticate()
	apply_equipped_hair()
	coins_label.text = str(Global.coins)
	if Global.caught_food_count > 0:
		trigger_flying_foods()
		Global.caught_food_count = 0
	
	update_unlock_buttons()
	if Global.extra_gun_unlocked:
		$UnlockExtraGun.disabled = true
		$UnlockExtraGun.text = "Already unlocked!"
		
func trigger_flying_foods():
	for food_type in Global.caught_foods:
		spawn_flying_food(food_type)
	Global.caught_foods.clear()

func spawn_flying_food(food_type: String):
	var food_scene = food_scenes.get(food_type, food_scenes["Leek"])
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

	food.queue_free()

	var food_type = food.food_type if "food_type" in food else "Unknown"

	if not Global.food_counts.has(food_type):
		Global.food_counts[food_type] = 0
	Global.food_counts[food_type] += 1

	update_food_counter_label()
	spawn_coins_for_food()

func update_food_counter_label():
	var text = ""
	for food_type in Global.food_counts.keys():
		text += "%s: %d\n" % [food_type, Global.food_counts[food_type]]
	food_counter_label.text = text

func apply_equipped_hair():
	var hair_name = Global.equipped_hair
	var player_node = $MakeYourPlayer
	var wig_node = player_node.get_node_or_null(hair_name)
	if wig_node:
		wig_node.visible = true
		wig_node.play(hair_name)
		wig_node.z_index = 10

func _on_wardrobe_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Wardrobe.tscn")

# ------------------------
# Unlock next fishing level using coins

func _on_unlock_fishing_level2_pressed() -> void:
	var next_level = 2
	var cost = 155

	if Global.unlocked_fishing_levels >= next_level:
		print("Fishing level 2 already unlocked!")
		return

	if Global.coins < cost:
		print("Not enough coins to unlock this level!")
		$UnlockLevel2/NotEnough.play()
		return

	Global.coins -= cost
	coins_label.text = str(Global.coins)

	Global.unlocked_fishing_levels = next_level
	print("Unlocked fishing level", next_level)

	fishing_level2_label.visible = false
	fishing_level2_label.disabled = true
	$UnlockLevel2/buy.play()

	update_unlock_buttons()

func _on_unlock_level_3_pressed() -> void:
	var next_level = 3
	var cost = 280

	if Global.unlocked_fishing_levels >= next_level:
		print("Fishing level 3 already unlocked!")
		return


	if Global.unlocked_fishing_levels < 2:
		print("You need to unlock Level 2 first!")
		$UnlockLevel3/NotEnough.play()
		return

	if Global.coins < cost:
		print("Not enough coins to unlock this level!")
		$UnlockLevel3/NotEnough.play()
		return

	Global.coins -= cost
	coins_label.text = str(Global.coins)

	Global.unlocked_fishing_levels = next_level
	print("Unlocked fishing level", next_level)

	fishing_level3_label.text = "Fishing Level 3 Unlocked!"
	fishing_level3_label.disabled = true
	$UnlockLevel3/buy.play()

	update_unlock_buttons()

func update_unlock_buttons():

	fishing_level3_label.visible = Global.unlocked_fishing_levels >= 2


	if Global.unlocked_fishing_levels >= 2:
		fishing_level2_label.text = "Fishing Level 2 Unlocked!"
		fishing_level2_label.disabled = true
	if Global.unlocked_fishing_levels >= 3:
		fishing_level3_label.text = "Fishing Level 3 Unlocked!"
		fishing_level3_label.disabled = true

func _on_settings_pressed():
	$click.play()
	var anim = get_node("/root/Control/SettingsMenu/Animations")
	if anim:
		anim.play("FadeIn")


func _on_unlock_extra_gun_pressed() -> void:
	var cost = 40

	if Global.extra_gun_unlocked:
		print("Extra gun already unlocked!")
		$UnlockExtraGun.disabled = true
		$UnlockExtraGun.text = "Already unlocked!"
		return

	if Global.coins < cost:
		print("Not enough coins! Need %d more." % (cost - Global.coins))
		$UnlockExtraGun/NotEnough.play()
		$UnlockExtraGun.text = "Need 400 coins!"
		return

	Global.coins -= cost
	coins_label.text = str(Global.coins)

	Global.unlock_extra_gun()
	$UnlockExtraGun.disabled = true
	$UnlockExtraGun.text = "Now go and play with the slimes >:3!"
	$UnlockExtraGun/buy.play()
	print("Extra gun unlocked for %d coins!" % cost)
