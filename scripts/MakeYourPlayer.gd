extends CharacterBody2D

@onready var anim_sprite = $Car
@onready var meow_player = $MeowPlayer
@onready var wig_node = $MikuWig
@onready var heart_node = $Heart

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.LEFT:
		if anim_sprite and _is_point_over_sprite(anim_sprite, event.position):
			play_meow()

func _is_point_over_sprite(sprite, global_point: Vector2) -> bool:
	var local_point = sprite.to_local(global_point)
	var rect = Rect2(Vector2.ZERO, sprite.frames.get_frame(sprite.animation, 0).get_size())
	return rect.has_point(local_point)

func play_meow() -> void:
	if meow_player and not meow_player.playing:
		meow_player.play()
	if anim_sprite:
		anim_sprite.play("meow_wiggle")

func buy_miku_wig() -> void:
	if wig_node:
		wig_node.visible = true
		var anims = wig_node.frames.get_animation_names()
		if anims.size() > 0:
			wig_node.animation = anims[0]
			wig_node.play()
		wig_node.z_index = 10

func buy_heart() -> void:
	if heart_node:
		heart_node.visible = true
		var anims = heart_node.frames.get_animation_names()
		if anims.size() > 0:
			heart_node.animation = anims[0]
			heart_node.play()
		heart_node.z_index = 10
