extends Control

func _ready() -> void:

	$AnimationPlayer.play("RESET")
	hide_pause_menu()


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide_pause_menu()
	$CanvasLayer.visible = false


func pause():
	$CanvasLayer.visible = true
	get_tree().paused = true
	$CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # block input while fading
	$CanvasLayer/ColorRect/PanelContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$AnimationPlayer.play("blur")

func _input(event):
	if event.is_action_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_resume_pressed() -> void:
	resume()


func hide_pause_menu():
	visible = false
	$CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer/ColorRect/PanelContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer/ColorRect/PanelContainer/VBoxContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_pause_menu():
	visible = true
	$CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	$CanvasLayer/ColorRect/PanelContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	$CanvasLayer/ColorRect/PanelContainer/VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_AnimationPlayer_animation_finished(anim_name: StringName) -> void:
	if anim_name == "blur":
		# Animation finished → now allow input
		$CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
		$CanvasLayer/ColorRect/PanelContainer.mouse_filter = Control.MOUSE_FILTER_STOP
