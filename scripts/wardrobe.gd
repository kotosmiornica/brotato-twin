extends CanvasLayer

@onready var player = get_node("/root/Control/MakeYourPlayer")
@onready var buy_button = $Control/Buy
@onready var confirm_button = $Control/Confirm
var currItem: int = 0
var wardrobe_items: Array = []

func _ready() -> void:
	wardrobe_items = []
	for item in Global.items:
		if item.has("Owned") and item["Owned"]:
			wardrobe_items.append(item)
	if wardrobe_items.size() > 0:
		switch_item(0)

func switch_item(index: int) -> void:
	if wardrobe_items.size() == 0:
		return
	currItem = index % wardrobe_items.size()
	var item_data = wardrobe_items[currItem]
	$Control/Name.text = item_data["Name"]
	$Control/Des.text = item_data["Des"]
	$Control/AnimatedSprite2D.play(item_data["Name"])

func _on_prev_pressed() -> void:
	switch_item(currItem - 1)

func _on_next_pressed() -> void:
	switch_item(currItem + 1)

func _on_confirm_pressed() -> void:
	if wardrobe_items.size() == 0:
		return
	var item_data = wardrobe_items[currItem]
	var node_name = item_data["Name"]
	Global.equipped_hair = node_name
	var equip_node = player.get_node_or_null(node_name)
	if equip_node:
		equip_node.visible = true
		equip_node.play(node_name)
	print("Equipped:", node_name)
