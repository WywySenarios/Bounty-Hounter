extends Camera2D

var targetPosition = Vector2.ZERO

@export var backgroundColor # (Color, RGB)
@export var shakeNoise: FastNoiseLite

var xNoiseSampleVector = Vector2.RIGHT
var yNoiseSampleVector = Vector2.DOWN
var xNoiseSamplePosition = Vector2.ZERO
var yNoiseSamplePosition = Vector2.ZERO

var noiseSampleTravelRate = 500
var maxShakeOffset = 8 # low number gives you gentle swaying, good for stormfront
var currentShakePercentage =  0
var shakeDecay = 3

func _ready():
	RenderingServer.set_default_clear_color(backgroundColor)
	

func _process(delta):
	get_target_position()
	
	global_position = lerp(targetPosition, global_position, pow(2, -10*delta))
	if(Input.is_action_just_pressed("ui_secondary")):
		apply_shake(1)
	
	if(currentShakePercentage > 0):
		xNoiseSamplePosition += xNoiseSampleVector*noiseSampleTravelRate*delta
		yNoiseSamplePosition += yNoiseSampleVector*noiseSampleTravelRate*delta
		var xSample = shakeNoise.get_noise_2d(xNoiseSamplePosition.x, xNoiseSamplePosition.y)
		var ySample = shakeNoise.get_noise_2d(yNoiseSamplePosition.x, yNoiseSamplePosition.y)
		
		var calculatedOffset = Vector2(xSample, ySample) * maxShakeOffset * pow(currentShakePercentage, 2)
		offset = calculatedOffset
		
		currentShakePercentage = clamp(currentShakePercentage - shakeDecay * delta, 0, 1)
	
func apply_shake(percentage):
	currentShakePercentage = clamp(currentShakePercentage + percentage, 0, 1)
	
func get_target_position():
	var acquired = get_target_position_from_node_group("player")
	if(!acquired):
		get_target_position_from_node_group("player_death")
	
		
func get_target_position_from_node_group(groupName):
	var nodes = get_tree().get_nodes_in_group(groupName)
	if(nodes.size() > 0):
		var node = nodes[0]
		targetPosition = node.global_position
		return true
	return false
