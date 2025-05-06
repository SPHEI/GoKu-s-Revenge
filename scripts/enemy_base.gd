extends Area2D

class_name Enemy

@onready var explosion = preload("res://scenes/effects/explosion_small.tscn")

#Call this from player bullet script
func get_hit():
	var e = explosion.instantiate()
	e.position = position
	get_tree().root.add_child(e)
	queue_free()
