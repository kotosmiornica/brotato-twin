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
	var level = PlayerData.unlocked_fishing_levels

	var scene_path = ""
	match level:
		1:
			scene_path = "res://scenes/Fishin.tscn"
		2:
			scene_path = "res://scenes/Fishin2.tscn"
		3:
			scene_path = "res://scenes/Fishin3.tscn"

	get_tree().change_scene_to_file(scene_path)


func _process(_delta: float) -> void:
	pass
