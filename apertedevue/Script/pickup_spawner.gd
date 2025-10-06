extends Node3D

@export var pickupScene : PackedScene

var waitTime = 5
var timeSpawned = waitTime

func _process(delta: float) -> void:
	if timeSpawned>=waitTime:
		SpawnPickup()
		timeSpawned=0
	timeSpawned+=delta
	
func SpawnPickup():
	var newPickup = pickupScene.instantiate()
	add_child(newPickup)
	newPickup.position = Vector3(randf_range(-5.0, 5.0), 0.0, randf_range(-5.0, 5.0))
	
	var area = newPickup.get_node("Area3D")
	var player = get_tree().root.get_node("Node3D/Player")
	area.body_entered.connect(player.EnterPickupArea)
	area.body_exited.connect(player.LeavePickupArea)
	#area.connect("area_entered", player.EnterPickupArea)
	#area.connect("area_exited", player.LeavePickupArea)
