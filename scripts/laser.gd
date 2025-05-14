extends Area2D


var can_hit = true
var plr: Node2D
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

var plr_in_range = false
func _process(_delta):
	if can_hit and plr_in_range:
		plr.hit()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		plr = body
		plr_in_range = true;
func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		plr_in_range = false;
