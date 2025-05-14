extends Enemy

@export var speed = 30


func _ready():
	add_to_group("enemies")
	get_tree().create_timer(20).timeout.connect(func(): can_move = false)
	pass

var can_move = true
func _process(delta: float) -> void:
	if can_move:
		position.y += speed * delta
