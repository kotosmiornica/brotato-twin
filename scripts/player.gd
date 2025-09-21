extends CharacterBody2D

signal health_depleted


var health = 150.0
var orbit_angle: float = 0.0
var xp: int = 0
var level: int = 1
var xp_per_level: int = 10

var current_weapon: String = "gun"
var weapons: Array = []
@onready var weapons_container = get_node("/root/game/Brotat/Weapons")
var stain_scene = preload("res://scenes/BleachStain.tscn")
var equipped_weapons = []  

var _time_passed: float = 0.0
var cutter_scene = preload("res://scenes/pizzacutter.tscn")

var level_up_menu = null
var pizza_cutters: Array = []
const MAX_PIZZA_CUTTERS = 4


func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = direction * 600
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
				

var cutters: Array = []

func add_cutter(cutter_scene: PackedScene):
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
	pass 

func _on_xp_collected():
	xp += 1
	print("Collected XP. Current: %d" % xp)
	update_xp_bar()

	if xp >= xp_per_level:
		xp -= xp_per_level
		level_up()

func level_up():
	get_tree().paused = true

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


@export var cooldown: float = 4.0


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
			weapon_scene = preload("res://scenes/soda.tscn")
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
