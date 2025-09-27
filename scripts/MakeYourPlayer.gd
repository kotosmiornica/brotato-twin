extends CharacterBody2D

var health = 100
var health_depleted 


@onready var anim_sprite = $Car

func _physics_process(_delta: float) -> void:	
	if velocity.length() > 0.0:
		anim_sprite.play("walk")
	else:
		anim_sprite.play("idle")


	const DAMAGE_RATE = 25.0
	var overlapping_mobs = $HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * _delta
		$ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")


func buy_miku_wig() -> void:
	var wig_node = $MikuWig
	if wig_node:
		wig_node.visible = true
		if wig_node.has_method("play") and wig_node.animation_names.size() > 0:
			wig_node.animation = wig_node.animation_names[0]
			wig_node.play()
		wig_node.z_index = 10
		print("Miku wig activated!")
	else:
		print("MikuWig node not found!")


func buy_heart() -> void:
	var heart_node = $Heart
	if heart_node:
		heart_node.visible = true
		if heart_node.has_method("play") and heart_node.animation_names.size() > 0:
			heart_node.animation = heart_node.animation_names[0]
			heart_node.play()
		heart_node.z_index = 10
		print("Heart activated!")
	else:
		print("Heart not found!")
