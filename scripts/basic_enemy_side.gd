extends Enemy

@export var speed = 300.0

func _ready():
	add_to_group("enemies")
	if position.x > 1000.0:
		speed *= -1.0
		scale = Vector2(-1,1)
	
func _process(delta: float) -> void:
	if abs(speed) > 0:
		position.x += speed * delta
		speed = lerp(speed,0.0,delta * 2)
