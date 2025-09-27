extends Control

@export var item_name: String
@export var price: int
@export var description: String


@onready var buy_button = $Button if has_node("Button") else null
@onready var name_label = $NameLabel if has_node("NameLabel") else null
@onready var price_label = $PriceLabel if has_node("PriceLabel") else null

func _ready():
	if name_label:
		name_label.text = item_name
	if price_label:
		price_label.text = str(price) + " Coins"
	

	if buy_button:
		buy_button.pressed.connect(Callable(self, "_on_buy_pressed"))

func _on_buy_pressed():
	if PlayerData.coins >= price:
		PlayerData.coins -= price
		if not PlayerData.owned_items.has(item_name):
			PlayerData.owned_items.append(item_name)
		print("Purchased:", item_name)
		_update_ui()
	else:
		print("Not enough Coins for", item_name)

func _update_ui():
	if buy_button:
		buy_button.disabled = true
		buy_button.text = "Purchased"
