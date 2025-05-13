extends Node2D

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	rng.randomize()
	rotate(rng.randf_range(0.0,360.0))
