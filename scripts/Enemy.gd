extends KinematicBody2D

var maxSpeed = 2000
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT
var gravity = 400


func _process(delta):
	if(is_on_wall()):
		direction *= -1
	velocity.x = (direction * maxSpeed).x * delta
	
	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP) 

	$AnimatedSprite.flip_h = true if direction.x > 0 else false
