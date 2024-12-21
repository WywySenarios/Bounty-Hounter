extends CharacterBody2D

#var velocity = Vector2.ZERO
var gravity = 1000

func _ready():
	if(velocity.x > 0):
		$Visuals.scale = Vector2(-1, 1)

func _process(delta):
	var velocity_y_i = velocity.y
	
	if(is_on_floor()):
		velocity.lerp(velocity, pow(2, -1 * delta))
	
	velocity.y = velocity_y_i + gravity * delta
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	velocity = velocity
	
	#if(is_on_floor()):
		#velocity.x = lerp(0, velocity.x, pow(2, -1 * delta))
