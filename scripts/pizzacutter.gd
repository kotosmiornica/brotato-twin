extends Area2D

@export var spin_speed: float = 100
@export var orbit_radius: float = 25
@export var orbit_speed: float = 70
@export var damage: int = 2
@export var damage_multiplier: float = 0.5

var orbit_angle: float = 0
var angle_offset: float = 0
var player: Node = null

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	if not player:
		return

	orbit_angle += deg_to_rad(orbit_speed) * delta
	var rad = orbit_angle + deg_to_rad(angle_offset)
	global_position = player.global_position + Vector2(orbit_radius, 0).rotated(rad)


	rotation += deg_to_rad(spin_speed) * delta

func _on_body_entered(body):
	if body.has_method("take_damage") and player:
		body.take_damage(player.damage * damage_multiplier)
