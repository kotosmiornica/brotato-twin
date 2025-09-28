extends Label

func _ready() -> void:
	pass
	


func _process(_delta: float):
	text = "Coins: " + str(Global.coins)
