extends CanvasLayer

var currItem = 0
var select = 0


func _ready() -> void:
	pass
	
	
func _process(_delta: float) -> void:
	pass
	


func _on_close_pressed():
	get_node("Anime").play("TransOut")

func switchItem(select):
	for i in range(Global.items.size()):
		if select == i:
			currItem = select
			get_node("Control/AnimatedSprite2D").play(Global.items[currItem]["Name"])
			get_node("Control/Name").text = Global.items[currItem]["Name"]
			get_node("Control/Des").text = Global.items[currItem]["Des"]
			get_node("Control/Des").text += "\n Cost: " + str(Global.items[currItem]["Cost"])


func _on_prev_pressed() -> void:
	switchItem(currItem-1)


func _on_next_pressed() -> void:
	switchItem(currItem+1)


func _on_buy_pressed() -> void:
	var hasItem = false
	for i in Global.inventory:
		if Global.inventory[i]["Name"] == Global.items[currItem]["Name"]:
			Global.inventory[i]["Count"] += 1
			hasItem = true
	if hasItem == false:
		
		Global.inventory[Global.inventory.size()] =Global.items[currItem]
	
	
