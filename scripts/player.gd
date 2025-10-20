extends CharacterBody2D

signal health_depleted
signal leveled_up

@export var move_speed: float = 400.0
@export var throw_force: float = 600.0
@export var soda_cooldown: float = 10.0
@export var cooldown: float = 4.0

@onready var happy_boo = $HappyBoo
@onready var weapons_container = get_tree().get_first_node_in_group("Weapons")
@onready var progress_bar = %ProgressBar
@onready var extra_gun = %YOUSHOOT
@onready var stain_scene = preload("res://scenes/BleachStain.tscn")
@onready var cutter_scene = preload("res://scenes/pizzacutter.tscn")

# Added FightingText preload
var FT_Script = preload("res://scripts/FightingText.gd")

var health: float = 180.0
var xp: int = 0
var level: int = 1
var xp_per_level: int = 10
var xp_growth_factor: float = 1.4
var can_throw_soda: bool = true
var current_weapon: String = "gun"
var equipped_weapons: Array[String] = []
var cutters: Array = []
var _stain_timer: float = 0.0
var _throw_timer: float = 0.0
var level_up_menu: Node = null

const MAX_CUTTERS: int = 4

const WEAPON_SCENES = {
	"gun": preload("res://scenes/gun.tscn"),
	"soda1": preload("res://scenes/SodaCan.tscn"),
	"bleach3": preload("res://scenes/bleach.tscn"),
	"pizzacutter2": preload("res://scenes/pizzacutter.tscn")
}

func _ready():
	add_to_group("player")
	apply_equipped_hair()
	apply_equipped_accessories()
	if Global.extra_gun_unlocked:
		extra_gun.visible = true
		extra_gun.unlocked = true
	else:
		extra_gun.visible = false
		extra_gun.unlocked = false

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_damage(delta)

func handle_movement() -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

	if direction != Vector2.ZERO:
		happy_boo.play_walk_animation()
	else:
		happy_boo.play_idle_animation()

func handle_damage(delta: float) -> void:
	var overlapping = %HurtBox.get_overlapping_bodies()
	if overlapping.size() > 0:
		apply_damage(25.0 * overlapping.size() * delta)

func apply_damage(amount: float) -> void:
	health = max(health - amount, 0)
	progress_bar.value = health

	if health <= 0:
		die()


func die() -> void:
	emit_signal("health_depleted")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _process(delta: float) -> void:
	if "bleach3" not in equipped_weapons:
		_stain_timer = 0.0
	else:
		_stain_timer += delta
		if _stain_timer >= cooldown:
			_stain_timer = 0.0
			spawn_stain()

	if "soda1" in equipped_weapons and Input.is_action_just_pressed("throw") and can_throw_soda:
		throw_soda()

func spawn_stain() -> void:
	if stain_scene == null:
		return
	var stain = stain_scene.instantiate()
	stain.global_position = global_position
	get_parent().add_child(stain)

func throw_soda() -> void:
	if not can_throw_soda or "soda1" not in equipped_weapons:
		return
	can_throw_soda = false

	var soda_scene = WEAPON_SCENES["soda1"]
	var soda = soda_scene.instantiate() as Area2D
	soda.global_position = global_position
	soda.player = self

	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	soda.direction = dir

	get_tree().current_scene.add_child(soda)

	await get_tree().create_timer(soda_cooldown).timeout
	can_throw_soda = true

func add_cutter(scene: PackedScene):
	if cutters.size() >= MAX_CUTTERS:
		return
	var cutter = scene.instantiate()
	cutter.player = self
	add_child(cutter)
	cutters.append(cutter)
	update_cutter_angles()

func remove_cutter(cutter):
	cutters.erase(cutter)
	cutter.queue_free()
	update_cutter_angles()

func update_cutter_angles():
	var n = cutters.size()
	if n == 0:
		return
	for i in range(n):
		cutters[i].rotation = (TAU / n) * i
		cutters[i].angle_offset = (360.0 / n) * i

func _on_xp_collected(amount: int = 1):
	xp += amount
	_show_floating_text("+" + str(amount) + " XP", global_position, Color(1,1,0,1))
	emit_signal("xp_collected", amount)  # let game script handle level up
	update_xp_bar()


func update_xp_bar():
	var xp_bar = get_node_or_null("../Bar/XPbar")
	if xp_bar:
		xp_bar.value = xp
		xp_bar.max_value = xp_per_level



func _on_weapon_chosen(weapon_id: String):
	if weapon_id == "pizzacutter2" and cutters.size() >= MAX_CUTTERS:
		if level_up_menu:
			level_up_menu.queue_free()
			level_up_menu = null
		get_tree().paused = false
		return

	if weapon_id not in equipped_weapons:
		equipped_weapons.append(weapon_id)

	give_weapon(weapon_id)

	if level_up_menu:
		level_up_menu.queue_free()
		level_up_menu = null

	get_tree().paused = false

func give_weapon(weapon_id: String):
	if not WEAPON_SCENES.has(weapon_id):
		push_warning("Unknown weapon: %s" % weapon_id)
		return

	var weapon_scene = WEAPON_SCENES[weapon_id]

	if weapon_id == "pizzacutter2":
		add_cutter(weapon_scene)
		return

	var weapon = weapon_scene.instantiate()
	weapon.player = self
	weapons_container.add_child(weapon)

func unlock_extra_gun():
	extra_gun.visible = true
	extra_gun.unlocked = true
	Global.extra_gun_unlocked = true

func heal(amount: int) -> void:
	health = min(health + amount, 180)
	progress_bar.value = health
	print("Healed by %d! Current HP: %d" % [amount, health])


func _show_floating_text(text: String, pos: Vector2, color: Color = Color(1,1,0,1)):
	var popup = FT_Script.new()
	popup.show_text(text, pos, color)
	get_tree().current_scene.add_child(popup)


func apply_equipped_item(node_list: Array[String], equipped_name: String, z: int):
	for n in node_list:
		var node = happy_boo.get_node_or_null(n)
		if node:
			node.visible = (n == equipped_name)
			if n == equipped_name:
				node.z_index = z

func apply_equipped_hair():
	apply_equipped_item(["BlueWig"], Global.equipped_hair, 10)

func apply_equipped_accessories():
	apply_equipped_item(["Heart"], Global.equipped_accessory, 11)
