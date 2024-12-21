extends CharacterBody2D

var enemyDeathScene = preload("res://scenes/EnemyDeath.tscn")
@export var isSpawning: bool = true

var maxSpeed = 2000
#var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var gravity = 400
var startDirection = Vector2.RIGHT


func _ready():
	direction = startDirection
	$HitboxArea.connect("area_entered", Callable(self, "on_hitbox_entered"))
	
func _process(delta):
	if(isSpawning):
		return 
	
	if(is_on_wall()):
		direction *= -1
	
	velocity.x = (direction * maxSpeed).x * delta
	velocity.y += gravity * delta
	
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	velocity = velocity 
	$Visuals/AnimatedSprite2D.flip_h = true if direction.x > 0 else false

func kill():
	var deathInstance = enemyDeathScene.instantiate()
	get_parent().add_child(deathInstance)
	deathInstance.global_position = global_position
	if(velocity.x > 0):
		deathInstance.scale = Vector2(-1, 1)
	queue_free()

func on_hitbox_entered(_area2d):
	$"/root/Helpers".apply_camera_shake(1)
	call_deferred("kill")
