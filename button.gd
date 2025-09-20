extends Button






func _on_pressed() -> void:
	print("Restart button was pressed")
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
