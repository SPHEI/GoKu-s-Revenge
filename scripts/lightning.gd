extends OmniLight3D


var can_go = true;
var rng = RandomNumberGenerator.new()
func _ready() -> void:
	rng.seed = hash("Godot")
	rng.randomize()
	
func _process(delta: float) -> void:
	light_energy *= delta * 0.5
	if can_go:
		light_energy = 16
		can_go = false
		rng.randomize()
		get_tree().create_timer(rng.randf_range(1.0,4.0)).timeout.connect(func(): can_go = true)
		
