extends Control


var plr
var level = 0

func _ready():
	plr = get_node("/root/Main/SubViewportContainer/Main_Viewport/Player")
