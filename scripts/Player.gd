extends KinematicBody2D

signal died

var gravity = 1000
var velocity = Vector2.ZERO
var maxRunSpeed = 400
var runAcceleration = 600
var maxWalkSpeed = 200
var xAcceleration = 800
var jumpSpeed = 340
var jumpEndMultiplier = 5
var apexTweak = 5
var hasDoubleJump = false

var left = "ui_left"
var right = "ui_right"
var jump = "ui_jump"
var down = "ui_down"

func _ready():
	$HitboxArea.connect("area_entered", self, "on_hazard_area_entered")

func _process(delta):
	var inputVector = get_input_vector()
	
	if(inputVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -20*delta))
	
	velocity.x = clamp(velocity.x, -maxWalkSpeed, maxWalkSpeed)
	
	if (inputVector.y < 0 && (is_on_floor() && !$BufferTimer.is_stopped() || !$CoyoteTimer.is_stopped() || hasDoubleJump)):
		$BufferTimer.stop()
		velocity.y = inputVector.y * jumpSpeed
		if(!is_on_floor() && $CoyoteTimer.is_stopped()):
			hasDoubleJump = false
		$CoyoteTimer.stop()
	
	if (velocity.y < 0 && !Input.is_action_pressed(jump)):
		velocity.y += gravity * jumpEndMultiplier * delta
		inputVector.x *= apexTweak
		velocity.x *= 1.05
	else:
		velocity.y += gravity * delta
		
	velocity.x += inputVector.x * xAcceleration * delta
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)

	if(!is_on_floor()):
		call_deferred("disable_floor_hitbox")
		if(wasOnFloor):
			$CoyoteTimer.start()
	else:
		hasDoubleJump = true
		if(velocity.y == 0):
			call_deferred("disable_floor_hitbox")
		
	update_animation()


func get_input_vector():
	var inputVector = Vector2.ZERO
	inputVector.x = Input.get_action_strength(right) - Input.get_action_strength(left);
	inputVector.y = -1 if Input.is_action_just_pressed(jump) else 0
	if(inputVector.y < 0):
		$BufferTimer.start()
	return inputVector

func update_animation():
	var inputVec = get_input_vector()
	
	if(!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif(inputVec.x != 0):
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")
	
	if(inputVec.x != 0):
		$AnimatedSprite.flip_h = true if inputVec.x > 0 else false

func on_hazard_area_entered(area2d):
	emit_signal("died")

func disable_floor_hitbox():
	$FloorCollisionShape2D.disabled = true

func enable_floor_hitbox():
	$FloorCollisionShape2D.disabled = false
