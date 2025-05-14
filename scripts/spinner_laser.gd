extends Enemy

@onready var laser = [$l,$l2,$l3]

func _ready():
	add_to_group("enemies")
	while hp > 0:
		await get_tree().create_timer(2).timeout
		await toggle_lasers()
	pass

func _process(delta: float) -> void:
	rotation += -1 * delta
		
func toggle_lasers():
	if laser[0].visible:
		laser[0].can_hit = false
		laser[1].can_hit = false
		laser[2].can_hit = false
		await get_tree().create_timer(0.5).timeout
		laser[0].visible = false
		laser[1].visible = false
		laser[2].visible = false
	else:
		laser[0].can_hit = true
		laser[0].visible = true
		laser[1].can_hit = true
		laser[1].visible = true
		laser[2].can_hit = true
		laser[2].visible = true
		await get_tree().create_timer(0.5).timeout
