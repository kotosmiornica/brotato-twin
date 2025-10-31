extends Control

func _ready() -> void:
	hide_pause_menu()


# -----------------------------
# Help functions
# -----------------------------
func set_menu_active(active: bool) -> void:
	%PauseMenu.visible = active
	var filter = Control.MOUSE_FILTER_STOP if active else Control.MOUSE_FILTER_IGNORE
	apply_mouse_filter_recursive(%PauseMenu, filter)


func apply_mouse_filter_recursive(control: Control, filter_value: int) -> void:
	control.mouse_filter = filter_value
	for child in control.get_children():
		if child is Control:
			apply_mouse_filter_recursive(child, filter_value)


# -----------------------------
# Show / Hide Menu
# -----------------------------
func show_pause_menu():
	set_menu_active(true)
	$CanvasLayer.visible = true
	$CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer/ColorRect/PanelContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$AnimationPlayer.play("blur")


func hide_pause_menu():
	set_menu_active(false)
	$CanvasLayer.visible = false
	$CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer/ColorRect/PanelContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE


# -----------------------------
# Pause / Resume
# -----------------------------
func pause():
	get_tree().paused = true
	show_pause_menu()


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide_pause_menu()


# -----------------------------
# Input handling

func _input(event):
	if event.is_action_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()


# -----------------------------
# Button signals

func _on_resume_pressed() -> void:
	$click.play()
	resume()


func _on_restart_pressed() -> void:
	$click.play()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_settings_pressed() -> void:
	$click.play()
	print("Button clicked!")

	var anim = get_node("/root/game/SettingsMenu/Animations")
	if anim:
		print("AnimationPlayer found!")
		anim.play("FadeIn")
	else:
		print("Animation node not found!")


#other
func _on_AnimationPlayer_animation_finished(anim_name: StringName) -> void:
	if anim_name == "blur":
		apply_mouse_filter_recursive($PauseMenu, Control.MOUSE_FILTER_STOP)


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	$CanvasLayer/ColorRect/PanelContainer/VBoxContainer/MainMenu/click.play()
	Global.reset_run_data()
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
