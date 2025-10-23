extends Area2D

signal player_entered(player)
signal player_exited(player)

func _on_KillZone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("player_entered", body)

func _on_KillZone_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("player_exited", body)
