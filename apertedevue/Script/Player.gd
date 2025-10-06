extends CharacterBody3D

@export var speed = 3
var target_velocity = Vector3.ZERO

var rotation_speed = PI*2
var target_look_at_rot = 0

var curObjectInArea = null

var curSight=1.0

func _process(delta: float) -> void:
	PlayerGlobals.playerSight = clamp(PlayerGlobals.playerSight - delta * PlayerGlobals.sightLossOverTime, 0.0, 1.0)
	UpdateSight()
	if(Input.is_action_just_pressed("interact")):
		TryPickUpItem()

func _physics_process(delta: float) -> void:
	var frame_speed = 0
	var direction = Input.get_vector("move_right","move_left","move_back","move_forward")
	var inputStr = direction.length()
	if inputStr > 1.0:
		direction = direction.normalized()

	var normalizedDir = Vector3(direction.x, 0.0, direction.y).normalized()

	if direction != Vector2.ZERO:
		frame_speed = speed
			
		var cur_forward = $Pivot.get_global_transform().basis.z
		target_look_at_rot = cur_forward.signed_angle_to(normalizedDir, Vector3.UP)
		var rot = $Pivot.global_rotation
		
		$Pivot.rotate_y(target_look_at_rot * rotation_speed * delta)
		#$Pivot/Model/AnimationPlayer.play("CharLib/Walk")
	#else:
		#$Pivot/Model/AnimationPlayer.play("CharLib/Idle")
		
	target_velocity = Vector3(direction.x, 0.0, direction.y) * speed
	
	velocity = target_velocity
	move_and_slide()
	
func EnterPickupArea(obj: Node3D):
	if obj.is_in_group("Pickup"):
		curObjectInArea = obj
	
func LeavePickupArea(obj: Node3D):
	if obj.is_in_group("Pickup") and curObjectInArea == obj:
		curObjectInArea = null
	
func TryPickUpItem():
	if curObjectInArea == null or not curObjectInArea.is_in_group("Pickup"):
		return
		
	curObjectInArea.queue_free()
		
	PlayerGlobals.playerSight=1.0		
	UpdateSight()
	
func UpdateSight():
	var postProcessNode = get_tree().root.get_node("Node3D/SinglePassPostProcess/CanvasLayer/ColorRect")

	curSight = lerp(curSight, PlayerGlobals.playerSight, 0.1)

	var pixelSize = 1.0 - curSight
	pixelSize = 	remap(pixelSize, 0.0, 1.0, 0.1, 50)
	var vecPixelSize = Vector2(pixelSize, pixelSize)
	postProcessNode.material.set_shader_parameter("pixelSize", vecPixelSize)
