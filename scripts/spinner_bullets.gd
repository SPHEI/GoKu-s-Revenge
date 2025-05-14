extends Enemy

@onready var bullet = preload("res://scenes/bullets/enemy_bullet_basic_shoot.tscn")

func _ready():
	add_to_group("enemies")
var can_shoot = true
func _process(delta):
	rotation += -1 * delta
	if can_shoot:
		can_shoot = false
		get_tree().create_timer(1.5).timeout.connect(func(): can_shoot = true)
		for i in range(3):
			var b = bullet.instantiate()
			b.position = position
			b.dir = Vector2(0,1)
			b.dir = b.dir.rotated(rotation)
			b.dir = b.dir.rotated(deg_to_rad(120 * i))
			b.speed = 100
			get_tree().root.add_child(b)
		
