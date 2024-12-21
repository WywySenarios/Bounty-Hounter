extends Node

@export var levelScenes: Array = [preload("res://scenes//levels//Level_001.tscn"), preload("res://scenes//levels//Level_002.tscn")] # (Array, PackedScene)

var currentLevelIndex = 0

func change_level(levelIndex):
	currentLevelIndex = levelIndex
	if(currentLevelIndex >= levelScenes.size()):
		currentLevelIndex = 0
	
	
	get_tree().change_scene_to_packed.call_deferred(levelScenes[currentLevelIndex])

func increment_level(): # change
	change_level(currentLevelIndex + 1)
