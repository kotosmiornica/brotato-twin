extends Control




func _ready() -> void:
	pass

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioServer.set_bus_mute(1,  value < 0.01)


func _on_close_pressed() -> void:
	print("Button clicked!")

	var anim = get_node("/root/Settings/Volume")
	if anim:
		print("AnimationPlayer found!")
		anim.play("FadeOut")
	else:
		print("Animation not found")
		
