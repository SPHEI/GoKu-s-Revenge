extends Enemy

@export var speed = 300.0

@onready var laser = $l

func _ready():
	add_to_group("enemies")
	while hp > 0:
		await get_tree().create_timer(2).timeout
		await toggle_laser()
	pass

func _process(delta: float) -> void:
	if abs(speed) > 0:
		position.y += speed * delta
		speed = lerp(speed,0.0,delta * 2)
		
func toggle_laser():
	if laser.visible:
		laser.can_hit = false
		await get_tree().create_timer(0.5).timeout
		laser.visible = false
	else:
		laser.can_hit = true
		laser.visible = true
		await get_tree().create_timer(0.5).timeout
