extends Control


signal weapon_chosen(weapon_id)

func _on_weapon_1_pressed() -> void:
	emit_signal("weapon_chosen", "weapon_1")
	queue_free()



func _on_weapon_2_pressed() -> void:
	emit_signal("weapon_chosen", "weapon_2")
	queue_free()



func _on_weapon_3_pressed() -> void:
	emit_signal("weapon_chosen", "weapon_3")
	queue_free()
	
