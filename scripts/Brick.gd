extends KinematicBody2D

var velocity = Vector2.ZERO
var direction = Vector2.ZERO
export (int) var maxSpeed = 2000
export (Vector2) var startDirection = Vector2.UP

func _ready():
	direction = startDirection
	
func _process(delta):
	if(is_on_wall()):
		direction *= -1
	
	velocity.y = (direction * maxSpeed).y * delta
	
	velocity = move_and_slide(Vector2.ZERO, velocity) 
	$AnimatedSprite.flip_v = true if direction.y > 0 else false
