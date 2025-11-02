extends Node

signal coins_changed(new_amount)
signal item_bought(item_name: String)


var coins = 0
var extra_gun_unlocked: bool = false
var caught_food_count: int = 0
var caught_foods: Array[String] = []
var owned_items = []
var food_counts := {}
var equipped_hair: String = ""
var equipped_accessory: String = ""
var score: int = 0
var waves_survived: int = 0

var unlocked_fishing_levels := 1
var bleach_level: int = 1
var active_buffs = {}




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
		"Cost": 10,
		"Currency": "BlackMonster"
	}
]


func reset_run_data():
	score = 0
	waves_survived = 0


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


func is_bleach_maxed() -> bool:
	return bleach_level >= 3


func upgrade_bleach():
	if not is_bleach_maxed():
		bleach_level = clamp(bleach_level + 1, 1, 3)
		print("Bleach upgraded! Level:", bleach_level)
	else:
		print("Bleach already maxed out!")


func mark_item_owned(item_name: String) -> void:
	if not owned_items.has(item_name):
		owned_items.append(item_name)
	for i in range(items.size()):
		if items[i]["Name"] == item_name:
			items[i]["Owned"] = true
			break
	emit_signal("item_bought", item_name)
