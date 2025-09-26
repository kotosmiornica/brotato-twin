extends Label

func _on_coins_changed(new_amount: int) -> void:
	text = str(new_amount)
