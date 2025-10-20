extends CharacterBody2D

signal health_depleted

@export var soda_cooldown: float = 10.0
@export var throw_force: float = 600.0
@export var cooldown: float = 4.0
@onready var weapons_container = get_node("/root/game/Brotat/Weapons")
@onready var extra_gun = %YOUSHOOT

var health = 180.0
var orbit_angle: float = 0.0
var xp: int = 0
var level: int = 1
var xp_per_level: int = 10
var can_throw_soda: bool = true
var current_weapon: String = "gun"
var weapons: Array = []
var stain_scene = preload("res://scenes/BleachStain.tscn")
var equipped_weapons = []  
var _time_passed: float = 0.0
var cutter_scene = preload("res://scenes/pizzacutter.tscn")
var level_up_menu = null
var pizza_cutters: Array = []
var can_throw: bool = true
var throw_cooldown: float = 10.0
var xp_growth_factor = 1.4
var extra_gun_unlocked: bool = false
var cutters: Array = []


const MAX_PIZZA_CUTTERS = 4



# -------------------------
#  HAIR HANDLING
# -------------------------
func apply_equipped_hair():
	var possible_hairs = ["BlueWig"]  # only BlueWig for now

	# hide all possible hairs
	for hair_id in possible_hairs:
		var n = $HappyBoo.get_node_or_null(NodePath(hair_id))
		if n:
			n.visible = false

	var hair_name = Global.equipped_hair
	if hair_name == null or hair_name == "":
		return

	var hair_node = $HappyBoo.get_node_or_null(NodePath(hair_name))
	if not hair_node:
		hair_node = get_node_or_null(NodePath(hair_name))
		if hair_node:
			hair_node.get_parent().remove_child(hair_node)
			$HappyBoo.add_child(hair_node)

	if hair_node:
		hair_node.position = Vector2.ZERO
		hair_node.visible = true
		hair_node.z_index = 10

# -------------------------
#  ACCESSORY HANDLING
# -------------------------
func apply_equipped_accessories():
	var possible_accessories = ["Heart"]

	# hide all possible accessories
	for acc_id in possible_accessories:
		var n = $HappyBoo.get_node_or_null(NodePath(acc_id))
		if n:
			n.visible = false

	var accessory_name = Global.equipped_accessory
	if accessory_name == null or accessory_name == "":
		return

	var acc_node = $HappyBoo.get_node_or_null(NodePath(accessory_name))
	if not acc_node:
		acc_node = get_node_or_null(NodePath(accessory_name))
		if acc_node:
			acc_node.get_parent().remove_child(acc_node)
			$HappyBoo.add_child(acc_node)

	if acc_node:
		acc_node.position = Vector2.ZERO
		acc_node.visible = true
		acc_node.z_index = 11

func _physics_process(_delta: float) -> void:
	#print("Player:", position, "| BlueWig:", %BlueWig.global_position)
	#if %BlueWig:
	#	print("BlueWig's parent:", %BlueWig.get_parent())

	var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = direction * 400
	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()

	const DAMAGE_RATE = 25.0

	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * _delta
		$ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
				


func add_cutter(cutter_scene):
	var cutter = cutter_scene.instantiate()
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




func unlock_extra_gun():
	extra_gun.visible = true
	extra_gun.unlocked = true
	Global.extra_gun_unlocked = true


func _on_xp_collected():
	xp += 1
	print("Collected XP. Current: %d" % xp)
	update_xp_bar()

	if xp >= xp_per_level:
		xp -= xp_per_level
		level_up()

func level_up():
	get_tree().paused = true

	# Increase XP needed for next level
	xp_per_level = int(xp_per_level * xp_growth_factor)

	var LevelUpMenuScene = preload("res://scenes/level_up_menu.tscn")
	level_up_menu = LevelUpMenuScene.instantiate()
	get_tree().current_scene.add_child(level_up_menu)

	level_up_menu.connect("weapon_chosen", Callable(self, "_on_weapon_chosen"))


func upgrade_weapon(weapon_id):
	current_weapon = weapon_id
	print("Equipped weapon:", weapon_id)

func update_xp_bar():
	var xp_bar = get_node("../Bar/XPbar")  
	xp_bar.value = xp
	xp_bar.max_value = xp_per_level




func _process(delta: float) -> void:
	
	_time_passed += delta
	if _time_passed >= cooldown:
		_time_passed = 0
		spawn_stain()
		
	var has_bleach = false
	for w in equipped_weapons:
		if w == "bleach3":
			has_bleach = true
			break

	if not has_bleach:
		_time_passed = 0  
		return


	_time_passed += delta
	if _time_passed >= cooldown:
		_time_passed = 0
		spawn_stain()
	if "soda1" in equipped_weapons and Input.is_action_just_pressed("throw") and can_throw_soda:
		throw_soda()



func spawn_stain() -> void:
	if stain_scene == null:
		push_error("stain_scene not assigned in Inspector!")
		return

	var stain = stain_scene.instantiate()
	stain.global_position = global_position  
	get_parent().add_child(stain)     


func _on_weapon_chosen(weapon_id):
	print("Player chose:", weapon_id)


	if weapon_id == "pizzacutter2" and pizza_cutters.size() >= MAX_PIZZA_CUTTERS:
		print("Pizza cutter maxed! Next menu will show bleach instead.")
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

func give_weapon(weapon_id):
	var weapon_scene: PackedScene

	match weapon_id:
		"soda1":
			weapon_scene = preload("res://scenes/SodaCan.tscn")
		"pizzacutter2":
			weapon_scene = preload("res://scenes/pizzacutter.tscn")
			add_cutter(weapon_scene)
			return
		"gun":
			weapon_scene = preload("res://scenes/gun.tscn")
		"bleach3":
			weapon_scene = preload("res://scenes/bleach.tscn")
		_:
			print("Unknown weapon:", weapon_id)
			return
			
	var weapon = weapon_scene.instantiate()
	weapon.player = self
	weapons_container.add_child(weapon)



	#if weapon_id == "pizzacutter2":
		#
		#if pizza_cutters.size() >= MAX_PIZZA_CUTTERS:
			#print("Max pizza cutters reached!")
			#weapon.queue_free()
			#return

		#pizza_cutters.append(weapon)
	
		#_update_pizza_cutters()



func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if "soda1" in equipped_weapons:
			spawn_soda(event.position)


func spawn_soda(mouse_pos: Vector2) -> void:
	var soda_scene = preload("res://scenes/SodaCan.tscn")
	var soda = soda_scene.instantiate() as Area2D
	soda.global_position = mouse_pos
	get_tree().current_scene.add_child(soda)


func throw_soda() -> void:
	if not can_throw_soda or "soda1" not in equipped_weapons:
		return

	can_throw_soda = false

	var soda_scene = preload("res://scenes/SodaCan.tscn")
	var soda = soda_scene.instantiate() as Area2D
	soda.global_position = global_position
	soda.player = self

	var mouse_pos = get_viewport().get_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	soda.direction = dir

	get_tree().current_scene.add_child(soda)


	await get_tree().create_timer(soda_cooldown).timeout
	can_throw_soda = true


func _update_pizza_cutters():
	var count = pizza_cutters.size()
	for i in range(count):
		pizza_cutters[i].angle_offset = TAU / count * i

func show_weapon_menu():
	var menu_scene = preload("res://scenes/level_up_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	level_up_menu = menu

	menu.connect("weapon_chosen", Callable(self, "_on_weapon_chosen"))
	get_tree().paused = true


	var stain = stain_scene.instantiate() 
	stain.global_position = global_position 
	get_parent().add_child(stain)


func apply_accessories():
	for accessory_id in Global.owned_items:
		equip_accessory(accessory_id)

func equip_accessory(accessory_id):
	match accessory_id:
		"BlueWig":
			%BlueWig.visible = true
		"Heart":
			%Heart.visible = true


func heal(amount: int) -> void:
	health = min(health + amount, 180)
	%ProgressBar.value = health
	print("Healed by %d! Current HP: %d" % [amount, health])
