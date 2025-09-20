extends Button




func _on_restart_button_pressed() -> void:
	print("works")
	get_tree().reload_current_scene()
