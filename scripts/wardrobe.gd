extends Control

@onready var player = get_node("/root/Control/MakeYourPlayer")

var currItem: int = 0

func _ready() -> void:
	switch_item(currItem)

# Show the currently selected item
func switch_item(index: int) -> void:
	currItem = index % Global.items.size()
	var item_data = Global.items[currItem]

	$Panel/Control/Name.text = item_data["Name"]
	$Panel/Control/Des.text = item_data["Des"]

	# Only show animation if the item is owned
	if item_data.get("Owned", false):
		$Panel/Control/AnimatedSprite2D.play(item_data["Name"])
	else:
		$Panel/Control/AnimatedSprite2D.stop()

func _on_prev_pressed() -> void:
	switch_item(currItem - 1)

func _on_next_pressed() -> void:
	switch_item(currItem + 1)

# Equip the currently selected item
func _on_equip_pressed() -> void:
	var item_data = Global.items[currItem]

	if not item_data.get("Owned", false):
		print("You don’t own this item yet!")
		$NotEnough.play()
		return

	var player_node = get_tree().get_root().get_node("Control/MakeYourPlayer") 
	if not player_node:
		print("MakeYourPlayer node not found!")
		return

	match item_data["Name"]:
		"BlueWig":
			var wig_node = player_node.get_node_or_null("BlueWig")
			if wig_node:
				wig_node.visible = true
				wig_node.play("BlueWig")
				wig_node.z_index = 10

				# save globally which hair is equipped
				PlayerData.equipped_hair = "BlueWig"

				print("Equipped BlueWig!")

		"Heart":
			var heart_node = player_node.get_node_or_null("Heart")
			if heart_node:
				heart_node.visible = true
				heart_node.play("Heart")
				heart_node.z_index = 10

				# save globally which accessory is equipped
				PlayerData.equipped_accessory = "Heart"

				print("Equipped Heart!")

func _on_close_pressed() -> void:
	var anim = get_node("/root/Control/Shop/Anim")
	if anim:
		anim.play("TransOut")
