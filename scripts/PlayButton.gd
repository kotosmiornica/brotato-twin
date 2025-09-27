extends Button


func _ready():
	pass

func _pressed() -> void:
	$click.play()
	get_tree().change_scene_to_file("res://scenes/survivors_game.tscn")

func _process(_delta: float) -> void:
	pass
