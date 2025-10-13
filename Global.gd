extends Node

var coins = 0
signal coins_changed(new_amount)


func add_coins(amount):
	coins += amount
	emit_signal("coins_changed", coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		emit_signal("coins_changed", coins)
		return true
	return false


var items = [
	{
		"Name": "BlueWig",
		"Des": "Suddenly you want to sing at 750BPM.",
		"Cost": 20,
		"Currency": "Leek"  # 🧄 requires 50 Leeks
	},
	{
		"Name": "Heart",
		"Des": "Equipping this fills you with determination.",
		"Cost": 20,
		"Currency": "ToyKnife"  # 🔪 requires 50 ToyKnives
	},
	{
		"Name": "EmotionalWig",
		"Des": "Such deeply EMOtional hairstyle (wip).",
		"Cost": 20,
		"Currency": "BlackMonster"  # 👾 requires 50 BlackMonsters
	}
]
