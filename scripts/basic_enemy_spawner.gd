extends Enemy

@export var speed = 30


func _ready():
	add_to_group("enemies")
	pass

func _process(delta: float) -> void:
	position.y += speed * delta
