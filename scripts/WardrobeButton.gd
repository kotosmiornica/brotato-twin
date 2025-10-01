extends Button

func _ready():
	print("Button ready")
	pressed.connect(_on_pressed)

func _on_pressed():
	$click.play()
	print("Button clicked!")
