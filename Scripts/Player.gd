extends KinematicBody2D

class_name Player


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_name := ""

var x_input := 0.0
var y_input := 0.0
export var player_speed := 300.0
#export var dash_multiplier := 2.0
var is_dashing := false
#networked variables
puppet var player_velocity := Vector2()
puppet var player_position := Vector2()
puppet var facing_left := false

var gravity := 1200
var jump_force := 600
var air_jumps := 2 #number of air jumps
var air_jumps_left = air_jumps
var is_jumping := false

#enum Direction{UP, DOWN, LEFT, RIGHT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT}
#var current_direction = Direction.UP

#var player_angle := 0

var spawn_point := Vector2()

export var default_health = 10
export(int) onready var player_health = default_health

export var default_shield := 10
export(int) onready var shield_health := default_shield
var shield_pressed := false

puppet var is_shooting := false
puppet var shoot_direction := Vector2()
#var special_pressed := false

#var melee_pressed := false
var bullet_template = preload("res://Scenes/Bullet.tscn")
var bullet_exit_radius := 54.0
export var bullet_speed := 500.0
var fire_rate := 0.2
var time_left_till_next_bullet = fire_rate


# Called when the node enters the scene tree for the first time.
func _ready():
	set_shoot_rotation()
	set_player_name(player_name)
	player_position = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	set_movement(delta)
	set_camera()
	set_shoot_rotation()
	set_shoot_position()
	do_attack(delta)
	get_node("DebugLabel").text = to_string()
	pass

func get_input(delta):
	if is_network_master():
		x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		#y_input = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
		#check for facing direction
		if(x_input >= 0):
			facing_left = false
		else:
			facing_left = true
	
		shield_pressed = Input.is_action_pressed("shield")
		
		#networked variable
		is_shooting = Input.is_action_pressed("shoot")
		rset("is_shooting", is_shooting)
	
		is_jumping = Input.is_action_just_pressed("jump_pressed")
	pass

func jump(velocity):
	velocity.y = -jump_force
	is_jumping = false
	return velocity

func set_movement(delta):
	var velocity := Vector2()
	
	if is_network_master():
		velocity.x = player_speed * x_input
		velocity.y = player_velocity.y
	
		if(is_jumping and is_on_floor()):
			velocity = jump(velocity)
			print("normal_jump")
			print(str(velocity))
		elif(is_jumping and is_on_wall()):
			velocity = jump(velocity)
			print("wall_jump")
			print(str(velocity))
		elif(is_jumping and air_jumps_left > 0):
			velocity = jump(velocity)
			air_jumps_left -= 1
			print("air_jumps_left: " + str(air_jumps_left))
			print(str(velocity))
		elif(is_on_floor()):
			velocity.y = 0
			air_jumps_left = air_jumps
		elif(!is_on_floor()):
			velocity.y += gravity * delta
		
		rset("player_velocity", velocity)
		player_velocity = velocity # so i can save the data of this velocity to use elsewhere
		rset("player_position", position)
	else:
		position = player_position
		velocity = player_velocity
	
	#print("velocity: ", velocity)
	#print("player_velocity: ", player_velocity)
	
	move_and_slide(velocity, Vector2(0, -1)) #added a floor 
	
	if not is_network_master():
		player_position = position # To avoid jitter
	pass

#this is inefficent
func set_camera():
	if is_network_master():
		for player in get_parent().get_children():
			if(player == self):
				player.get_node("Camera2D").current = true
			else:
				player.get_node("Camera2D").current = false
			pass


func set_shoot_rotation():
	#current_shoot.rotation_degrees = rad2deg(player_angle)
	if is_network_master():
		var mouse_direction := get_position().direction_to(get_global_mouse_position()) # getting direction to mouse
		var bullet_angle := atan2(mouse_direction.y, mouse_direction.x)
		
		shoot_direction = Vector2(cos(bullet_angle), sin(bullet_angle))
		rset("shoot_direction", shoot_direction) #make sure that the other instances can see this
	pass

func set_shoot_position():
	get_node("BulletExit").position = shoot_direction * bullet_exit_radius + self.position

func do_attack(delta):
	time_left_till_next_bullet -= delta
	if(is_shooting and time_left_till_next_bullet <= 0):
		var bullet = bullet_template.instance()
		bullet.set_direction(shoot_direction)
		bullet.bullet_speed = bullet_speed
		bullet.position = get_node("BulletExit").position
		print(bullet.position)
		bullet.node_this_belongs_to = self
		get_tree().get_root().add_child(bullet)
		time_left_till_next_bullet = fire_rate
		pass
	pass

func on_hit(damage):
	if(shield_health > 0):
		shield_health -= damage
	elif (player_health > 0):
		player_health -= damage
	else:
		death()
	pass

func death():
	#RESPAWN
	shield_health = default_shield
	player_health = default_health
	position = spawn_point
	rset("player_position", position)
	pass

func set_player_name(new_name):
	player_name = new_name
	get_node("NameLabel").set_text(player_name)

func _to_string():
	var player_string := ""
	player_string += "Current State: "
	
	player_string += "\n"
	
	player_string += "Health:" + str(player_health) + "\n"
	
	player_string += "Shield: " + str(shield_pressed) + "\nShield Health: " + str(shield_health) + "\n"
	
	player_string += "Shooting: " + str(is_shooting) + "\n"
	
	player_string += "Shoot Direction" + str(shoot_direction) + "\n"

	return player_string
