extends Area2D

@export var speed = 30

@onready var explosion = preload("res://scenes/effects/explosion_small.tscn")

func _ready():
	add_to_group("enemies")
	pass

func _process(delta: float) -> void:
	position.y += speed * delta

func get_hit():
	var e = explosion.instantiate()
	e.position = position
	get_tree().root.add_child(e)
	queue_free()
