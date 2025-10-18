extends Button



func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
