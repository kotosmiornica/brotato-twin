extends Button



func _pressed() -> void:
	$click.play()
	print("Button clicked!")
	var anim = get_node("/root/Control/SettingsMenu/Animations")	
	if anim:
		print("AnimationPlayer found!")
		anim.play("FadeOut")
	else:
		print("Animation not found")
