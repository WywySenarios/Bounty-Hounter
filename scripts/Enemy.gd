extends KinematicBody2D

var maxSpeed = 2000
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var gravity = 400
var startDirection = Vector2.RIGHT

func _ready():
	direction = startDirection
	$HitboxArea.connect("area_entered", self, "on_hitbox_entered")
	
func _process(delta):
	if(is_on_wall()):
		direction *= -1
	
	velocity.x = (direction * maxSpeed).x * delta
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP) 
	$AnimatedSprite.flip_h = true if direction.x > 0 else false

func on_hitbox_entered(_area2d):
	$"/root/Helpers".apply_camera_shake(1)
	queue_free()
