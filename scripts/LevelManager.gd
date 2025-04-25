extends Node3D

var currentLevelObjects = [null,null,null]
var currentLevelId = 0
#speed up to check if scrolling is aligned properly
@export var speed = 10.0
#Add new levels here
var sceneList = [
	#[Scene name, Scene length]
	["res://scenes/levels/testPlane.tscn",200],
	["res://scenes/levels/ocean.tscn", 255]
]

@export var ui: Control = null;
var label: Label = null;

func _ready():
	for l in ui.get_children():
		if l.name == "CurrentLevel":
			label = l;
	#change number to change starting level
	updateLevel()
func _physics_process(delta: float):
	if not updating:
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


var updating = false
func updateLevel():
	updating = true
	label.text = "Current Level: " + str(currentLevelId)
	ResourceLoader.load_threaded_request(sceneList[currentLevelId][0])
	for i in range(3):
		if currentLevelObjects[i] != null:
			remove_child(currentLevelObjects[i])
	while(ResourceLoader.load_threaded_get_status(sceneList[currentLevelId][0]) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS):
			await get_tree().create_timer(0.2).timeout
	var l = ResourceLoader.load_threaded_get(sceneList[currentLevelId][0])
	for i in range(3):
		currentLevelObjects[i] = l.instantiate()
		add_child(currentLevelObjects[i])
		currentLevelObjects[i].position = Vector3(0,0,-sceneList[currentLevelId][1] * i)
		if i > 0:
			for child in currentLevelObjects[i].get_children():
				if child is DirectionalLight3D or child is WorldEnvironment:
					currentLevelObjects[i].remove_child(child)
	updating = false

func nextLevel():
	currentLevelId += 1
	if currentLevelId >= sceneList.size():
		currentLevelId = 0
	await updateLevel()
