extends CanvasLayer


@onready var player = get_node("/root/Control/MakeYourPlayer")

var currItem: int = 0


func _ready() -> void:
	switch_item(currItem)


func switch_item(index: int) -> void:
	currItem = index % Global.items.size()
	var item_data = Global.items[currItem]

	$Control/Name.text = item_data["Name"]
	var cost = item_data.get("Cost", 50)
	var currency = item_data.get("Currency", "Leek")  # default fallback
	$Control/Des.text = "%s\nCost: %d %s" % [item_data["Des"], cost, currency]

	$Control/AnimatedSprite2D.play(item_data["Name"])

func _on_prev_pressed() -> void:
	switch_item(currItem - 1)

func _on_next_pressed() -> void:
	switch_item(currItem + 1)

func _on_buy_pressed() -> void:
	var item_data = Global.items[currItem]
	var item_name = item_data["Name"]

	var player_node = get_tree().get_root().get_node("Control/MakeYourPlayer")
	if not player_node:
		print("MakeYourPlayer node not found!")
		return

	# Currency logic based on item type
	match item_name:
		"BlueWig":
			_buy_with_food(item_name, "Leek", 20, player_node)
		"Heart":
			_buy_with_food(item_name, "ToyKnife", 20, player_node)
		"EmotionalWig":
			_buy_with_food(item_name, "BlackMonster", 20, player_node)
		_:
			print("Unknown item:", item_name)


func _on_close_pressed() -> void:
	print("Button clicked!")

	var anim = get_node("/root/Control/Shop/Anim")
	if anim:
		print("AnimationPlayer found!")
		anim.play("TransOut")
	else:
		print("Animation not found")
		


func _buy_with_food(item_name: String, food_type: String, cost: int, player_node: Node) -> void:
	var current_amount = PlayerData.food_counts.get(food_type, 0)
	if current_amount < cost:
		print("Not enough %s to buy %s!" % [food_type, item_name])
		$NotEnough.play()
		return

	# Deduct the food cost
	PlayerData.food_counts[food_type] = current_amount - cost

	# Cosmetic application logic
	var cosmetic_node = player_node.get_node_or_null(item_name)
	if cosmetic_node:
		cosmetic_node.visible = true
		if cosmetic_node.has_method("play"):
			cosmetic_node.play(item_name)
		cosmetic_node.z_index = 10

	# Track ownership
	PlayerData.equipped_hair = item_name
	PlayerData.owned_items.append(item_name)

	$buy.play()
	print("Bought %s for %d %s(s)" % [item_name, cost, food_type])
