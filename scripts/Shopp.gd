extends CanvasLayer


@onready var player = get_node("/root/Control/MakeYourPlayer")

var currItem: int = 0


func _ready() -> void:
	switch_item(currItem)


func switch_item(index: int) -> void:
	currItem = index % Global.items.size()
	var item_data = Global.items[currItem]

	$Control/Name.text = item_data["Name"]
	$Control/Des.text = item_data["Des"] + "\nCost: " + str(item_data["Cost"])
	$Control/AnimatedSprite2D.play(item_data["Name"])

func _on_prev_pressed() -> void:
	switch_item(currItem - 1)

func _on_next_pressed() -> void:
	switch_item(currItem + 1)

func _on_buy_pressed() -> void:
	var item_data = Global.items[currItem]
	var cost = item_data.get("Cost", 0)

	if Global.coins < cost:
		print("Not enough coins!")
		$NotEnough.play()
		return
	else:
		$buy.play()

	var player_node = get_tree().get_root().get_node("Control/MakeYourPlayer") 
	if not player_node:
		print("MakeYourPlayer node not found!")
		return

	if item_data["Name"] == "BlueWig":
		var wig_node = player_node.get_node_or_null("BlueWig")
		if wig_node:
			wig_node.visible = true
			wig_node.play("BlueWig")
			wig_node.z_index = 10

			# save globally which hair is equipped
			PlayerData.equipped_hair = "BlueWig"

			Global.coins -= cost
			item_data["Owned"] = true
			PlayerData.owned_items.append(item_data["Name"])
			%CoinsLabel.text = str(Global.coins)

		print("Bought:", item_data["Name"], "Remaining coins:", Global.coins)


	elif item_data["Name"] == "Heart":
		var heart_node = player_node.get_node_or_null("Heart")
		if heart_node:
			heart_node.visible = true
			heart_node.play("Heart")
			heart_node.z_index = 10

			PlayerData.equipped_hair = "Heart"

			Global.coins -= cost
			item_data["Owned"] = true
			PlayerData.owned_items.append(item_data["Name"])
			%CoinsLabel.text = str(Global.coins)

		print("Bought:", item_data["Name"], "Remaining coins:", Global.coins)


func _on_close_pressed() -> void:
	print("Button clicked!")

	var anim = get_node("/root/Control/Shop/Anim")
	if anim:
		print("AnimationPlayer found!")
		anim.play("TransOut")
	else:
		print("Animation not found")
		
