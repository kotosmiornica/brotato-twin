extends Sprite2D 

func on_food_arrived(food):

	if is_instance_valid(food):
		food.queue_free()


	get_parent().call_deferred("spawn_coins_for_food")
