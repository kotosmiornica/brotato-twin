extends Button

func _ready():
	print("Button ready")
	pressed.connect(_on_pressed)

func _on_pressed():
	$click.play()
	print("Button clicked!")

	var anim = get_node("/root/Control/Anime2")
	if anim:
		print("AnimationPlayer found!")
		anim.play("TransIn")
	else:
		print("Animation node not found!")
