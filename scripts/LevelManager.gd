extends Node3D

var currentLevelObjects = [null,null,null]
var currentLevelId = 0
#speed up to check if scrolling is aligned properly
@export var speed = 10.0
#Add new levels here
var sceneList = [
	#[Scene name, Scene length]
	["res://scenes/testPlane.tscn",200],
	["res://scenes/ocean.tscn", 254]
]

func _ready():
	#change number to change starting level
	updateLevel()
func _process(delta: float):
	#Ctrl + =
	if Input.is_action_just_pressed("debug_nextScene"):
		currentLevelId += 1
		if currentLevelId >= sceneList.size():
			currentLevelId = 0
		updateLevel()
	#Ctrl + -
	if Input.is_action_just_pressed("debug_previousScene"):
		currentLevelId -= 1
		if currentLevelId < 0:
			currentLevelId = sceneList.size() - 1
		updateLevel()
	
	if currentLevelObjects[0] != null and currentLevelObjects[1] != null and currentLevelObjects[2] != null:
		for i in range(3):
			currentLevelObjects[i].position += Vector3(0,0,speed) * delta
		if currentLevelObjects[1].position.z > 0:
			for i in range(3):
				currentLevelObjects[i].position = Vector3(0,0,-sceneList[currentLevelId][1] * i)

	
func updateLevel():
	var l = load(sceneList[currentLevelId][0])
	for i in range(3):
		if currentLevelObjects[i] != null:
			remove_child(currentLevelObjects[i])
		currentLevelObjects[i] = l.instantiate()
		add_child(currentLevelObjects[i])
		currentLevelObjects[i].position = Vector3(0,0,-sceneList[currentLevelId][1] * i)
