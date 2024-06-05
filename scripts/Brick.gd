extends CharacterBody2D

var direction = Vector2.ZERO
@export var maxSpeed = 2000
@export var startDirection = Vector2.UP

func _ready():
	#velocity = Vector2.ZERO
	direction = startDirection
	
func _process(delta):
	if(is_on_wall()):
		direction *= -1
	
	velocity.y = (direction * maxSpeed).y * delta
	
	set_velocity(Vector2.ZERO)
	set_up_direction(velocity)
	move_and_slide()
	velocity = velocity 
	$AnimatedSprite2D.flip_v = true if direction.y > 0 else false
