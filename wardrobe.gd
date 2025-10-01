extends Control

@onready var player_preview = $PlayerPreview  # Node2D/AnimatedSprite showing the character

func _ready():
	# Initialize the preview with currently equipped items
	update_preview()

# Call when a hair button is clicked
func _on_HairButton_1_pressed():
	PlayerData.equipped_hair = "BlueWig"
	update_preview()

func _on_HairButton_2_pressed():
	PlayerData.equipped_hair = "RedWig"
	update_preview()

func _on_HeartButton_pressed():
	if "Heart" in PlayerData.owned_items:
		PlayerData.equipped_accessory = "Heart"
		update_preview()
