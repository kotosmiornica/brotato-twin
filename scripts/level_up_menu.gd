extends Control

signal weapon_chosen(weapon_id)

@onready var pizza_button = $CanvasLayer/Panel/pizzacutter2
@onready var bleach_button = $CanvasLayer/Panel/bleach3
@onready var bleach_desc = $CanvasLayer/Panel/bleach3/des3

func _ready():
	if Global.is_bleach_maxed():
		_hide_bleach_option()
	else:
		bleach_button.connect("pressed", Callable(self, "_on_weapon_button_pressed").bind("bleach3"))
	
	pizza_button.connect("pressed", Callable(self, "_on_weapon_button_pressed").bind("pizzacutter2"))


func _on_weapon_button_pressed(weapon_id):
	if weapon_id == "bleach3":
		Global.upgrade_bleach()
		if Global.is_bleach_maxed():
			_hide_bleach_option()

	emit_signal("weapon_chosen", weapon_id)
	queue_free()


func _hide_bleach_option():
	if bleach_button:
		bleach_button.hide()
	if bleach_desc:
		bleach_desc.hide()
