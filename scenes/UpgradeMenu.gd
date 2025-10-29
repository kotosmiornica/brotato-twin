extends Control

signal upgrade_selected(upgrade_name: String)

func _ready():
	print("Upgrade menu ready")
	$CanvasLayer/Panel/health.pressed.connect(_on_health_pressed)
	$CanvasLayer/Panel/damage.pressed.connect(_on_damage_pressed)
	$CanvasLayer/Panel/movementspeed.pressed.connect(_on_movementspeed_pressed)

func _on_damage_pressed() -> void:
	print("Damage button pressed!")
	emit_signal("upgrade_selected", "damage")


func _on_movementspeed_pressed() -> void:
	print("Speed button pressed!")
	emit_signal("upgrade_selected", "movement speed")


func _on_health_pressed() -> void:
	print("Health button pressed!")
	emit_signal("upgrade_selected", "health")
