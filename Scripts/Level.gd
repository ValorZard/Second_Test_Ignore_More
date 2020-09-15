extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	check_hittable()
	pass # Replace with function body.

func check_hittable():
	for player in get_node("Players").get_children():
		player.add_to_group("Hittable")
	for enemy in get_node("Enemies").get_children():
		enemy.add_to_group("Hittable")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_hittable()
	pass
