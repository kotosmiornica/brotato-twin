extends Control


func _ready() -> void:
	$text_score.text = "Score: %d" % Global.score
	$text_waves.text = "Waves Survived: %d" % Global.waves_survived



func _on_main_menu_button_pressed() -> void:
	Global.reset_run_data()
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
