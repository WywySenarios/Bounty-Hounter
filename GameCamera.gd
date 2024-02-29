extends Camera2D

var targetPosition = Vector2.ZERO

func _process(delta):
	get_target_position()
	
	global_position = lerp(targetPosition, global_position, pow(2, -10*delta))
	
func get_target_position():
	var players = get_tree().get_nodes_in_group("player")
	if(players.size() > 0):
		var player = players[0]
		targetPosition = player.global_position
