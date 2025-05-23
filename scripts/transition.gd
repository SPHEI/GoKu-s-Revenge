extends AnimatedSprite2D

#0 - up, 1 - middle, 2 - down
var state = 2

func _process(delta: float) -> void:
	match state:
		0:
			position.y = -540
		1: 	
			if position.y < 540:
				position.y += delta * 3000
			if position.y > 540:
				position.y = 540
		2:
			if position.y < 1620:
				position.y += delta * 3000
			if position.y > 1620:
				position.y = 1620
