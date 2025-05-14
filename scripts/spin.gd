extends Sprite2D

func _ready():
	scale = Vector2(5.0,5.0)

@export var expand = false
var done = false
func _physics_process(delta):
	if expand:
		scale += Vector2(10,10) * delta
		modulate.a = 1.0/scale.x
	else:
		if scale.x > 1 and scale.y > 1:
			scale -= Vector2(10,10) * delta
			modulate.a = 1.0/scale.x
		elif scale.x < 1 or scale.y < 1:
			scale = Vector2(1.0,1.0) 
			done = true
	rotation -= 5 * delta
