extends CanvasLayer



func _ready() -> void:
	pass


func _on_master_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)


func _on_music_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)



func _on_sfx_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Sfx")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)


func _on_bullets_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Bullets")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)


func _on_closing_pressed() -> void:
	$click.play()
	print("Button clicked!")
	var anim = get_node("/root/Control/SettingsMenu/Animations")	
	if anim:
		print("AnimationPlayer found!")
		anim.play("FadeOut")
	else:
		print("Animation not found")
