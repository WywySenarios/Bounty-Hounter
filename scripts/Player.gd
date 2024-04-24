extends KinematicBody2D

signal died

var playerDeathScene = preload("res://scenes/PlayerDeath.tscn")

enum State { NORMAL, DASHING }

export(int, LAYERS_2D_PHYSICS) var dashHazardMask

# we can put the variables in a seperate file but it's a bit complicated so do it later
var left = "ui_left"
var right = "ui_right"
var jump = "ui_jump"
var jump2 = "ui_jump2"
var down = "ui_down"

var gravity = 1000
var velocity = Vector2.ZERO
var maxRunSpeed = 400
var runAcceleration = 600
var maxWalkSpeed = 200
var minDashSpeed = 200
var maxDashSpeed = 650
var xAcceleration = 800
var jumpSpeed = 330
var jumpEndMultiplier = 5
var apexTweak = 5
var hasDoubleJump = false
var currentState = State.NORMAL
var isStateNew = true

var defaultHazardMask = 0


func _ready():
	$HitboxArea.connect("area_entered", self, "on_hazard_area_entered")
	defaultHazardMask = $HitboxArea.collision_mask

func _process(delta):
	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
	isStateNew = false

func change_state(newState):
	currentState = newState
	isStateNew = true

func process_normal(delta):
	if(isStateNew):
		$DashArea/CollisionShape2D.disabled = true
		$HitboxArea.collision_mask = defaultHazardMask
	
	var inputVector = get_input_vector()
	
	if(inputVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -20*delta))
	
	velocity.x = clamp(velocity.x, -maxWalkSpeed, maxWalkSpeed)
	
	# this is braindead mode jump thing
	# !!! UNCOMMENT IN CASE OF EMERGENCY !!!
	#if(!$SuperBufferTimer.is_stopped() && is_on_floor()):
	#	$SuperBufferTimer.stop()
	#	velocity.y = -1.1*jumpSpeed
	
	if(!$MiniTimer.is_stopped() && is_on_floor()):
		$MiniTimer.stop()
		velocity.y = -1*jumpSpeed
		$"/root/Helpers".apply_camera_shake(0.5)
	
	if (inputVector.y < 0):
		if(!$CoyoteTimer.is_stopped()):
			$CoyoteTimer.stop()
			velocity.y = inputVector.y * jumpSpeed
			$"/root/Helpers".apply_camera_shake(0.2)
			
		elif(hasDoubleJump && !is_on_floor()):
			hasDoubleJump = false
			$SuperTimer.start()
			$MiniTimer.start()
			velocity.y += gravity * 1.5 * jumpEndMultiplier * delta
			inputVector.x *= apexTweak
			velocity.x *= 1.05
			$"/root/Helpers".apply_camera_shake(1)
		elif(is_on_floor()):
			if(!$SuperTimer.is_stopped()):
				$SuperTimer.stop()
				velocity.y = inputVector.y * 1.2*jumpSpeed
			elif(!$BufferTimer.is_stopped()):
				$BufferTimer.stop()
				$SuperTimer.stop()
				velocity.y = inputVector.y * jumpSpeed
				$"/root/Helpers".apply_camera_shake(0.2)
	
	if (velocity.y < 0 && !(Input.is_action_pressed(jump) && Input.is_action_pressed(jump2)) ):
		velocity.y += gravity * jumpEndMultiplier * delta
		inputVector.x *= apexTweak
		velocity.x *= 1.05
	else:
		velocity.y += gravity * delta
		
	velocity.x += inputVector.x * xAcceleration * delta
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)

	if(!is_on_floor()):
		#call_deferred("disable_floor_hitbox")
		if(wasOnFloor):
			$CoyoteTimer.start()
	else:
		hasDoubleJump = true
		#if(velocity.y == 0):
			#call_deferred("enable_floor_hitbox")
	
	if(Input.is_action_just_pressed("ui_secondary")):
		call_deferred("change_state", State.DASHING)
	update_animation()

func process_dash(delta):
	if(isStateNew):
		$"/root/Helpers".apply_camera_shake(.75)
		$DashArea/CollisionShape2D.disabled = false
		$HitboxArea.collision_mask = dashHazardMask
		var inputVector = get_input_vector()
		var directionMod = 1 if $AnimatedSprite.flip_h else -1
		velocity = Vector2(maxDashSpeed * directionMod, 0)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -8 * delta))
	
	if (abs(velocity.x) < minDashSpeed):
		call_deferred("change_state", State.NORMAL)

func get_input_vector():
	var inputVector = Vector2.ZERO
	if(Input.get_action_strength(right) == Input.get_action_strength(left) && Input.get_action_strength(right) != 0):
		inputVector.x = 1 if $AnimatedSprite.flip_h else -1
	else:
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

func kill():
	var playerDeathInstance = playerDeathScene.instance()
	get_parent().add_child_below_node(self, playerDeathInstance)
	playerDeathInstance.global_position = global_position
	playerDeathInstance.velocity = velocity
	emit_signal("died")

func on_hazard_area_entered(_area2d):
	$"/root/Helpers".apply_camera_shake(1)
	call_deferred("kill")

func disable_floor_hitbox():
	$FloorCollisionShape2D.disabled = true

func enable_floor_hitbox():
	$FloorCollisionShape2D.disabled = false
