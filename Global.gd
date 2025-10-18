extends Node

var coins = 0
var extra_gun_unlocked: bool = false
signal coins_changed(new_amount)
var caught_food_count:int = 0
var caught_foods: Array[String] = []
var owned_items = [] 
var food_counts := {}
var equipped_hair: String = ""
var equipped_accessory: String = ""

var unlocked_fishing_levels := 1
var bleach_level: int = 1
var active_buffs = {}

func add_coins(amount):
	coins += amount
	emit_signal("coins_changed", coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		emit_signal("coins_changed", coins)
		return true
	return false

func unlock_extra_gun():
	extra_gun_unlocked = true
	print("Extra gun unlocked!")

func activate_temp_buff(buff_type: String, multiplier: float, duration: float):
	var now = Time.get_unix_time_from_system()
	active_buffs[buff_type] = {
		"multiplier": multiplier,
		"end_time": now + duration
	}
	print("Activated buff:", buff_type, "for", duration, "seconds!")

func get_buff_multiplier(buff_type: String) -> float:
	if not active_buffs.has(buff_type):
		return 1.0
	var buff = active_buffs[buff_type]
	var now = Time.get_unix_time_from_system()
	if now > buff["end_time"]:
		active_buffs.erase(buff_type)
		return 1.0
	return buff["multiplier"]

var items = [
	{
		"Name": "BlueWig",
		"Des": "Suddenly you want to sing at 750BPM.",
		"Cost": 20,
		"Currency": "Leek"
	},
	{
		"Name": "Heart",
		"Des": "Equipping this fills you with determination.",
		"Cost": 20,
		"Currency": "ToyKnife"
	},
	{
		"Name": "EmotionalWig",
		"Des": "Such deeply EMOtional hairstyle (wip).",
		"Cost": 25,
		"Currency": "BlackMonster"
	}
]
