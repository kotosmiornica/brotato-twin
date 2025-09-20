extends Button


func _ready():
	pass

func _pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/survivors_game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
