extends CanvasLayer

@onready var player = get_node("/root/Control/MakeYourPlayer")
@onready var buy_button = $Control/Buy
var currItem: int = 0

func _ready() -> void:
	switch_item(currItem)

func switch_item(index: int) -> void:
	currItem = index % Global.items.size()
	var item_data = Global.items[currItem]
	var owned_text = ""
	if item_data.has("Owned") and item_data["Owned"]:
		owned_text = " (Owned)"
	$Control/Name.text = item_data["Name"] + owned_text
	$Control/Des.text = item_data["Des"] + "\nCost: " + str(item_data["Cost"]) + " " + item_data["Currency"]
	$Control/Buy.disabled = item_data.has("Owned") and item_data["Owned"]
	$Control/AnimatedSprite2D.play(item_data["Name"])

func _on_prev_pressed() -> void:
	switch_item(currItem - 1)

func _on_next_pressed() -> void:
	switch_item(currItem + 1)

func _on_buy_pressed() -> void:
	var item_data = Global.items[currItem]
	var cost = item_data.get("Cost", 0)
	var currency = item_data.get("Currency", "")

	if item_data.has("Owned") and item_data["Owned"]:
		print("%s already owned!" % item_data["Name"])
		$NotEnough.play()
		return

	if not Global.food_counts.has(currency) or Global.food_counts[currency] < cost:
		print("Not enough %s to buy %s!" % [currency, item_data["Name"]])
		$NotEnough.play()
		return
	else:
		$buy.play()

	Global.food_counts[currency] -= cost

	var node_name = item_data["Name"]
	var equip_node = player.get_node_or_null(node_name)
	if equip_node:
		equip_node.visible = true
		equip_node.play(node_name)
		equip_node.z_index = 10

	Global.equipped_hair = node_name
	item_data["Owned"] = true
	Global.owned_items.append(node_name)

	print("Bought:", item_data["Name"])
	$Control/Buy.disabled = true
	$Control/Name.text = item_data["Name"] + " (Owned)"

func _on_close_pressed() -> void:
	var anim = get_node("/root/Control/Shop/Anim")
	if anim:
		anim.play("TransOut")
