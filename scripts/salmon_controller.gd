extends RigidBody3D

@export var pull_strength := 5
@export var gravity_counteract_strength = -0.5
@export var jump_strength_impulse = 0.8
@export var jump_strength_force = 6
@export var upright_torque_strength = 0.5
@export var right_torque_strength = 0.1
@export var linear_damping = 0.5
@export var angular_damping = 0.99
@export var cam_full_amount = 0.8
@export var speed_dir_lerp_amount = 0.8
@export var negative_vertical_deadzone = 0.7
@export var jump_impulse_version = false

var swim_animation_amount = 0.0

func _ready() -> void:
	pass

func _physics_process(delta):
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	
	var nose_offset = -global_transform.basis.z
	
	if Input.is_action_pressed("move_forward"):
		apply_force(get_swim_dir(cam) * pull_strength, nose_offset)

		# Counteract gravity
		apply_force(Vector3(0.0, gravity_counteract_strength, 0.0))
		
		apply_torque_to_axis(Vector3.UP, upright_torque_strength)
		var horizontal_vel_vec = linear_velocity
		horizontal_vel_vec.y = 0
		var horizontal_vel = horizontal_vel_vec.length()
		swim_animation_amount = lerp(swim_animation_amount, clamp(horizontal_vel / 3.0, 0.0, 1.0), 0.01)
	else:
		swim_animation_amount = lerp(swim_animation_amount, 0.0, 0.05)
		#apply_torque_to_axis(Vector3.RIGHT, right_torque_strength)
		
	$SalmonMesh/AnimationTree.set("parameters/Blend2/blend_amount", swim_animation_amount)

	if jump_impulse_version:
		if Input.is_action_just_pressed("jump"):
			apply_impulse(Vector3.UP * jump_strength_impulse, nose_offset)
		
		if Input.is_action_just_pressed("dive"):
			apply_impulse(Vector3.UP * -jump_strength_impulse, nose_offset)
	else: # Force version
		if Input.is_action_pressed("jump"):
			apply_force(Vector3.UP * jump_strength_force, nose_offset)

		if Input.is_action_pressed("dive"):
			apply_force(Vector3.UP * -jump_strength_force, nose_offset)
	
	apply_damping()

func apply_torque_to_axis(a, strength):
	var axis = global_transform.basis.y.cross(a)
	var angle = global_transform.basis.y.angle_to(a)

	apply_torque(axis.normalized() * angle * strength)


func apply_damping():
	apply_force(-linear_velocity * linear_damping)
	apply_torque(-angular_velocity * angular_damping)

	
func get_swim_dir(cam):
	var cam_flat = -cam.global_transform.basis.z
	cam_flat.y = 0.0
	cam_flat = cam_flat.normalized()
	var cam_full = get_filtered_cam(cam)
	var dir = cam_flat.lerp(cam_full, cam_full_amount).normalized()
	dir = (-global_transform.basis.z).lerp(dir, speed_dir_lerp_amount).normalized()
	return dir


func get_filtered_cam(cam):
	var cam_dir = (-cam.global_transform.basis.z).normalized()

	var y = cam_dir.y
	var deadzone = -negative_vertical_deadzone
	
	if y < 0.0 and y > deadzone:
		y = 0.0
	elif y < deadzone:
		var remapped = (y - deadzone) / (1.0 + deadzone)
		y = remapped

	var filtered = Vector3(cam_dir.x, 0.0, cam_dir.z).normalized()
	filtered = (filtered + Vector3(0, y, 0)).normalized()
	return filtered
