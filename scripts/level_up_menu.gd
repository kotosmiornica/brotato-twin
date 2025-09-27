extends Control

signal weapon_chosen(weapon_id)

func _ready():
	$CanvasLayer/Panel/soda1.connect("pressed", Callable(self, "_on_weapon_button_pressed").bind("soda1"))
	$CanvasLayer/Panel/pizzacutter2.connect("pressed", Callable(self, "_on_weapon_button_pressed").bind("pizzacutter2"))
	$CanvasLayer/Panel/bleach3.connect("pressed", Callable(self, "_on_weapon_button_pressed").bind("bleach3"))


func _on_weapon_button_pressed(weapon_id):
	emit_signal("weapon_chosen", weapon_id)
	queue_free()
