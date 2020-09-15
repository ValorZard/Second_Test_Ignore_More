extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var bullet_speed := 100
var bullet_direction := Vector2(1, 0)
export var bullet_damage := 1
export var life_span := 300 #seconds
var node_this_belongs_to := KinematicBody2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	life_span -= delta
	var bullet_velocity := bullet_speed * bullet_direction
	if(life_span > 0):
		move_and_slide(bullet_velocity)
	else:
		#print(str(bullet_velocity))
		destroy()
	pass

func set_direction(direction):
	bullet_direction = direction

#when the bullet hits something
func on_hit(body):
	#self.queue_free()
	if body.is_in_group("Hittable"):
		body.on_hit(bullet_damage)
		pass
	destroy()
	pass

#destroy bullet
#might add animations or sounds or something later
func destroy():
	queue_free()
	pass

func _on_Area2D_body_entered(body):
	#print("works")
	if body.is_in_group("Collision") and (body != node_this_belongs_to):
		#print("AER")
		on_hit(body)
	pass # Replace with function body.


func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	#print("works")
	pass # Replace with function body.
