extends Enemy

@export var speed = 300.0

@onready var laser = $l

func _ready():
	add_to_group("enemies")
	while hp > 0:
		toggle_laser()
		await get_tree().create_timer(2).timeout
	pass

func _process(delta: float) -> void:
	if abs(speed) > 0:
		position.y += speed * delta
		speed = lerp(speed,0.0,delta * 2)
		
func toggle_laser():
	laser.visible = !laser.visible
	laser.can_hit = laser.visible
