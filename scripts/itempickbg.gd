extends Panel


var go = false

func _process(delta: float):
	if go:
		if scale.y < 1 || position.y > 270:
			scale.y += delta * 2
			position.y -= delta * 250 * 2
		if scale.y > 1 || position.y < 270:
			scale.y = 1
			position.y = 270
	else:
		if scale.y > 0 || position.y < 540:
			scale.y -= delta * 2
			position.y += delta * 250 * 2
		if scale.y < 0 || position.y > 540:
			scale.y = 0
			position.y = 540
