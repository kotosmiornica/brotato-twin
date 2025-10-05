extends CanvasLayer




func _ready() -> void:
	pass

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioServer.set_bus_mute(1,  value < 0.01)





func _on_music_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)



func _on_sfx_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)
