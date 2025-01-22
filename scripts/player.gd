extends CharacterBody3D

@export_group("Movement")
@export var movement_speed := 8.0
@export var acceleration := 60.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0

@export_group("Skin")
@export var _character_model: MeshInstance3D

#@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %PlayerCamera

var _last_move_direction := Vector3.FORWARD
var _gravity := -50

func _physics_process(delta: float) -> void:
	
	var move_direction = Vector3.ZERO
	var player_input_direction = Input.get_vector("left", "right"
			, "forward", "back")
	
	var camera_forward = _camera.global_basis.z
	var camera_right = _camera.global_basis.x
	
	move_direction = camera_forward * player_input_direction.y + camera_right * player_input_direction.x
	#move_direction.x = player_input_direction.x * _camera.global_basis.x
	#move_direction.z = player_input_direction.y * _camera.global_basis.z
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	
	velocity = velocity.move_toward(move_direction * movement_speed
			, acceleration * delta)
	
	velocity.y = y_velocity + _gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_impulse
	
	move_and_slide()
	
	# handle visual rotation of character model
	
	if move_direction.length() > 0.0:
		_last_move_direction = move_direction

	var target_angle := Vector3.FORWARD.signed_angle_to(_last_move_direction
		, Vector3.UP)
	_character_model.global_rotation.y = lerp_angle(_character_model.rotation.y
		, target_angle, rotation_speed * delta)
