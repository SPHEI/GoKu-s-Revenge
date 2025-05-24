extends Control

var style = StyleBoxFlat.new()
var a = 0.0

func _ready() -> void:
	add_theme_stylebox_override("panel", style)
	style.set_bg_color(Color(1,0,0,a))

func _process(delta: float) -> void:
	if a > 0:
		style.set_bg_color(Color(1,0,0,a))
		a -= delta * 4
		if a < 0:
			a = 0
