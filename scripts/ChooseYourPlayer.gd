extends CharacterBody2D

var health = 100
var health_depleted 

func _physics_process(_delta: float) -> void:	
	if velocity.length() > 0.0:
		%Sadboo.play_walk_animation()
	else:
		%SadBoo.play_idle_animation()

	const DAMAGE_RATE = 25.0

	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * _delta
		$ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
				
