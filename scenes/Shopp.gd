extends CanvasLayer

# Player node
@onready var player = get_node("/root/Control/MakeYourPlayer")

# Current shop selection
var currItem: int = 0


func _ready() -> void:
	switch_item(currItem)

# Switch displayed item in the shop
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

	# Check coins
	if Global.coins < cost:
		print("Not enough coins!")
		return

	Global.coins -= cost

	# Find MakeYourPlayer node safely
	var player_node = get_tree().get_root().get_node("Control/MakeYourPlayer") # Adjust "Main" to your scene root name
	if not player_node:
		print("MakeYourPlayer node not found!")
		return

	# Find MikuWig under the player
	var wig_node = player_node.get_node_or_null("BlueWig")
	if wig_node:
		wig_node.visible = true
		wig_node.play("BlueWig")
		wig_node.z_index = 10
		print("Blue wig activated!")
	else:
		print("BlueWig node not found!")

	print("Bought:", item_data["Name"], "Remaining coins:", Global.coins)


func _on_close_pressed() -> void:
	print("Button clicked!")

	var anim = get_node("/root/Control/Shop/Anim")
	if anim:
		print("AnimationPlayer found!")
		anim.play("TransOut")
	else:
		print("Animation node")
		
