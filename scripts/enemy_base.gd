extends Area2D

class_name Enemy

@onready var explosion = preload("res://scenes/effects/explosion_small.tscn")

@export var hp = 1
#Call this from player bullet script
func get_hit():
	hp -= 1
	if hp <= 0:
		var e = explosion.instantiate()
		e.position = position
		get_tree().root.add_child(e)
		get_tree().get_nodes_in_group("player")[0].inc_ability()
		queue_free()
