extends Button


func _ready():
	$bubbles.finished.connect(_on_bubbles_finished)

func _pressed() -> void:
	$bubbles.play()
	var anim = get_node("/root/Control/FishButton/FishingStarts")
	if anim:
		$Fading.visible = true

		anim.play("Fade")
	else:
		print("Animation node not found!")


func _on_bubbles_finished():
	get_tree().change_scene_to_file("res://scenes/Fishin.tscn")


func _process(_delta: float) -> void:
	pass
