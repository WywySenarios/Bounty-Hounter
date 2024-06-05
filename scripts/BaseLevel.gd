extends Node

signal coin_total_changed

var playerScene = preload("res://scenes/Player.tscn") # so it's available
var spawnPosition = Vector2.ZERO
var currentPlayerNode = null
var totalCoins = 0
var collectedCoins = 0

func _ready():
	spawnPosition = $PlayerRoot/Player.global_position
	register_player($PlayerRoot/Player)
	coin_total_changed(get_tree().get_nodes_in_group("coin").size())

	$TriggersAndTransitions/Flag.connect("player_won", Callable(self, "on_player_won"))
	
func coin_collected():
	collectedCoins += 1
	emit_signal("coin_total_changed", totalCoins, collectedCoins)

func coin_total_changed(newTotal):
	totalCoins = newTotal
	emit_signal("coin_total_changed", totalCoins, collectedCoins)

func register_player(player):
	currentPlayerNode = player
	currentPlayerNode.connect("died", Callable(self, "on_player_died").bind(), CONNECT_DEFERRED)

func create_player():
	var playerInstance = playerScene.instantiate()
	$PlayerRoot.add_child(playerInstance)
	playerInstance.global_position = spawnPosition
	register_player(playerInstance)

func on_player_died():
	currentPlayerNode.queue_free()
	
	#good for simple delays that only need to happen once
	var timer = get_tree().create_timer(1)
	await timer.timeout
	
	create_player()

func on_player_won(): #change
	$"/root/LevelManager".increment_level()
