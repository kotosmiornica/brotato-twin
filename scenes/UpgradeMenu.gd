extends Control

signal upgrade_selected(upgrade_name: String)


func _ready() -> void:
	visible = false 
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_filter = MOUSE_FILTER_IGNORE

func _on_damage_pressed() -> void:
	print("Damage button pressed!")
	emit_signal("upgrade_selected", "damage")


func _on_movementspeed_pressed() -> void:
	print("Speed button pressed!")
	emit_signal("upgrade_selected", "movement speed")


func _on_health_pressed() -> void:
	print("Health button pressed!")
	emit_signal("upgrade_selected", "health")
