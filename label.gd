
extends Label

@onready var restart_button = $RestartButton

func _ready():
	visible = false 

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func show_game_over():
	visible = true
