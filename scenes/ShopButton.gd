extends Button

func _ready():
	print("Button ready")
	pressed.connect(_on_pressed)

func _on_pressed():
	print("Button clicked!")

	var anim = get_node("../ColorRect/Shop/Anim")
	if anim:
		print("AnimationPlayer found!")
		anim.play("TransIn")
	else:
		print("Animation node not found!")

func _on_shop_button_pressed():
	var anim = get_node("../ColorRect/Shop/Anim")
	if anim:
		anim.play("TransIn")
	else:
		print("Animation node not found!")
