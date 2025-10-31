extends Control

var player_score = Global.score * 50

func _ready() -> void:
	$text_score.text = "Score: %d" % player_score
	$text_waves.text = "Waves Survived: %d" % Global.waves_survived
	$SadAmbient.play()


func _on_main_menu_button_pressed() -> void:
	$MainMenuButton/click.play()
	Global.reset_run_data()
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	


func _on_retry_pressed() -> void:
	$Retry/click.play()
	Global.reset_run_data()
	get_tree().change_scene_to_file("res://scenes/survivors_game.tscn")
