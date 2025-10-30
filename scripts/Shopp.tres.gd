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

	if not Global.has("inventory"):
		Global.inventory = []

	for inv_item in Global.inventory:
		if inv_item["Name"] == item_data["Name"]:
			print("Item already bought!")
			return

	if Global.coins < cost:
		print("Not enough coins!")
		return

	Global.spend_coins(cost)

	Global.inventory.append(item_data.duplicate())

	if item_data.has("ScenePath"):
		var item_scene = load(item_data["ScenePath"])
		if item_scene:
			var instance = item_scene.instantiate()
			player.add_child(instance)
			print("Added item to player:", item_data["Name"])

	print("Bought:", item_data["Name"], "Remaining coins:", Global.coins)
