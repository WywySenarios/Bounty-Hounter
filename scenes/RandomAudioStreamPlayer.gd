extends Node

export (int) var numberToPlay = 2

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
		validNodes.remove(idx)
