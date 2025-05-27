extends Enemy

@export var speed = 30


func _ready():
	add_to_group("enemies")

func _process(delta: float) -> void:
	if position.y < 540:
		position.y += speed * delta
