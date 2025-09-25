extends CharacterBody2D

var health = 100
var health_depleted 

# Cache the AnimatedSprite2D child for easy access
@onready var anim_sprite = $AnimatedSprite2D  # Make sure this path matches your scene tree

func _physics_process(_delta: float) -> void:	
	# Play the correct animation based on movement
	if velocity.length() > 0.0:
		anim_sprite.play("walk")
	else:
		anim_sprite.play("idle")

	# Damage logic
	const DAMAGE_RATE = 25.0
	var overlapping_mobs = $HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * _delta
		$ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
