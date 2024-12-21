extends Node

@export var numberToPlay: int = 2

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func play():
	var validNodes = []
	for streamPlayer in get_children():
		if(!streamPlayer.playing):
			validNodes.append(streamPlayer)
			
	for i in numberToPlay:
		if(validNodes.size() == 0):
			break
		var idx = rng.randi_range(0, validNodes.size() - 1)	
		validNodes[idx].play()
		
		#@david I modified this line of code and IDK if it fully works or not
		validNodes.remove_at(idx)
