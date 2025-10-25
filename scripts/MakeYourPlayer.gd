extends CharacterBody2D

@onready var anim_sprite = $Car
@onready var meow_player = $MeowPlayer
@onready var wig_node = $BlueWig
@onready var heart_node = $Heart

func _ready() -> void:
	set_process_input(true)



func _is_point_over_sprite(sprite, global_point: Vector2) -> bool:
	var local_point = sprite.to_local(global_point)
	var rect = Rect2(Vector2.ZERO, sprite.frames.get_frame(sprite.animation, 0).get_size())
	return rect.has_point(local_point)

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



#func _on_ClickArea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
#	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
#		play_meow()

func play_meow() -> void:
	if not meow_player.playing:
		meow_player.play()
