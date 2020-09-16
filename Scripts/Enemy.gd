extends StaticBody2D

class_name Enemy


#var enemy_angle := 0

export var default_health := 10
export(int) var enemy_health := default_health

export var default_shield := 10
export(int) var shield_health := default_shield
var shield_pressed := false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Collision")
	self.add_to_group("Hittable")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass



func on_hit(damage):
	enemy_health -= damage
	if(shield_health > 0):
		shield_health -= damage
	elif(enemy_health > 0):
		enemy_health -= damage
	else:
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
