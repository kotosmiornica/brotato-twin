extends Button



func _on_settings_pressed():
	$click.play()
	print("Button clicked!")

	var anim = get_node("/root/Control/SettingsMenu/Animations")
	if anim:
		print("AnimationPlayer found!")
		anim.play("FadeIn")
	else:
		print("Animation node not found!")
