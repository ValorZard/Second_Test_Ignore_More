extends StaticBody2D

class_name Enemy


#var enemy_angle := 0
var score_worth := 1

export var default_health := 10
export(int) var enemy_health := default_health

export var default_shield := 10
export(int) var shield_health := default_shield
var shield_pressed := false

puppet var who_is_attacking

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Collision")
	self.add_to_group("Hittable")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func set_attacking(player_responsible):
	# this is so that the last person who hits the player gets the kill
	who_is_attacking = player_responsible
	pass


func on_hit(damage):
	enemy_health -= damage
	if(shield_health > 0):
		shield_health -= damage
	elif(enemy_health > 0):
		enemy_health -= damage
	else:
		who_is_attacking.add_to_score(score_worth)
		death()
	pass

func death():
	queue_free()
	pass

func _to_string():
	var enemy_string := ""
	
	enemy_string += "Health:" + str(enemy_health) + "\n"
	
	enemy_string += "Shield: " + str(shield_pressed) + "\nShield Health: " + str(shield_health) + "\n"
	
	return enemy_string
